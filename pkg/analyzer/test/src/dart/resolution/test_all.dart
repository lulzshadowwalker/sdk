// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'adjacent_strings_test.dart' as adjacent_strings;
import 'as_expression_test.dart' as as_expression;
import 'assignment_test.dart' as assignment;
import 'ast_rewrite_test.dart' as ast_rewrite;
import 'augmentation_import_test.dart' as augmentation_import;
import 'await_expression_test.dart' as await_expression;
import 'binary_expression_test.dart' as binary_expression;
import 'cast_pattern_test.dart' as cast_pattern;
import 'class_alias_test.dart' as class_alias;
import 'class_test.dart' as class_resolution;
import 'comment_test.dart' as comment;
import 'conditional_expression_test.dart' as conditional_expression;
import 'constant_pattern_test.dart' as constant_pattern;
import 'constant_test.dart' as constant;
import 'constructor_field_initializer_test.dart'
    as constructor_field_initializer;
import 'constructor_reference_test.dart' as constructor_reference;
import 'constructor_test.dart' as constructor;
import 'declared_variable_pattern_test.dart' as declared_variable_pattern;
import 'enum_test.dart' as enum_resolution;
import 'extension_method_test.dart' as extension_method;
import 'extension_override_test.dart' as extension_override;
import 'extension_type_test.dart' as extension_type;
import 'field_formal_parameter_test.dart' as field_formal_parameter;
import 'field_promotion_test.dart' as field_promotion;
import 'field_test.dart' as field;
import 'for_element_test.dart' as for_element;
import 'for_statement_test.dart' as for_in;
import 'function_body_test.dart' as function_body;
import 'function_declaration_statement_test.dart'
    as function_declaration_statement;
import 'function_declaration_test.dart' as function_declaration;
import 'function_expression_invocation_test.dart'
    as function_expression_invocation;
import 'function_reference_test.dart' as function_reference;
import 'function_type_alias_test.dart' as function_type_alias;
import 'function_typed_formal_parameter_test.dart'
    as function_typed_formal_parameter;
import 'generic_function_type_test.dart' as generic_function_type;
import 'generic_type_alias_test.dart' as generic_type_alias;
import 'if_element_test.dart' as if_element;
import 'if_statement_test.dart' as if_statement;
import 'index_expression_test.dart' as index_expression;
import 'instance_creation_test.dart' as instance_creation;
import 'instance_member_inference_class_test.dart'
    as instance_member_inference_class;
import 'instance_member_inference_mixin_test.dart'
    as instance_member_inference_mixin;
import 'interpolation_string_test.dart' as interpolation_string;
import 'is_expression_test.dart' as is_expression;
import 'library_augmentation_test.dart' as library_element2;
import 'library_element_test.dart' as library_element;
import 'library_export_test.dart' as library_export;
import 'library_import_prefix_test.dart' as library_import_prefix;
import 'library_import_test.dart' as library_import;
import 'list_literal_test.dart' as list_literal;
import 'list_pattern_test.dart' as list_pattern;
import 'local_function_test.dart' as local_function;
import 'local_variable_test.dart' as local_variable;
import 'logical_and_pattern_test.dart' as logical_and_pattern;
import 'logical_or_pattern_test.dart' as logical_or_pattern;
import 'macro_test.dart' as macro;
import 'map_pattern_test.dart' as map_pattern;
import 'metadata_test.dart' as metadata;
import 'method_declaration_test.dart' as method_declaration;
import 'method_invocation_test.dart' as method_invocation;
import 'mixin_test.dart' as mixin_resolution;
import 'named_type_test.dart' as named_type;
import 'namespace_test.dart' as namespace;
import 'node_text_expectations.dart';
import 'non_nullable_test.dart' as non_nullable;
import 'null_assert_pattern_test.dart' as null_assert_pattern;
import 'null_check_pattern_test.dart' as null_check_pattern;
import 'object_pattern_test.dart' as object_pattern;
import 'optional_const_test.dart' as optional_const;
import 'parenthesized_expression_test.dart' as parenthesized_expression;
import 'parenthesized_pattern_test.dart' as parenthesized_pattern;
import 'part_test.dart' as part_;
import 'pattern_assignment_test.dart' as pattern_assignment;
import 'pattern_variable_declaration_statement_test.dart'
    as pattern_variable_declaration_statement;
import 'postfix_expression_test.dart' as postfix_expression;
import 'prefix_element_test.dart' as prefix_element;
import 'prefix_expression_test.dart' as prefix_expression;
import 'prefixed_identifier_test.dart' as prefixed_identifier;
import 'property_access_test.dart' as property_access;
import 'record_literal_test.dart' as record_literal;
import 'record_pattern_test.dart' as record_pattern;
import 'record_type_annotation_test.dart' as record_type_annotation;
import 'redirecting_constructor_invocation_test.dart'
    as redirecting_constructor_invocation;
import 'relational_pattern_test.dart' as relational_pattern;
import 'scope_test.dart' as scope;
import 'set_or_map_literal_test.dart' as set_or_map_literal;
import 'simple_identifier_test.dart' as simple_identifier;
import 'super_constructor_invocation_test.dart' as super_constructor_invocation;
import 'super_formal_parameter_test.dart' as super_formal_parameter;
import 'switch_expression_test.dart' as switch_expression;
import 'switch_statement_test.dart' as switch_statement;
import 'this_expression_test.dart' as this_expression;
import 'top_level_variable_test.dart' as top_level_variable;
import 'top_type_inference_test.dart' as top_type_inference;
import 'try_statement_test.dart' as try_statement;
import 'type_inference/test_all.dart' as type_inference;
import 'type_literal_test.dart' as type_literal;
import 'variable_declaration_statement_test.dart'
    as variable_declaration_statement;
import 'variance_test.dart' as variance_test;
import 'while_statement_test.dart' as while_statement;
import 'wildcard_pattern_test.dart' as wildcard_pattern;
import 'yield_statement_test.dart' as yield_statement;

main() {
  defineReflectiveSuite(() {
    adjacent_strings.main();
    as_expression.main();
    assignment.main();
    ast_rewrite.main();
    augmentation_import.main();
    await_expression.main();
    binary_expression.main();
    cast_pattern.main();
    class_alias.main();
    class_resolution.main();
    conditional_expression.main();
    constant_pattern.main();
    comment.main();
    constant.main();
    constructor_field_initializer.main();
    constructor_reference.main();
    constructor.main();
    declared_variable_pattern.main();
    enum_resolution.main();
    extension_method.main();
    extension_override.main();
    extension_type.main();
    field_formal_parameter.main();
    field_promotion.main();
    field.main();
    for_element.main();
    for_in.main();
    function_body.main();
    function_declaration_statement.main();
    function_declaration.main();
    function_expression_invocation.main();
    function_reference.main();
    function_type_alias.main();
    function_typed_formal_parameter.main();
    generic_function_type.main();
    generic_type_alias.main();
    if_element.main();
    if_statement.main();
    index_expression.main();
    instance_creation.main();
    instance_member_inference_class.main();
    instance_member_inference_mixin.main();
    interpolation_string.main();
    is_expression.main();
    library_element2.main();
    library_element.main();
    library_export.main();
    library_import_prefix.main();
    library_import.main();
    list_literal.main();
    list_pattern.main();
    local_function.main();
    local_variable.main();
    logical_and_pattern.main();
    logical_or_pattern.main();
    macro.main();
    map_pattern.main();
    metadata.main();
    method_declaration.main();
    method_invocation.main();
    mixin_resolution.main();
    named_type.main();
    namespace.main();
    non_nullable.main();
    null_assert_pattern.main();
    null_check_pattern.main();
    object_pattern.main();
    optional_const.main();
    parenthesized_expression.main();
    parenthesized_pattern.main();
    part_.main();
    pattern_assignment.main();
    pattern_variable_declaration_statement.main();
    postfix_expression.main();
    prefix_element.main();
    prefix_expression.main();
    prefixed_identifier.main();
    property_access.main();
    record_literal.main();
    record_pattern.main();
    record_type_annotation.main();
    redirecting_constructor_invocation.main();
    relational_pattern.main();
    scope.main();
    set_or_map_literal.main();
    simple_identifier.main();
    super_constructor_invocation.main();
    super_formal_parameter.main();
    switch_expression.main();
    switch_statement.main();
    this_expression.main();
    top_level_variable.main();
    top_type_inference.main();
    try_statement.main();
    type_inference.main();
    type_literal.main();
    variable_declaration_statement.main();
    variance_test.main();
    while_statement.main();
    wildcard_pattern.main();
    yield_statement.main();
    defineReflectiveTests(UpdateNodeTextExpectations);
  }, name: 'resolution');
}
