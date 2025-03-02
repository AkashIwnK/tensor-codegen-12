; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -vector-combine -mtriple=arm64-apple-darwinos -S %s | FileCheck --check-prefixes=CHECK,LIMIT-DEFAULT %s
; RUN: opt -vector-combine -enable-new-pm=false -mtriple=arm64-apple-darwinos -S %s | FileCheck --check-prefixes=CHECK,LIMIT-DEFAULT %s
; RUN: opt -vector-combine -mtriple=arm64-apple-darwinos -vector-combine-max-scan-instrs=2 -S %s | FileCheck --check-prefixes=CHECK,LIMIT2 %s

define i32 @load_extract_idx_0(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_idx_0(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 3
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 3
  ret i32 %r
}

; If the original load had a smaller alignment than the scalar type, the
; smaller alignment should be used.
define i32 @load_extract_idx_0_small_alignment(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_idx_0_small_alignment(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 3
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 2
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x, align 2
  %r = extractelement <4 x i32> %lv, i32 3
  ret i32 %r
}

define i32 @load_extract_idx_1(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_idx_1(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 1
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 1
  ret i32 %r
}

define i32 @load_extract_idx_2(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_idx_2(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 2
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 2
  ret i32 %r
}

define i32 @load_extract_idx_3(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_idx_3(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 3
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 3
  ret i32 %r
}

; Out-of-bounds index for extractelement, should not be converted to narrow
; load, because it would introduce a dereference of a poison pointer.
define i32 @load_extract_idx_4(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_idx_4(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 4
  ret i32 %r
}

define i32 @load_extract_idx_var_i64(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i64 %idx
  ret i32 %r
}

declare void @maythrow() readnone

define i32 @load_extract_idx_var_i64_known_valid_by_assume(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_known_valid_by_assume(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[IDX:%.*]], 4
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    call void @maythrow()
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i64 [[IDX]]
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP0]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %cmp = icmp ult i64 %idx, 4
  call void @llvm.assume(i1 %cmp)
  %lv = load <4 x i32>, <4 x i32>* %x
  call void @maythrow()
  %r = extractelement <4 x i32> %lv, i64 %idx
  ret i32 %r
}

define i32 @load_extract_idx_var_i64_not_known_valid_by_assume_after_load(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_not_known_valid_by_assume_after_load(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[IDX:%.*]], 4
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    call void @maythrow()
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX]]
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %cmp = icmp ult i64 %idx, 4
  %lv = load <4 x i32>, <4 x i32>* %x
  call void @maythrow()
  call void @llvm.assume(i1 %cmp)
  %r = extractelement <4 x i32> %lv, i64 %idx
  ret i32 %r
}

define i32 @load_extract_idx_var_i64_not_known_valid_by_assume(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_not_known_valid_by_assume(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[IDX:%.*]], 5
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX]]
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %cmp = icmp ult i64 %idx, 5
  call void @llvm.assume(i1 %cmp)
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i64 %idx
  ret i32 %r
}

declare void @llvm.assume(i1)

define i32 @load_extract_idx_var_i64_known_valid_by_and(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_known_valid_by_and(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[IDX_CLAMPED:%.*]] = and i64 [[IDX:%.*]], 3
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i64 [[IDX_CLAMPED]]
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP0]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %idx.clamped = and i64 %idx, 3
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i64 %idx.clamped
  ret i32 %r
}

define i32 @load_extract_idx_var_i64_not_known_valid_by_and(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_not_known_valid_by_and(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[IDX_CLAMPED:%.*]] = and i64 [[IDX:%.*]], 4
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_CLAMPED]]
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %idx.clamped = and i64 %idx, 4
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i64 %idx.clamped
  ret i32 %r
}

define i32 @load_extract_idx_var_i64_known_valid_by_urem(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_known_valid_by_urem(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[IDX_CLAMPED:%.*]] = urem i64 [[IDX:%.*]], 4
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i64 [[IDX_CLAMPED]]
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP0]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %idx.clamped = urem i64 %idx, 4
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i64 %idx.clamped
  ret i32 %r
}

define i32 @load_extract_idx_var_i64_not_known_valid_by_urem(<4 x i32>* %x, i64 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i64_not_known_valid_by_urem(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[IDX_CLAMPED:%.*]] = urem i64 [[IDX:%.*]], 5
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_CLAMPED]]
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %idx.clamped = urem i64 %idx, 5
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i64 %idx.clamped
  ret i32 %r
}

define i32 @load_extract_idx_var_i32(<4 x i32>* %x, i32 %idx) {
; CHECK-LABEL: @load_extract_idx_var_i32(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 [[IDX:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 %idx
  ret i32 %r
}

declare void @clobber()

define i32 @load_extract_clobber_call_before(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_clobber_call_before(
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 2
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  call void @clobber()
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 2
  ret i32 %r
}

define i32 @load_extract_clobber_call_between(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_clobber_call_between(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 2
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  call void @clobber()
  %r = extractelement <4 x i32> %lv, i32 2
  ret i32 %r
}

define i32 @load_extract_clobber_call_after(<4 x i32>* %x) {
; CHECK-LABEL: @load_extract_clobber_call_after(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 2
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 2
  call void @clobber()
  ret i32 %r
}

define i32 @load_extract_clobber_store_before(<4 x i32>* %x, i8* %y) {
; CHECK-LABEL: @load_extract_clobber_store_before(
; CHECK-NEXT:    store i8 0, i8* [[Y:%.*]], align 1
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 2
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  store i8 0, i8* %y
  %lv = load <4 x i32>, <4 x i32>* %x
  %r = extractelement <4 x i32> %lv, i32 2
  ret i32 %r
}

define i32 @load_extract_clobber_store_between(<4 x i32>* %x, i8* %y) {
; CHECK-LABEL: @load_extract_clobber_store_between(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    store i8 0, i8* [[Y:%.*]], align 1
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 2
; CHECK-NEXT:    ret i32 [[R]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  store i8 0, i8* %y
  %r = extractelement <4 x i32> %lv, i32 2
  ret i32 %r
}

define i32 @load_extract_clobber_store_between_limit(<4 x i32>* %x, i8* %y, <8 x i32> %z) {
; CHECK-LABEL: @load_extract_clobber_store_between_limit(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[Z_0:%.*]] = extractelement <8 x i32> [[Z:%.*]], i32 0
; CHECK-NEXT:    [[Z_1:%.*]] = extractelement <8 x i32> [[Z]], i32 1
; CHECK-NEXT:    [[ADD_0:%.*]] = add i32 [[Z_0]], [[Z_1]]
; CHECK-NEXT:    [[Z_2:%.*]] = extractelement <8 x i32> [[Z]], i32 2
; CHECK-NEXT:    [[ADD_1:%.*]] = add i32 [[ADD_0]], [[Z_2]]
; CHECK-NEXT:    [[Z_3:%.*]] = extractelement <8 x i32> [[Z]], i32 3
; CHECK-NEXT:    [[ADD_2:%.*]] = add i32 [[ADD_1]], [[Z_3]]
; CHECK-NEXT:    [[Z_4:%.*]] = extractelement <8 x i32> [[Z]], i32 4
; CHECK-NEXT:    [[ADD_3:%.*]] = add i32 [[ADD_2]], [[Z_4]]
; CHECK-NEXT:    store i8 0, i8* [[Y:%.*]], align 1
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 2
; CHECK-NEXT:    [[ADD_4:%.*]] = add i32 [[ADD_3]], [[R]]
; CHECK-NEXT:    ret i32 [[ADD_4]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %z.0 = extractelement <8 x i32> %z, i32 0
  %z.1 = extractelement <8 x i32> %z, i32 1
  %add.0 = add i32 %z.0, %z.1
  %z.2 = extractelement <8 x i32> %z, i32 2
  %add.1 = add i32 %add.0, %z.2
  %z.3 = extractelement <8 x i32> %z, i32 3
  %add.2 = add i32 %add.1, %z.3
  %z.4 = extractelement <8 x i32> %z, i32 4
  %add.3 = add i32 %add.2, %z.4
  store i8 0, i8* %y
  %r = extractelement <4 x i32> %lv, i32 2
  %add.4 = add i32 %add.3, %r
  ret i32 %add.4
}

define i32 @load_extract_clobber_store_after_limit(<4 x i32>* %x, i8* %y, <8 x i32> %z) {
; LIMIT-DEFAULT-LABEL: @load_extract_clobber_store_after_limit(
; LIMIT-DEFAULT-NEXT:    [[Z_0:%.*]] = extractelement <8 x i32> [[Z:%.*]], i32 0
; LIMIT-DEFAULT-NEXT:    [[Z_1:%.*]] = extractelement <8 x i32> [[Z]], i32 1
; LIMIT-DEFAULT-NEXT:    [[ADD_0:%.*]] = add i32 [[Z_0]], [[Z_1]]
; LIMIT-DEFAULT-NEXT:    [[Z_2:%.*]] = extractelement <8 x i32> [[Z]], i32 2
; LIMIT-DEFAULT-NEXT:    [[ADD_1:%.*]] = add i32 [[ADD_0]], [[Z_2]]
; LIMIT-DEFAULT-NEXT:    [[Z_3:%.*]] = extractelement <8 x i32> [[Z]], i32 3
; LIMIT-DEFAULT-NEXT:    [[ADD_2:%.*]] = add i32 [[ADD_1]], [[Z_3]]
; LIMIT-DEFAULT-NEXT:    [[Z_4:%.*]] = extractelement <8 x i32> [[Z]], i32 4
; LIMIT-DEFAULT-NEXT:    [[ADD_3:%.*]] = add i32 [[ADD_2]], [[Z_4]]
; LIMIT-DEFAULT-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <4 x i32>, <4 x i32>* [[X:%.*]], i32 0, i32 2
; LIMIT-DEFAULT-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; LIMIT-DEFAULT-NEXT:    store i8 0, i8* [[Y:%.*]], align 1
; LIMIT-DEFAULT-NEXT:    [[ADD_4:%.*]] = add i32 [[ADD_3]], [[R]]
; LIMIT-DEFAULT-NEXT:    ret i32 [[ADD_4]]
;
; LIMIT2-LABEL: @load_extract_clobber_store_after_limit(
; LIMIT2-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; LIMIT2-NEXT:    [[Z_0:%.*]] = extractelement <8 x i32> [[Z:%.*]], i32 0
; LIMIT2-NEXT:    [[Z_1:%.*]] = extractelement <8 x i32> [[Z]], i32 1
; LIMIT2-NEXT:    [[ADD_0:%.*]] = add i32 [[Z_0]], [[Z_1]]
; LIMIT2-NEXT:    [[Z_2:%.*]] = extractelement <8 x i32> [[Z]], i32 2
; LIMIT2-NEXT:    [[ADD_1:%.*]] = add i32 [[ADD_0]], [[Z_2]]
; LIMIT2-NEXT:    [[Z_3:%.*]] = extractelement <8 x i32> [[Z]], i32 3
; LIMIT2-NEXT:    [[ADD_2:%.*]] = add i32 [[ADD_1]], [[Z_3]]
; LIMIT2-NEXT:    [[Z_4:%.*]] = extractelement <8 x i32> [[Z]], i32 4
; LIMIT2-NEXT:    [[ADD_3:%.*]] = add i32 [[ADD_2]], [[Z_4]]
; LIMIT2-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 2
; LIMIT2-NEXT:    store i8 0, i8* [[Y:%.*]], align 1
; LIMIT2-NEXT:    [[ADD_4:%.*]] = add i32 [[ADD_3]], [[R]]
; LIMIT2-NEXT:    ret i32 [[ADD_4]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %z.0 = extractelement <8 x i32> %z, i32 0
  %z.1 = extractelement <8 x i32> %z, i32 1
  %add.0 = add i32 %z.0, %z.1
  %z.2 = extractelement <8 x i32> %z, i32 2
  %add.1 = add i32 %add.0, %z.2
  %z.3 = extractelement <8 x i32> %z, i32 3
  %add.2 = add i32 %add.1, %z.3
  %z.4 = extractelement <8 x i32> %z, i32 4
  %add.3 = add i32 %add.2, %z.4
  %r = extractelement <4 x i32> %lv, i32 2
  store i8 0, i8* %y
  %add.4 = add i32 %add.3, %r
  ret i32 %add.4
}

declare void @use.v4i32(<4 x i32>)

define i32 @load_extract_idx_different_bbs(<4 x i32>* %x, i1 %c) {
; CHECK-LABEL: @load_extract_idx_different_bbs(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    br i1 [[C:%.*]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[LV]], i32 1
; CHECK-NEXT:    ret i32 [[R]]
; CHECK:       else:
; CHECK-NEXT:    call void @use.v4i32(<4 x i32> [[LV]])
; CHECK-NEXT:    ret i32 20
;
  %lv = load <4 x i32>, <4 x i32>* %x
  br i1 %c, label %then, label %else

then:
  %r = extractelement <4 x i32> %lv, i32 1
  ret i32 %r

else:
  call void @use.v4i32(<4 x i32> %lv)
  ret i32 20
}

define i31 @load_with_non_power_of_2_element_type(<4 x i31>* %x) {
; CHECK-LABEL: @load_with_non_power_of_2_element_type(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i31>, <4 x i31>* [[X:%.*]], align 16
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i31> [[LV]], i32 1
; CHECK-NEXT:    ret i31 [[R]]
;
  %lv = load <4 x i31>, <4 x i31>* %x
  %r = extractelement <4 x i31> %lv, i32 1
  ret i31 %r
}

; Scalarizing the load for multiple constant indices may not be profitable.
define i32 @load_multiple_extracts_with_constant_idx(<4 x i32>* %x) {
; CHECK-LABEL: @load_multiple_extracts_with_constant_idx(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[SHIFT:%.*]] = shufflevector <4 x i32> [[LV]], <4 x i32> poison, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i32> [[LV]], [[SHIFT]]
; CHECK-NEXT:    [[RES:%.*]] = extractelement <4 x i32> [[TMP1]], i32 0
; CHECK-NEXT:    ret i32 [[RES]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %e.0 = extractelement <4 x i32> %lv, i32 0
  %e.1 = extractelement <4 x i32> %lv, i32 1
  %res = add i32 %e.0, %e.1
  ret i32 %res
}

; Scalarizing the load for multiple extracts is profitable in this case,
; because the vector large vector requires 2 vector registers.
define i32 @load_multiple_extracts_with_constant_idx_profitable(<8 x i32>* %x) {
; CHECK-LABEL: @load_multiple_extracts_with_constant_idx_profitable(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <8 x i32>, <8 x i32>* [[X:%.*]], i32 0, i32 0
; CHECK-NEXT:    [[E_0:%.*]] = load i32, i32* [[TMP1]], align 16
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds <8 x i32>, <8 x i32>* [[X]], i32 0, i32 6
; CHECK-NEXT:    [[E_1:%.*]] = load i32, i32* [[TMP2]], align 4
; CHECK-NEXT:    [[RES:%.*]] = add i32 [[E_0]], [[E_1]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %lv = load <8 x i32>, <8 x i32>* %x, align 16
  %e.0 = extractelement <8 x i32> %lv, i32 0
  %e.1 = extractelement <8 x i32> %lv, i32 6
  %res = add i32 %e.0, %e.1
  ret i32 %res
}

; Scalarizing may or may not be profitable, depending on the target.
define i32 @load_multiple_2_with_variable_indices(<4 x i32>* %x, i64 %idx.0, i64 %idx.1) {
; CHECK-LABEL: @load_multiple_2_with_variable_indices(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[E_0:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_0:%.*]]
; CHECK-NEXT:    [[E_1:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_1:%.*]]
; CHECK-NEXT:    [[RES:%.*]] = add i32 [[E_0]], [[E_1]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %e.0 = extractelement <4 x i32> %lv, i64 %idx.0
  %e.1 = extractelement <4 x i32> %lv, i64 %idx.1
  %res = add i32 %e.0, %e.1
  ret i32 %res
}

define i32 @load_4_extracts_with_variable_indices_short_vector(<4 x i32>* %x, i64 %idx.0, i64 %idx.1, i64 %idx.2, i64 %idx.3) {
; CHECK-LABEL: @load_4_extracts_with_variable_indices_short_vector(
; CHECK-NEXT:    [[LV:%.*]] = load <4 x i32>, <4 x i32>* [[X:%.*]], align 16
; CHECK-NEXT:    [[E_0:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_0:%.*]]
; CHECK-NEXT:    [[E_1:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_1:%.*]]
; CHECK-NEXT:    [[E_2:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_2:%.*]]
; CHECK-NEXT:    [[E_3:%.*]] = extractelement <4 x i32> [[LV]], i64 [[IDX_3:%.*]]
; CHECK-NEXT:    [[RES_0:%.*]] = add i32 [[E_0]], [[E_1]]
; CHECK-NEXT:    [[RES_1:%.*]] = add i32 [[RES_0]], [[E_2]]
; CHECK-NEXT:    [[RES_2:%.*]] = add i32 [[RES_1]], [[E_3]]
; CHECK-NEXT:    ret i32 [[RES_2]]
;
  %lv = load <4 x i32>, <4 x i32>* %x
  %e.0 = extractelement <4 x i32> %lv, i64 %idx.0
  %e.1 = extractelement <4 x i32> %lv, i64 %idx.1
  %e.2 = extractelement <4 x i32> %lv, i64 %idx.2
  %e.3 = extractelement <4 x i32> %lv, i64 %idx.3
  %res.0 = add i32 %e.0, %e.1
  %res.1 = add i32 %res.0, %e.2
  %res.2 = add i32 %res.1, %e.3
  ret i32 %res.2
}

define i32 @load_multiple_extracts_with_variable_indices_large_vector_only_first_valid(<16 x i32>* %x, i64 %idx.0, i64 %idx.1) {
; CHECK-LABEL: @load_multiple_extracts_with_variable_indices_large_vector_only_first_valid(
; CHECK-NEXT:    [[CMP_IDX_0:%.*]] = icmp ult i64 [[IDX_0:%.*]], 16
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP_IDX_0]])
; CHECK-NEXT:    [[LV:%.*]] = load <16 x i32>, <16 x i32>* [[X:%.*]], align 64
; CHECK-NEXT:    [[E_0:%.*]] = extractelement <16 x i32> [[LV]], i64 [[IDX_0]]
; CHECK-NEXT:    [[E_1:%.*]] = extractelement <16 x i32> [[LV]], i64 [[IDX_1:%.*]]
; CHECK-NEXT:    [[RES:%.*]] = add i32 [[E_0]], [[E_1]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %cmp.idx.0 = icmp ult i64 %idx.0, 16
  call void @llvm.assume(i1 %cmp.idx.0)

  %lv = load <16 x i32>, <16 x i32>* %x
  %e.0 = extractelement <16 x i32> %lv, i64 %idx.0
  %e.1 = extractelement <16 x i32> %lv, i64 %idx.1
  %res = add i32 %e.0, %e.1
  ret i32 %res
}

define i32 @load_multiple_extracts_with_variable_indices_large_vector_only_all_valid(<16 x i32>* %x, i64 %idx.0, i64 %idx.1) {
; CHECK-LABEL: @load_multiple_extracts_with_variable_indices_large_vector_only_all_valid(
; CHECK-NEXT:    [[CMP_IDX_0:%.*]] = icmp ult i64 [[IDX_0:%.*]], 16
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP_IDX_0]])
; CHECK-NEXT:    [[CMP_IDX_1:%.*]] = icmp ult i64 [[IDX_1:%.*]], 16
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP_IDX_1]])
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <16 x i32>, <16 x i32>* [[X:%.*]], i32 0, i64 [[IDX_0]]
; CHECK-NEXT:    [[E_0:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds <16 x i32>, <16 x i32>* [[X]], i32 0, i64 [[IDX_1]]
; CHECK-NEXT:    [[E_1:%.*]] = load i32, i32* [[TMP2]], align 4
; CHECK-NEXT:    [[RES:%.*]] = add i32 [[E_0]], [[E_1]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %cmp.idx.0 = icmp ult i64 %idx.0, 16
  call void @llvm.assume(i1 %cmp.idx.0)
  %cmp.idx.1 = icmp ult i64 %idx.1, 16
  call void @llvm.assume(i1 %cmp.idx.1)

  %lv = load <16 x i32>, <16 x i32>* %x
  %e.0 = extractelement <16 x i32> %lv, i64 %idx.0
  %e.1 = extractelement <16 x i32> %lv, i64 %idx.1
  %res = add i32 %e.0, %e.1
  ret i32 %res
}
