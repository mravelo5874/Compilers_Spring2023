; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-unroll -unroll-runtime -unroll-count=4 -S | FileCheck %s
; RUN: opt < %s -passes='require<opt-remark-emit>,loop-unroll' -unroll-runtime -unroll-count=4 -S | FileCheck %s

; Check that loop unroll pass correctly handle loops with
; single exiting block not the loop header or latch.

define void @test1(i32* noalias %A) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[A:%.*]], align 4
; CHECK-NEXT:    call void @bar(i32 [[TMP0]])
; CHECK-NEXT:    br label [[FOR_HEADER:%.*]]
; CHECK:       for.header:
; CHECK-NEXT:    call void @bar(i32 [[TMP0]])
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    br label [[FOR_BODY_FOR_BODY_CRIT_EDGE:%.*]]
; CHECK:       for.body.for.body_crit_edge:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 1
; CHECK-NEXT:    [[DOTPRE:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE]])
; CHECK-NEXT:    br label [[FOR_BODY_1:%.*]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
; CHECK:       for.body.1:
; CHECK-NEXT:    br label [[FOR_BODY_FOR_BODY_CRIT_EDGE_1:%.*]]
; CHECK:       for.body.for.body_crit_edge.1:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_1:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 2
; CHECK-NEXT:    [[DOTPRE_1:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_1]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE_1]])
; CHECK-NEXT:    br label [[FOR_BODY_2:%.*]]
; CHECK:       for.body.2:
; CHECK-NEXT:    br label [[FOR_BODY_FOR_BODY_CRIT_EDGE_2:%.*]]
; CHECK:       for.body.for.body_crit_edge.2:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_2:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 3
; CHECK-NEXT:    [[DOTPRE_2:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_2]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE_2]])
; CHECK-NEXT:    br label [[FOR_BODY_3:%.*]]
; CHECK:       for.body.3:
; CHECK-NEXT:    br i1 false, label [[FOR_BODY_FOR_BODY_CRIT_EDGE_3:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.for.body_crit_edge.3:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_3:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 4
; CHECK-NEXT:    unreachable
;
entry:
  %0 = load i32, i32* %A, align 4
  call void @bar(i32 %0)
  br label %for.header

for.header:
  %1 = phi i32 [ %0, %entry ], [ %.pre, %for.body.for.body_crit_edge ]
  %i = phi i64 [ 0, %entry ], [ %inc, %for.body.for.body_crit_edge ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %i
  call void @bar(i32 %1)
  br label %for.body

for.body:
  %inc = add nsw i64 %i, 1
  %cmp = icmp slt i64 %inc, 4
  br i1 %cmp, label %for.body.for.body_crit_edge, label %for.end

for.body.for.body_crit_edge:
  %arrayidx.phi.trans.insert = getelementptr inbounds i32, i32* %A, i64 %inc
  %.pre = load i32, i32* %arrayidx.phi.trans.insert, align 4
  br label %for.header

for.end:
  ret void
}

; Check that loop unroll pass correctly handle loops with
; (1) exiting block not dominating the loop latch; and
; (2) exiting terminator instructions cannot be simplified to unconditional.

define void @test2(i32* noalias %A) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 true, label [[FOR_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[A:%.*]], align 4
; CHECK-NEXT:    call void @bar(i32 [[TMP0]])
; CHECK-NEXT:    br label [[FOR_HEADER:%.*]]
; CHECK:       for.header:
; CHECK-NEXT:    [[TMP1:%.*]] = phi i32 [ [[TMP0]], [[FOR_PREHEADER]] ], [ [[DOTPRE_3:%.*]], [[FOR_BODY_FOR_BODY_CRIT_EDGE_3:%.*]] ]
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ 0, [[FOR_PREHEADER]] ], [ [[INC_3:%.*]], [[FOR_BODY_FOR_BODY_CRIT_EDGE_3]] ]
; CHECK-NEXT:    call void @bar(i32 [[TMP1]])
; CHECK-NEXT:    [[INC:%.*]] = add nuw nsw i64 [[I]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY:%.*]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[CMP:%.*]] = call i1 @foo(i64 [[I]])
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE]], label [[FOR_END_LOOPEXIT:%.*]]
; CHECK:       for.body.for.body_crit_edge:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC]]
; CHECK-NEXT:    [[DOTPRE:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE]])
; CHECK-NEXT:    [[INC_1:%.*]] = add nuw nsw i64 [[INC]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY_1:%.*]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE_1:%.*]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
; CHECK:       for.body.1:
; CHECK-NEXT:    [[CMP_1:%.*]] = call i1 @foo(i64 [[INC]])
; CHECK-NEXT:    br i1 [[CMP_1]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE_1]], label [[FOR_END_LOOPEXIT]]
; CHECK:       for.body.for.body_crit_edge.1:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_1:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC_1]]
; CHECK-NEXT:    [[DOTPRE_1:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_1]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE_1]])
; CHECK-NEXT:    [[INC_2:%.*]] = add nuw nsw i64 [[INC_1]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY_2:%.*]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE_2:%.*]]
; CHECK:       for.body.2:
; CHECK-NEXT:    [[CMP_2:%.*]] = call i1 @foo(i64 [[INC_1]])
; CHECK-NEXT:    br i1 [[CMP_2]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE_2]], label [[FOR_END_LOOPEXIT]]
; CHECK:       for.body.for.body_crit_edge.2:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_2:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC_2]]
; CHECK-NEXT:    [[DOTPRE_2:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_2]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE_2]])
; CHECK-NEXT:    [[INC_3]] = add nsw i64 [[INC_2]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY_3:%.*]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE_3]]
; CHECK:       for.body.3:
; CHECK-NEXT:    [[CMP_3:%.*]] = call i1 @foo(i64 [[INC_2]])
; CHECK-NEXT:    br i1 [[CMP_3]], label [[FOR_BODY_FOR_BODY_CRIT_EDGE_3]], label [[FOR_END_LOOPEXIT]]
; CHECK:       for.body.for.body_crit_edge.3:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_3:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC_3]]
; CHECK-NEXT:    [[DOTPRE_3]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_3]], align 4
; CHECK-NEXT:    br label [[FOR_HEADER]], !llvm.loop !0
;
entry:
  br i1 true, label %for.preheader, label %for.end

for.preheader:
  %0 = load i32, i32* %A, align 4
  call void @bar(i32 %0)
  br label %for.header

for.header:
  %1 = phi i32 [ %0, %for.preheader ], [ %.pre, %for.body.for.body_crit_edge ]
  %i = phi i64 [ 0, %for.preheader ], [ %inc, %for.body.for.body_crit_edge ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %i
  call void @bar(i32 %1)
  %inc = add nsw i64 %i, 1
  br i1 true, label %for.body, label %for.body.for.body_crit_edge

for.body:
  %cmp = call i1 @foo(i64 %i)
  br i1 %cmp, label %for.body.for.body_crit_edge, label %for.end

for.body.for.body_crit_edge:
  %arrayidx.phi.trans.insert = getelementptr inbounds i32, i32* %A, i64 %inc
  %.pre = load i32, i32* %arrayidx.phi.trans.insert, align 4
  br label %for.header

for.end:
  ret void
}

; Check that loop unroll pass correctly handle loops with
; (1) multiple exiting blocks; and
; (2) loop latch is not an exiting block.

define void @test3(i32* noalias %A, i1 %cond) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[A:%.*]], align 4
; CHECK-NEXT:    call void @bar(i32 [[TMP0]])
; CHECK-NEXT:    br label [[FOR_HEADER:%.*]]
; CHECK:       for.header:
; CHECK-NEXT:    [[TMP1:%.*]] = phi i32 [ [[TMP0]], [[ENTRY:%.*]] ], [ [[DOTPRE_3:%.*]], [[FOR_BODY_FOR_BODY_CRIT_EDGE_3:%.*]] ]
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ 0, [[ENTRY]] ], [ [[INC_3:%.*]], [[FOR_BODY_FOR_BODY_CRIT_EDGE_3]] ]
; CHECK-NEXT:    call void @bar(i32 [[TMP1]])
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[FOR_BODY:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INC:%.*]] = add nuw nsw i64 [[I]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY_FOR_BODY_CRIT_EDGE:%.*]], label [[FOR_END]]
; CHECK:       for.body.for.body_crit_edge:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC]]
; CHECK-NEXT:    [[DOTPRE:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE]])
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY_1:%.*]], label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
; CHECK:       for.body.1:
; CHECK-NEXT:    [[INC_1:%.*]] = add nuw nsw i64 [[INC]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY_FOR_BODY_CRIT_EDGE_1:%.*]], label [[FOR_END]]
; CHECK:       for.body.for.body_crit_edge.1:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_1:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC_1]]
; CHECK-NEXT:    [[DOTPRE_1:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_1]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE_1]])
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY_2:%.*]], label [[FOR_END]]
; CHECK:       for.body.2:
; CHECK-NEXT:    [[INC_2:%.*]] = add nuw nsw i64 [[INC_1]], 1
; CHECK-NEXT:    br i1 true, label [[FOR_BODY_FOR_BODY_CRIT_EDGE_2:%.*]], label [[FOR_END]]
; CHECK:       for.body.for.body_crit_edge.2:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_2:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC_2]]
; CHECK-NEXT:    [[DOTPRE_2:%.*]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_2]], align 4
; CHECK-NEXT:    call void @bar(i32 [[DOTPRE_2]])
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY_3:%.*]], label [[FOR_END]]
; CHECK:       for.body.3:
; CHECK-NEXT:    [[INC_3]] = add nuw nsw i64 [[INC_2]], 1
; CHECK-NEXT:    br i1 false, label [[FOR_BODY_FOR_BODY_CRIT_EDGE_3]], label [[FOR_END]]
; CHECK:       for.body.for.body_crit_edge.3:
; CHECK-NEXT:    [[ARRAYIDX_PHI_TRANS_INSERT_3:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INC_3]]
; CHECK-NEXT:    [[DOTPRE_3]] = load i32, i32* [[ARRAYIDX_PHI_TRANS_INSERT_3]], align 4
; CHECK-NEXT:    br label [[FOR_HEADER]], !llvm.loop !2
;
entry:
  %0 = load i32, i32* %A, align 4
  call void @bar(i32 %0)
  br label %for.header

for.header:
  %1 = phi i32 [ %0, %entry ], [ %.pre, %for.body.for.body_crit_edge ]
  %i = phi i64 [ 0, %entry ], [ %inc, %for.body.for.body_crit_edge ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %i
  call void @bar(i32 %1)
  br i1 %cond, label %for.body, label %for.end

for.body:
  %inc = add nsw i64 %i, 1
  %cmp = icmp slt i64 %inc, 4
  br i1 %cmp, label %for.body.for.body_crit_edge, label %for.end

for.body.for.body_crit_edge:
  %arrayidx.phi.trans.insert = getelementptr inbounds i32, i32* %A, i64 %inc
  %.pre = load i32, i32* %arrayidx.phi.trans.insert, align 4
  br label %for.header

for.end:
  ret void
}

declare void @bar(i32)
declare i1 @foo(i64)
