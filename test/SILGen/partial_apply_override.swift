// RUN: %target-swift-emit-silgen %s | %FileCheck %s

// rdar://45671537

class Converter<Input, Output> {
  func convert(input: Input) -> Output {
    fatalError("Has to be overridden")
  }
}

class StringIntConverter: Converter<String, Int> {
  override func convert(input: String) -> Int {
    return 0
  }
}

public func convert(strings: [String]) -> [Int] {
  return strings.map(StringIntConverter().convert)
}

// CHECK-LABEL: sil [ossa] @$s22partial_apply_override7convert7stringsSaySiGSaySSG_tF :
// CHECK:      [[CONVERTER_TYPE:%.*]] = metatype $@thick StringIntConverter.Type
// CHECK-NEXT: // function_ref
// CHECK-NEXT: [[ALLOC_CONVERTER:%.*]] = function_ref @$s22partial_apply_override18StringIntConverterCACycfC :
// CHECK-NEXT: [[CONVERTER:%.*]] = apply [[ALLOC_CONVERTER]]([[CONVERTER_TYPE]])
// CHECK-NEXT: // function_ref
// CHECK-NEXT: [[CURRY_THUNK:%.*]] = function_ref @$s22partial_apply_override7convert7stringsSaySiGSaySSG_tFSiSScAA18StringIntConverterCcfu_ : $@convention(thin) (@guaranteed StringIntConverter) -> @owned @callee_guaranteed (@guaranteed String) -> Int
// CHECK-NEXT: [[CURRY_RESULT:%.*]] = apply [[CURRY_THUNK]]([[CONVERTER]])
// CHECK: [[CONVERTED:%.*]] = convert_function [[CURRY_RESULT]]
// CHECK: [[NOESCAPE:%.*]] = convert_escape_to_noescape [not_guaranteed] [[CONVERTED]]
// CHECK: // function_ref
// CHECK-NEXT: [[THUNK:%.*]] = function_ref @$sSSSis5Error_pIggdzo_SSSisAA_pIegnrzo_TR : $@convention(thin) (@in_guaranteed String, @noescape @callee_guaranteed (@guaranteed String) -> (Int, @error any Error)) -> (@out Int, @error any Error)
// CHECK-NEXT: [[REABSTRACTED:%.*]] = partial_apply [callee_guaranteed] [[THUNK]]([[NOESCAPE]])

// CHECK-LABEL: sil private [ossa] @$s22partial_apply_override7convert7stringsSaySiGSaySSG_tFSiSScAA18StringIntConverterCcfu_SiSScfu0_ : $@convention(thin) (@guaranteed String, @guaranteed StringIntConverter) -> Int
// CHECK:      [[METHOD:%.*]] = class_method %1 : $StringIntConverter, #StringIntConverter.convert : (StringIntConverter) -> (String) -> Int, $@convention(method) (@in_guaranteed String, @guaranteed StringIntConverter) -> @out Int
