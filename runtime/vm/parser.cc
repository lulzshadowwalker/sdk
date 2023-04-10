// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/parser.h"
#include "vm/flags.h"

#ifndef DART_PRECOMPILED_RUNTIME

#include "lib/invocation_mirror.h"
#include "platform/utils.h"
#include "vm/bit_vector.h"
#include "vm/bootstrap.h"
#include "vm/class_finalizer.h"
#include "vm/compiler/aot/precompiler.h"
#include "vm/compiler/backend/il_printer.h"
#include "vm/compiler/frontend/scope_builder.h"
#include "vm/compiler/jit/compiler.h"
#include "vm/dart_api_impl.h"
#include "vm/dart_entry.h"
#include "vm/growable_array.h"
#include "vm/handles.h"
#include "vm/hash_table.h"
#include "vm/heap/heap.h"
#include "vm/heap/safepoint.h"
#include "vm/isolate.h"
#include "vm/longjump.h"
#include "vm/native_arguments.h"
#include "vm/native_entry.h"
#include "vm/object.h"
#include "vm/object_store.h"
#include "vm/os.h"
#include "vm/regexp_assembler.h"
#include "vm/resolver.h"
#include "vm/scopes.h"
#include "vm/stack_frame.h"
#include "vm/symbols.h"
#include "vm/tags.h"
#include "vm/timeline.h"
#include "vm/zone.h"

namespace dart {

// Quick access to the current thread, isolate and zone.
#define T (thread())
#define I (isolate())
#define Z (zone())

ParsedFunction::ParsedFunction(Thread* thread, const Function& function)
    : thread_(thread),
      function_(function),
      code_(Code::Handle(zone(), function.unoptimized_code())),
      scope_(nullptr),
      regexp_compile_data_(nullptr),
      function_type_arguments_(nullptr),
      parent_type_arguments_(nullptr),
      current_context_var_(nullptr),
      arg_desc_var_(nullptr),
      expression_temp_var_(nullptr),
      entry_points_temp_var_(nullptr),
      finally_return_temp_var_(nullptr),
      dynamic_closure_call_vars_(nullptr),
      guarded_fields_(),
      default_parameter_values_(nullptr),
      raw_type_arguments_var_(nullptr),
      first_parameter_index_(),
      num_stack_locals_(0),
      have_seen_await_expr_(false),
      kernel_scopes_(nullptr) {
  DEBUG_ASSERT(function.IsNotTemporaryScopedHandle());
  // Every function has a local variable for the current context.
  LocalVariable* temp = new (zone())
      LocalVariable(function.token_pos(), function.token_pos(),
                    Symbols::CurrentContextVar(), Object::dynamic_type());
  current_context_var_ = temp;

  if (function.PrologueNeedsArgumentsDescriptor()) {
    arg_desc_var_ = new (zone())
        LocalVariable(TokenPosition::kNoSource, TokenPosition::kNoSource,
                      Symbols::ArgDescVar(), Object::dynamic_type());
  }

  // The code generated by the prologue builder for loading optional arguments
  // requires the expression temporary variable.
  if (function.HasOptionalParameters()) {
    EnsureExpressionTemp();
  }
}

void ParsedFunction::AddToGuardedFields(const Field* field) const {
  if ((field->guarded_cid() == kDynamicCid) ||
      (field->guarded_cid() == kIllegalCid)) {
    return;
  }

  const Field** other = guarded_fields_.Lookup(field);
  if (other != nullptr) {
    ASSERT(field->Original() == (*other)->Original());
    // Abort background compilation early if the guarded state of this field
    // has changed during compilation. We will not be able to commit
    // the resulting code anyway.
    if (Compiler::IsBackgroundCompilation()) {
      if (!(*other)->IsConsistentWith(*field)) {
        Compiler::AbortBackgroundCompilation(
            DeoptId::kNone, "Field's guarded state changed during compilation");
      }
    }
    return;
  }

  // Note: the list of guarded fields must contain copies during optimizing
  // compilation because we will look at their guarded_cid when copying
  // the array of guarded fields from callee into the caller during
  // inlining.
  ASSERT(field->IsOriginal() ==
         !CompilerState::Current().should_clone_fields());
  guarded_fields_.Insert(&Field::ZoneHandle(Z, field->ptr()));
}

void ParsedFunction::Bailout(const char* origin, const char* reason) const {
  Report::MessageF(Report::kBailout, Script::Handle(function_.script()),
                   function_.token_pos(), Report::AtLocation,
                   "%s Bailout in %s: %s", origin,
                   String::Handle(function_.name()).ToCString(), reason);
  UNREACHABLE();
}

kernel::ScopeBuildingResult* ParsedFunction::EnsureKernelScopes() {
  if (kernel_scopes_ == nullptr) {
    kernel::ScopeBuilder builder(this);
    kernel_scopes_ = builder.BuildScopes();
  }
  return kernel_scopes_;
}

LocalVariable* ParsedFunction::EnsureExpressionTemp() {
  if (!has_expression_temp_var()) {
    LocalVariable* temp =
        new (Z) LocalVariable(function_.token_pos(), function_.token_pos(),
                              Symbols::ExprTemp(), Object::dynamic_type());
    ASSERT(temp != nullptr);
    set_expression_temp_var(temp);
  }
  ASSERT(has_expression_temp_var());
  return expression_temp_var();
}

LocalVariable* ParsedFunction::EnsureEntryPointsTemp() {
  if (!has_entry_points_temp_var()) {
    LocalVariable* temp = new (Z)
        LocalVariable(function_.token_pos(), function_.token_pos(),
                      Symbols::EntryPointsTemp(), Object::dynamic_type());
    ASSERT(temp != nullptr);
    set_entry_points_temp_var(temp);
  }
  ASSERT(has_entry_points_temp_var());
  return entry_points_temp_var();
}

void ParsedFunction::EnsureFinallyReturnTemp(bool is_async) {
  if (!has_finally_return_temp_var()) {
    LocalVariable* temp =
        new (Z) LocalVariable(function_.token_pos(), function_.token_pos(),
                              Symbols::FinallyRetVal(), Object::dynamic_type());
    ASSERT(temp != nullptr);
    temp->set_is_final();
    if (is_async) {
      temp->set_is_captured();
    }
    set_finally_return_temp_var(temp);
  }
  ASSERT(has_finally_return_temp_var());
}

void ParsedFunction::SetRegExpCompileData(
    RegExpCompileData* regexp_compile_data) {
  ASSERT(regexp_compile_data_ == nullptr);
  ASSERT(regexp_compile_data != nullptr);
  regexp_compile_data_ = regexp_compile_data;
}

void ParsedFunction::AllocateVariables() {
  ASSERT(!function().IsIrregexpFunction());
  LocalScope* scope = this->scope();
  const intptr_t num_fixed_params = function().num_fixed_parameters();
  const intptr_t num_opt_params = function().NumOptionalParameters();
  const intptr_t num_params = num_fixed_params + num_opt_params;
  const bool copy_parameters = function().MakesCopyOfParameters();

  // Before we start allocating indices to variables, we'll setup the
  // parameters array, which can be used to access the raw parameters (i.e. not
  // the potentially variables which are in the context)

  raw_parameters_ = new (Z) ZoneGrowableArray<LocalVariable*>(Z, num_params);
  for (intptr_t param = 0; param < num_params; ++param) {
    LocalVariable* variable = ParameterVariable(param);
    LocalVariable* raw_parameter = variable;
    if (variable->is_captured()) {
      String& tmp = String::ZoneHandle(Z);
      tmp = Symbols::FromConcat(T, Symbols::OriginalParam(), variable->name());

      RELEASE_ASSERT(scope->LocalLookupVariable(
                         tmp, variable->kernel_offset()) == nullptr);
      raw_parameter = new LocalVariable(
          variable->declaration_token_pos(), variable->token_pos(), tmp,
          variable->type(), variable->kernel_offset(),
          variable->parameter_type(), variable->parameter_value());
      if (variable->is_explicit_covariant_parameter()) {
        raw_parameter->set_is_explicit_covariant_parameter();
      }
      if (variable->needs_covariant_check_in_method()) {
        raw_parameter->set_needs_covariant_check_in_method();
      }
      raw_parameter->set_type_check_mode(variable->type_check_mode());
      if (copy_parameters) {
        bool ok = scope->AddVariable(raw_parameter);
        ASSERT(ok);

        // Currently our optimizer cannot prove liveness of variables properly
        // when a function has try/catch.  It therefore makes the conservative
        // estimate that all [LocalVariable]s in the frame are live and spills
        // them before call sites (in some shape or form).
        //
        // Since we are guaranteed to not need that, we tell the try/catch
        // sync moves mechanism not to care about this variable.
        //
        // Receiver (this variable) is an exception from this rule because
        // it is immutable and we don't reload captured it from the context but
        // instead use raw_parameter to access it. This means we must still
        // consider it when emitting the catch entry moves.
        const bool is_receiver_var =
            function().HasThisParameter() && receiver_var_ == variable;
        if (!is_receiver_var) {
          raw_parameter->set_is_captured_parameter(true);
        }

      } else {
        raw_parameter->set_index(
            VariableIndex(function().NumParameters() - param));
      }
    }
    raw_parameters_->Add(raw_parameter);
  }
  if (function_type_arguments_ != nullptr) {
    LocalVariable* raw_type_args_parameter = function_type_arguments_;
    if (function_type_arguments_->is_captured()) {
      String& tmp = String::ZoneHandle(Z);
      tmp = Symbols::FromConcat(T, Symbols::OriginalParam(),
                                function_type_arguments_->name());

      ASSERT(scope->LocalLookupVariable(
                 tmp, function_type_arguments_->kernel_offset()) == nullptr);
      raw_type_args_parameter =
          new LocalVariable(function_type_arguments_->declaration_token_pos(),
                            function_type_arguments_->token_pos(), tmp,
                            function_type_arguments_->type(),
                            function_type_arguments_->kernel_offset());
      bool ok = scope->AddVariable(raw_type_args_parameter);
      ASSERT(ok);
    }
    raw_type_arguments_var_ = raw_type_args_parameter;
  }

  // The copy parameters implementation will still write to local variables
  // which we assign indices as with the old CopyParams implementation.
  VariableIndex first_local_index;
  {
    // Compute start indices to parameters and locals, and the number of
    // parameters to copy.
    if (!copy_parameters) {
      ASSERT(suspend_state_var() == nullptr);
      first_parameter_index_ = VariableIndex(num_params);
      first_local_index = VariableIndex(0);
    } else {
      // :suspend_state variable is inserted at the fixed slot
      // before the copied parameters.
      const intptr_t reserved_var_slot_count =
          (suspend_state_var() != nullptr) ? 1 : 0;
      first_parameter_index_ = VariableIndex(-reserved_var_slot_count);
      first_local_index =
          VariableIndex(first_parameter_index_.value() - num_params);
    }
  }

  // Allocate parameters and local variables, either in the local frame or
  // in the context(s).
  bool found_captured_variables = false;
  VariableIndex next_free_index = scope->AllocateVariables(
      function(), first_parameter_index_, num_params, first_local_index,
      nullptr, &found_captured_variables);

  num_stack_locals_ = -next_free_index.value();
}

void ParsedFunction::AllocateIrregexpVariables(intptr_t num_stack_locals) {
  ASSERT(function().IsIrregexpFunction());
  ASSERT(function().NumOptionalParameters() == 0);
  const intptr_t num_params = function().num_fixed_parameters();
  ASSERT(num_params == RegExpMacroAssembler::kParamCount);
  // Compute start indices to parameters and locals, and the number of
  // parameters to copy.
  first_parameter_index_ = VariableIndex(num_params);

  // Frame indices are relative to the frame pointer and are decreasing.
  num_stack_locals_ = num_stack_locals;
}

void ParsedFunction::SetCovariantParameters(
    const BitVector* covariant_parameters) {
  ASSERT(covariant_parameters_ == nullptr);
  ASSERT(covariant_parameters->length() == function_.NumParameters());
  covariant_parameters_ = covariant_parameters;
}

void ParsedFunction::SetGenericCovariantImplParameters(
    const BitVector* generic_covariant_impl_parameters) {
  ASSERT(generic_covariant_impl_parameters_ == nullptr);
  ASSERT(generic_covariant_impl_parameters->length() ==
         function_.NumParameters());
  generic_covariant_impl_parameters_ = generic_covariant_impl_parameters;
}

bool ParsedFunction::IsCovariantParameter(intptr_t i) const {
  ASSERT(covariant_parameters_ != nullptr);
  ASSERT((i >= 0) && (i < function_.NumParameters()));
  return covariant_parameters_->Contains(i);
}

bool ParsedFunction::IsGenericCovariantImplParameter(intptr_t i) const {
  ASSERT(generic_covariant_impl_parameters_ != nullptr);
  ASSERT((i >= 0) && (i < function_.NumParameters()));
  return generic_covariant_impl_parameters_->Contains(i);
}

ParsedFunction::DynamicClosureCallVars*
ParsedFunction::EnsureDynamicClosureCallVars() {
  ASSERT(function().IsDynamicClosureCallDispatcher(thread()));
  if (dynamic_closure_call_vars_ != nullptr) return dynamic_closure_call_vars_;
  const auto& saved_args_desc =
      Array::Handle(zone(), function().saved_args_desc());
  const ArgumentsDescriptor descriptor(saved_args_desc);

  dynamic_closure_call_vars_ =
      new (zone()) DynamicClosureCallVars(zone(), descriptor.NamedCount());

  auto const pos = function().token_pos();
  const auto& type_Dynamic = Object::dynamic_type();
  const auto& type_Function =
      Type::ZoneHandle(zone(), Type::DartFunctionType());
  const auto& type_Smi = Type::ZoneHandle(zone(), Type::SmiType());
#define INIT_FIELD(Name, TypeName, Symbol)                                     \
  dynamic_closure_call_vars_->Name = new (zone()) LocalVariable(               \
      pos, pos, Symbols::DynamicCall##Symbol##Var(), type_##TypeName);
  FOR_EACH_DYNAMIC_CLOSURE_CALL_VARIABLE(INIT_FIELD);
#undef INIT_FIELD

  for (intptr_t i = 0; i < descriptor.NamedCount(); i++) {
    auto const name = OS::SCreate(
        zone(), ":dyn_call_named_argument_%" Pd "_parameter_index", i);
    auto const var = new (zone()) LocalVariable(
        pos, pos, String::ZoneHandle(zone(), Symbols::New(thread(), name)),
        type_Smi);
    dynamic_closure_call_vars_->named_argument_parameter_indices.Add(var);
  }

  return dynamic_closure_call_vars_;
}

}  // namespace dart

#endif  // DART_PRECOMPILED_RUNTIME
