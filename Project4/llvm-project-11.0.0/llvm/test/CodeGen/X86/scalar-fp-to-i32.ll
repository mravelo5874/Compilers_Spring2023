; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=+avx512f,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X32,AVX512_32,AVX512_32_WIN,AVX512DQVL_32_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=+avx512f,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X32,AVX512_32,AVX512_32_LIN,AVX512DQVL_32_LIN
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc   -mattr=+avx512f,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X64,AVX512_64,AVX512_64_WIN,AVX512DQVL_64_WIN
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X32,AVX512_64,AVX512_64_LIN,AVX512DQVL_64_LIN
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=+avx512f,+avx512dq | FileCheck %s --check-prefixes=CHECK,X32,AVX512_32,AVX512_32_WIN,AVX512DQ_32_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=+avx512f,+avx512dq | FileCheck %s --check-prefixes=CHECK,X32,AVX512_32,AVX512_32_LIN,AVX512DQ_32_LIN
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc   -mattr=+avx512f,+avx512dq | FileCheck %s --check-prefixes=CHECK,X64,AVX512_64,AVX512_64_WIN,AVX512DQ_64_WIN
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f,+avx512dq | FileCheck %s --check-prefixes=CHECK,X32,AVX512_64,AVX512_64_LIN,AVX512DQ_64_LIN
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,X32,AVX512_32,AVX512_32_WIN,AVX512F_32_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,X32,AVX512_32,AVX512_32_LIN,AVX512F_32_LIN
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc   -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,X64,AVX512_64,AVX512_64_WIN,AVX512F_64_WIN
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,X32,AVX512_64,AVX512_64_LIN,AVX512F_64_LIN
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=+sse3 | FileCheck %s --check-prefixes=CHECK,X32,SSE3_32,SSE3_32_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=+sse3 | FileCheck %s --check-prefixes=CHECK,X32,SSE3_32,SSE3_32_LIN
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc   -mattr=+sse3 | FileCheck %s --check-prefixes=CHECK,X64,SSE3_64,SSE3_64_WIN
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+sse3 | FileCheck %s --check-prefixes=CHECK,X64,SSE3_64,SSE3_64_LIN
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X32,SSE2_32,SSE2_32_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X32,SSE2_32,SSE2_32_LIN
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc   -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X64,SSE2_64,SSE2_64_WIN
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X64,SSE2_64,SSE2_64_LIN
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=+sse | FileCheck %s --check-prefixes=CHECK,X32,SSE_32,SSE_32_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=+sse | FileCheck %s --check-prefixes=CHECK,X32,SSE_32,SSE_32_LIN
; RUN: llc < %s -mtriple=i386-pc-windows-msvc     -mattr=-sse  | FileCheck %s --check-prefixes=CHECK,X32,X87,X87_WIN
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu   -mattr=-sse  | FileCheck %s --check-prefixes=CHECK,X32,X87,X87_LIN

; Check that scalar FP conversions to signed and unsigned int32 are using
; reasonable sequences, across platforms and target switches.

define i32 @f_to_u32(float %a) nounwind {
; AVX512_32-LABEL: f_to_u32:
; AVX512_32:       # %bb.0:
; AVX512_32-NEXT:    vcvttss2usi {{[0-9]+}}(%esp), %eax
; AVX512_32-NEXT:    retl
;
; AVX512_64-LABEL: f_to_u32:
; AVX512_64:       # %bb.0:
; AVX512_64-NEXT:    vcvttss2usi %xmm0, %eax
; AVX512_64-NEXT:    retq
;
; SSE3_32_WIN-LABEL: f_to_u32:
; SSE3_32_WIN:       # %bb.0:
; SSE3_32_WIN-NEXT:    pushl %ebp
; SSE3_32_WIN-NEXT:    movl %esp, %ebp
; SSE3_32_WIN-NEXT:    andl $-8, %esp
; SSE3_32_WIN-NEXT:    subl $8, %esp
; SSE3_32_WIN-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE3_32_WIN-NEXT:    movss %xmm0, (%esp)
; SSE3_32_WIN-NEXT:    flds (%esp)
; SSE3_32_WIN-NEXT:    fisttpll (%esp)
; SSE3_32_WIN-NEXT:    movl (%esp), %eax
; SSE3_32_WIN-NEXT:    movl %ebp, %esp
; SSE3_32_WIN-NEXT:    popl %ebp
; SSE3_32_WIN-NEXT:    retl
;
; SSE3_32_LIN-LABEL: f_to_u32:
; SSE3_32_LIN:       # %bb.0:
; SSE3_32_LIN-NEXT:    subl $12, %esp
; SSE3_32_LIN-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE3_32_LIN-NEXT:    movss %xmm0, (%esp)
; SSE3_32_LIN-NEXT:    flds (%esp)
; SSE3_32_LIN-NEXT:    fisttpll (%esp)
; SSE3_32_LIN-NEXT:    movl (%esp), %eax
; SSE3_32_LIN-NEXT:    addl $12, %esp
; SSE3_32_LIN-NEXT:    retl
;
; SSE3_64-LABEL: f_to_u32:
; SSE3_64:       # %bb.0:
; SSE3_64-NEXT:    cvttss2si %xmm0, %rax
; SSE3_64-NEXT:    # kill: def $eax killed $eax killed $rax
; SSE3_64-NEXT:    retq
;
; SSE2_32-LABEL: f_to_u32:
; SSE2_32:       # %bb.0:
; SSE2_32-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE2_32-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSE2_32-NEXT:    movaps %xmm0, %xmm2
; SSE2_32-NEXT:    subss %xmm1, %xmm2
; SSE2_32-NEXT:    cvttss2si %xmm2, %ecx
; SSE2_32-NEXT:    xorl $-2147483648, %ecx # imm = 0x80000000
; SSE2_32-NEXT:    cvttss2si %xmm0, %eax
; SSE2_32-NEXT:    ucomiss %xmm0, %xmm1
; SSE2_32-NEXT:    cmovbel %ecx, %eax
; SSE2_32-NEXT:    retl
;
; SSE2_64-LABEL: f_to_u32:
; SSE2_64:       # %bb.0:
; SSE2_64-NEXT:    cvttss2si %xmm0, %rax
; SSE2_64-NEXT:    # kill: def $eax killed $eax killed $rax
; SSE2_64-NEXT:    retq
;
; SSE_32-LABEL: f_to_u32:
; SSE_32:       # %bb.0:
; SSE_32-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE_32-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSE_32-NEXT:    movaps %xmm0, %xmm2
; SSE_32-NEXT:    subss %xmm1, %xmm2
; SSE_32-NEXT:    cvttss2si %xmm2, %ecx
; SSE_32-NEXT:    xorl $-2147483648, %ecx # imm = 0x80000000
; SSE_32-NEXT:    cvttss2si %xmm0, %eax
; SSE_32-NEXT:    ucomiss %xmm0, %xmm1
; SSE_32-NEXT:    cmovbel %ecx, %eax
; SSE_32-NEXT:    retl
;
; X87_WIN-LABEL: f_to_u32:
; X87_WIN:       # %bb.0:
; X87_WIN-NEXT:    pushl %ebp
; X87_WIN-NEXT:    movl %esp, %ebp
; X87_WIN-NEXT:    andl $-8, %esp
; X87_WIN-NEXT:    subl $16, %esp
; X87_WIN-NEXT:    flds 8(%ebp)
; X87_WIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X87_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; X87_WIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87_WIN-NEXT:    movl %ebp, %esp
; X87_WIN-NEXT:    popl %ebp
; X87_WIN-NEXT:    retl
;
; X87_LIN-LABEL: f_to_u32:
; X87_LIN:       # %bb.0:
; X87_LIN-NEXT:    subl $20, %esp
; X87_LIN-NEXT:    flds {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X87_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; X87_LIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87_LIN-NEXT:    addl $20, %esp
; X87_LIN-NEXT:    retl
  %r = fptoui float %a to i32
  ret i32 %r
}

define i32 @f_to_s32(float %a) nounwind {
; AVX512_32-LABEL: f_to_s32:
; AVX512_32:       # %bb.0:
; AVX512_32-NEXT:    vcvttss2si {{[0-9]+}}(%esp), %eax
; AVX512_32-NEXT:    retl
;
; AVX512_64-LABEL: f_to_s32:
; AVX512_64:       # %bb.0:
; AVX512_64-NEXT:    vcvttss2si %xmm0, %eax
; AVX512_64-NEXT:    retq
;
; SSE3_32-LABEL: f_to_s32:
; SSE3_32:       # %bb.0:
; SSE3_32-NEXT:    cvttss2si {{[0-9]+}}(%esp), %eax
; SSE3_32-NEXT:    retl
;
; SSE3_64-LABEL: f_to_s32:
; SSE3_64:       # %bb.0:
; SSE3_64-NEXT:    cvttss2si %xmm0, %eax
; SSE3_64-NEXT:    retq
;
; SSE2_32-LABEL: f_to_s32:
; SSE2_32:       # %bb.0:
; SSE2_32-NEXT:    cvttss2si {{[0-9]+}}(%esp), %eax
; SSE2_32-NEXT:    retl
;
; SSE2_64-LABEL: f_to_s32:
; SSE2_64:       # %bb.0:
; SSE2_64-NEXT:    cvttss2si %xmm0, %eax
; SSE2_64-NEXT:    retq
;
; SSE_32-LABEL: f_to_s32:
; SSE_32:       # %bb.0:
; SSE_32-NEXT:    cvttss2si {{[0-9]+}}(%esp), %eax
; SSE_32-NEXT:    retl
;
; X87-LABEL: f_to_s32:
; X87:       # %bb.0:
; X87-NEXT:    subl $8, %esp
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fnstcw (%esp)
; X87-NEXT:    movzwl (%esp), %eax
; X87-NEXT:    orl $3072, %eax # imm = 0xC00
; X87-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87-NEXT:    fistpl {{[0-9]+}}(%esp)
; X87-NEXT:    fldcw (%esp)
; X87-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87-NEXT:    addl $8, %esp
; X87-NEXT:    retl
  %r = fptosi float %a to i32
  ret i32 %r
}

define i32 @d_to_u32(double %a) nounwind {
; AVX512_32-LABEL: d_to_u32:
; AVX512_32:       # %bb.0:
; AVX512_32-NEXT:    vcvttsd2usi {{[0-9]+}}(%esp), %eax
; AVX512_32-NEXT:    retl
;
; AVX512_64-LABEL: d_to_u32:
; AVX512_64:       # %bb.0:
; AVX512_64-NEXT:    vcvttsd2usi %xmm0, %eax
; AVX512_64-NEXT:    retq
;
; SSE3_32_WIN-LABEL: d_to_u32:
; SSE3_32_WIN:       # %bb.0:
; SSE3_32_WIN-NEXT:    pushl %ebp
; SSE3_32_WIN-NEXT:    movl %esp, %ebp
; SSE3_32_WIN-NEXT:    andl $-8, %esp
; SSE3_32_WIN-NEXT:    subl $8, %esp
; SSE3_32_WIN-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE3_32_WIN-NEXT:    movsd %xmm0, (%esp)
; SSE3_32_WIN-NEXT:    fldl (%esp)
; SSE3_32_WIN-NEXT:    fisttpll (%esp)
; SSE3_32_WIN-NEXT:    movl (%esp), %eax
; SSE3_32_WIN-NEXT:    movl %ebp, %esp
; SSE3_32_WIN-NEXT:    popl %ebp
; SSE3_32_WIN-NEXT:    retl
;
; SSE3_32_LIN-LABEL: d_to_u32:
; SSE3_32_LIN:       # %bb.0:
; SSE3_32_LIN-NEXT:    subl $12, %esp
; SSE3_32_LIN-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE3_32_LIN-NEXT:    movsd %xmm0, (%esp)
; SSE3_32_LIN-NEXT:    fldl (%esp)
; SSE3_32_LIN-NEXT:    fisttpll (%esp)
; SSE3_32_LIN-NEXT:    movl (%esp), %eax
; SSE3_32_LIN-NEXT:    addl $12, %esp
; SSE3_32_LIN-NEXT:    retl
;
; SSE3_64-LABEL: d_to_u32:
; SSE3_64:       # %bb.0:
; SSE3_64-NEXT:    cvttsd2si %xmm0, %rax
; SSE3_64-NEXT:    # kill: def $eax killed $eax killed $rax
; SSE3_64-NEXT:    retq
;
; SSE2_32-LABEL: d_to_u32:
; SSE2_32:       # %bb.0:
; SSE2_32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE2_32-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSE2_32-NEXT:    movapd %xmm0, %xmm2
; SSE2_32-NEXT:    subsd %xmm1, %xmm2
; SSE2_32-NEXT:    cvttsd2si %xmm2, %ecx
; SSE2_32-NEXT:    xorl $-2147483648, %ecx # imm = 0x80000000
; SSE2_32-NEXT:    cvttsd2si %xmm0, %eax
; SSE2_32-NEXT:    ucomisd %xmm0, %xmm1
; SSE2_32-NEXT:    cmovbel %ecx, %eax
; SSE2_32-NEXT:    retl
;
; SSE2_64-LABEL: d_to_u32:
; SSE2_64:       # %bb.0:
; SSE2_64-NEXT:    cvttsd2si %xmm0, %rax
; SSE2_64-NEXT:    # kill: def $eax killed $eax killed $rax
; SSE2_64-NEXT:    retq
;
; SSE_32_WIN-LABEL: d_to_u32:
; SSE_32_WIN:       # %bb.0:
; SSE_32_WIN-NEXT:    pushl %ebp
; SSE_32_WIN-NEXT:    movl %esp, %ebp
; SSE_32_WIN-NEXT:    andl $-8, %esp
; SSE_32_WIN-NEXT:    subl $16, %esp
; SSE_32_WIN-NEXT:    fldl 8(%ebp)
; SSE_32_WIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; SSE_32_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE_32_WIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE_32_WIN-NEXT:    movl %ebp, %esp
; SSE_32_WIN-NEXT:    popl %ebp
; SSE_32_WIN-NEXT:    retl
;
; SSE_32_LIN-LABEL: d_to_u32:
; SSE_32_LIN:       # %bb.0:
; SSE_32_LIN-NEXT:    subl $20, %esp
; SSE_32_LIN-NEXT:    fldl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; SSE_32_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE_32_LIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE_32_LIN-NEXT:    addl $20, %esp
; SSE_32_LIN-NEXT:    retl
;
; X87_WIN-LABEL: d_to_u32:
; X87_WIN:       # %bb.0:
; X87_WIN-NEXT:    pushl %ebp
; X87_WIN-NEXT:    movl %esp, %ebp
; X87_WIN-NEXT:    andl $-8, %esp
; X87_WIN-NEXT:    subl $16, %esp
; X87_WIN-NEXT:    fldl 8(%ebp)
; X87_WIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X87_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; X87_WIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87_WIN-NEXT:    movl %ebp, %esp
; X87_WIN-NEXT:    popl %ebp
; X87_WIN-NEXT:    retl
;
; X87_LIN-LABEL: d_to_u32:
; X87_LIN:       # %bb.0:
; X87_LIN-NEXT:    subl $20, %esp
; X87_LIN-NEXT:    fldl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X87_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; X87_LIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87_LIN-NEXT:    addl $20, %esp
; X87_LIN-NEXT:    retl
  %r = fptoui double %a to i32
  ret i32 %r
}

define i32 @d_to_s32(double %a) nounwind {
; AVX512_32-LABEL: d_to_s32:
; AVX512_32:       # %bb.0:
; AVX512_32-NEXT:    vcvttsd2si {{[0-9]+}}(%esp), %eax
; AVX512_32-NEXT:    retl
;
; AVX512_64-LABEL: d_to_s32:
; AVX512_64:       # %bb.0:
; AVX512_64-NEXT:    vcvttsd2si %xmm0, %eax
; AVX512_64-NEXT:    retq
;
; SSE3_32-LABEL: d_to_s32:
; SSE3_32:       # %bb.0:
; SSE3_32-NEXT:    cvttsd2si {{[0-9]+}}(%esp), %eax
; SSE3_32-NEXT:    retl
;
; SSE3_64-LABEL: d_to_s32:
; SSE3_64:       # %bb.0:
; SSE3_64-NEXT:    cvttsd2si %xmm0, %eax
; SSE3_64-NEXT:    retq
;
; SSE2_32-LABEL: d_to_s32:
; SSE2_32:       # %bb.0:
; SSE2_32-NEXT:    cvttsd2si {{[0-9]+}}(%esp), %eax
; SSE2_32-NEXT:    retl
;
; SSE2_64-LABEL: d_to_s32:
; SSE2_64:       # %bb.0:
; SSE2_64-NEXT:    cvttsd2si %xmm0, %eax
; SSE2_64-NEXT:    retq
;
; SSE_32-LABEL: d_to_s32:
; SSE_32:       # %bb.0:
; SSE_32-NEXT:    subl $8, %esp
; SSE_32-NEXT:    fldl {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fnstcw (%esp)
; SSE_32-NEXT:    movzwl (%esp), %eax
; SSE_32-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE_32-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fistpl {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fldcw (%esp)
; SSE_32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE_32-NEXT:    addl $8, %esp
; SSE_32-NEXT:    retl
;
; X87-LABEL: d_to_s32:
; X87:       # %bb.0:
; X87-NEXT:    subl $8, %esp
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fnstcw (%esp)
; X87-NEXT:    movzwl (%esp), %eax
; X87-NEXT:    orl $3072, %eax # imm = 0xC00
; X87-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87-NEXT:    fistpl {{[0-9]+}}(%esp)
; X87-NEXT:    fldcw (%esp)
; X87-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87-NEXT:    addl $8, %esp
; X87-NEXT:    retl
  %r = fptosi double %a to i32
  ret i32 %r
}

define i32 @x_to_u32(x86_fp80 %a) nounwind {
; AVX512_32_WIN-LABEL: x_to_u32:
; AVX512_32_WIN:       # %bb.0:
; AVX512_32_WIN-NEXT:    pushl %ebp
; AVX512_32_WIN-NEXT:    movl %esp, %ebp
; AVX512_32_WIN-NEXT:    andl $-8, %esp
; AVX512_32_WIN-NEXT:    subl $8, %esp
; AVX512_32_WIN-NEXT:    fldt 8(%ebp)
; AVX512_32_WIN-NEXT:    fisttpll (%esp)
; AVX512_32_WIN-NEXT:    movl (%esp), %eax
; AVX512_32_WIN-NEXT:    movl %ebp, %esp
; AVX512_32_WIN-NEXT:    popl %ebp
; AVX512_32_WIN-NEXT:    retl
;
; AVX512_32_LIN-LABEL: x_to_u32:
; AVX512_32_LIN:       # %bb.0:
; AVX512_32_LIN-NEXT:    subl $12, %esp
; AVX512_32_LIN-NEXT:    fldt {{[0-9]+}}(%esp)
; AVX512_32_LIN-NEXT:    fisttpll (%esp)
; AVX512_32_LIN-NEXT:    movl (%esp), %eax
; AVX512_32_LIN-NEXT:    addl $12, %esp
; AVX512_32_LIN-NEXT:    retl
;
; AVX512_64_WIN-LABEL: x_to_u32:
; AVX512_64_WIN:       # %bb.0:
; AVX512_64_WIN-NEXT:    pushq %rax
; AVX512_64_WIN-NEXT:    fldt (%rcx)
; AVX512_64_WIN-NEXT:    fisttpll (%rsp)
; AVX512_64_WIN-NEXT:    movl (%rsp), %eax
; AVX512_64_WIN-NEXT:    popq %rcx
; AVX512_64_WIN-NEXT:    retq
;
; AVX512_64_LIN-LABEL: x_to_u32:
; AVX512_64_LIN:       # %bb.0:
; AVX512_64_LIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; AVX512_64_LIN-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; AVX512_64_LIN-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; AVX512_64_LIN-NEXT:    retq
;
; SSE3_32_WIN-LABEL: x_to_u32:
; SSE3_32_WIN:       # %bb.0:
; SSE3_32_WIN-NEXT:    pushl %ebp
; SSE3_32_WIN-NEXT:    movl %esp, %ebp
; SSE3_32_WIN-NEXT:    andl $-8, %esp
; SSE3_32_WIN-NEXT:    subl $8, %esp
; SSE3_32_WIN-NEXT:    fldt 8(%ebp)
; SSE3_32_WIN-NEXT:    fisttpll (%esp)
; SSE3_32_WIN-NEXT:    movl (%esp), %eax
; SSE3_32_WIN-NEXT:    movl %ebp, %esp
; SSE3_32_WIN-NEXT:    popl %ebp
; SSE3_32_WIN-NEXT:    retl
;
; SSE3_32_LIN-LABEL: x_to_u32:
; SSE3_32_LIN:       # %bb.0:
; SSE3_32_LIN-NEXT:    subl $12, %esp
; SSE3_32_LIN-NEXT:    fldt {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    fisttpll (%esp)
; SSE3_32_LIN-NEXT:    movl (%esp), %eax
; SSE3_32_LIN-NEXT:    addl $12, %esp
; SSE3_32_LIN-NEXT:    retl
;
; SSE3_64_WIN-LABEL: x_to_u32:
; SSE3_64_WIN:       # %bb.0:
; SSE3_64_WIN-NEXT:    pushq %rax
; SSE3_64_WIN-NEXT:    fldt (%rcx)
; SSE3_64_WIN-NEXT:    fisttpll (%rsp)
; SSE3_64_WIN-NEXT:    movl (%rsp), %eax
; SSE3_64_WIN-NEXT:    popq %rcx
; SSE3_64_WIN-NEXT:    retq
;
; SSE3_64_LIN-LABEL: x_to_u32:
; SSE3_64_LIN:       # %bb.0:
; SSE3_64_LIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; SSE3_64_LIN-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; SSE3_64_LIN-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; SSE3_64_LIN-NEXT:    retq
;
; SSE2_32_WIN-LABEL: x_to_u32:
; SSE2_32_WIN:       # %bb.0:
; SSE2_32_WIN-NEXT:    pushl %ebp
; SSE2_32_WIN-NEXT:    movl %esp, %ebp
; SSE2_32_WIN-NEXT:    andl $-8, %esp
; SSE2_32_WIN-NEXT:    subl $16, %esp
; SSE2_32_WIN-NEXT:    fldt 8(%ebp)
; SSE2_32_WIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; SSE2_32_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_32_WIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE2_32_WIN-NEXT:    movl %ebp, %esp
; SSE2_32_WIN-NEXT:    popl %ebp
; SSE2_32_WIN-NEXT:    retl
;
; SSE2_32_LIN-LABEL: x_to_u32:
; SSE2_32_LIN:       # %bb.0:
; SSE2_32_LIN-NEXT:    subl $20, %esp
; SSE2_32_LIN-NEXT:    fldt {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; SSE2_32_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_32_LIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE2_32_LIN-NEXT:    addl $20, %esp
; SSE2_32_LIN-NEXT:    retl
;
; SSE2_64_WIN-LABEL: x_to_u32:
; SSE2_64_WIN:       # %bb.0:
; SSE2_64_WIN-NEXT:    subq $16, %rsp
; SSE2_64_WIN-NEXT:    fldt (%rcx)
; SSE2_64_WIN-NEXT:    fnstcw {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    movzwl {{[0-9]+}}(%rsp), %eax
; SSE2_64_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_64_WIN-NEXT:    movw %ax, {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    fldcw {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    fistpll {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    fldcw {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    movl {{[0-9]+}}(%rsp), %eax
; SSE2_64_WIN-NEXT:    addq $16, %rsp
; SSE2_64_WIN-NEXT:    retq
;
; SSE2_64_LIN-LABEL: x_to_u32:
; SSE2_64_LIN:       # %bb.0:
; SSE2_64_LIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; SSE2_64_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_64_LIN-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; SSE2_64_LIN-NEXT:    retq
;
; SSE_32_WIN-LABEL: x_to_u32:
; SSE_32_WIN:       # %bb.0:
; SSE_32_WIN-NEXT:    pushl %ebp
; SSE_32_WIN-NEXT:    movl %esp, %ebp
; SSE_32_WIN-NEXT:    andl $-8, %esp
; SSE_32_WIN-NEXT:    subl $16, %esp
; SSE_32_WIN-NEXT:    fldt 8(%ebp)
; SSE_32_WIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; SSE_32_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE_32_WIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE_32_WIN-NEXT:    movl %ebp, %esp
; SSE_32_WIN-NEXT:    popl %ebp
; SSE_32_WIN-NEXT:    retl
;
; SSE_32_LIN-LABEL: x_to_u32:
; SSE_32_LIN:       # %bb.0:
; SSE_32_LIN-NEXT:    subl $20, %esp
; SSE_32_LIN-NEXT:    fldt {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; SSE_32_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE_32_LIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE_32_LIN-NEXT:    addl $20, %esp
; SSE_32_LIN-NEXT:    retl
;
; X87_WIN-LABEL: x_to_u32:
; X87_WIN:       # %bb.0:
; X87_WIN-NEXT:    pushl %ebp
; X87_WIN-NEXT:    movl %esp, %ebp
; X87_WIN-NEXT:    andl $-8, %esp
; X87_WIN-NEXT:    subl $16, %esp
; X87_WIN-NEXT:    fldt 8(%ebp)
; X87_WIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X87_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; X87_WIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87_WIN-NEXT:    movl %ebp, %esp
; X87_WIN-NEXT:    popl %ebp
; X87_WIN-NEXT:    retl
;
; X87_LIN-LABEL: x_to_u32:
; X87_LIN:       # %bb.0:
; X87_LIN-NEXT:    subl $20, %esp
; X87_LIN-NEXT:    fldt {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X87_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; X87_LIN-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fistpll {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87_LIN-NEXT:    addl $20, %esp
; X87_LIN-NEXT:    retl
  %r = fptoui x86_fp80 %a to i32
  ret i32 %r
}

define i32 @x_to_s32(x86_fp80 %a) nounwind {
; AVX512_32-LABEL: x_to_s32:
; AVX512_32:       # %bb.0:
; AVX512_32-NEXT:    pushl %eax
; AVX512_32-NEXT:    fldt {{[0-9]+}}(%esp)
; AVX512_32-NEXT:    fisttpl (%esp)
; AVX512_32-NEXT:    movl (%esp), %eax
; AVX512_32-NEXT:    popl %ecx
; AVX512_32-NEXT:    retl
;
; AVX512_64_WIN-LABEL: x_to_s32:
; AVX512_64_WIN:       # %bb.0:
; AVX512_64_WIN-NEXT:    pushq %rax
; AVX512_64_WIN-NEXT:    fldt (%rcx)
; AVX512_64_WIN-NEXT:    fisttpl {{[0-9]+}}(%rsp)
; AVX512_64_WIN-NEXT:    movl {{[0-9]+}}(%rsp), %eax
; AVX512_64_WIN-NEXT:    popq %rcx
; AVX512_64_WIN-NEXT:    retq
;
; AVX512_64_LIN-LABEL: x_to_s32:
; AVX512_64_LIN:       # %bb.0:
; AVX512_64_LIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; AVX512_64_LIN-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; AVX512_64_LIN-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; AVX512_64_LIN-NEXT:    retq
;
; SSE3_32-LABEL: x_to_s32:
; SSE3_32:       # %bb.0:
; SSE3_32-NEXT:    pushl %eax
; SSE3_32-NEXT:    fldt {{[0-9]+}}(%esp)
; SSE3_32-NEXT:    fisttpl (%esp)
; SSE3_32-NEXT:    movl (%esp), %eax
; SSE3_32-NEXT:    popl %ecx
; SSE3_32-NEXT:    retl
;
; SSE3_64_WIN-LABEL: x_to_s32:
; SSE3_64_WIN:       # %bb.0:
; SSE3_64_WIN-NEXT:    pushq %rax
; SSE3_64_WIN-NEXT:    fldt (%rcx)
; SSE3_64_WIN-NEXT:    fisttpl {{[0-9]+}}(%rsp)
; SSE3_64_WIN-NEXT:    movl {{[0-9]+}}(%rsp), %eax
; SSE3_64_WIN-NEXT:    popq %rcx
; SSE3_64_WIN-NEXT:    retq
;
; SSE3_64_LIN-LABEL: x_to_s32:
; SSE3_64_LIN:       # %bb.0:
; SSE3_64_LIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; SSE3_64_LIN-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; SSE3_64_LIN-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; SSE3_64_LIN-NEXT:    retq
;
; SSE2_32-LABEL: x_to_s32:
; SSE2_32:       # %bb.0:
; SSE2_32-NEXT:    subl $8, %esp
; SSE2_32-NEXT:    fldt {{[0-9]+}}(%esp)
; SSE2_32-NEXT:    fnstcw (%esp)
; SSE2_32-NEXT:    movzwl (%esp), %eax
; SSE2_32-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_32-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE2_32-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE2_32-NEXT:    fistpl {{[0-9]+}}(%esp)
; SSE2_32-NEXT:    fldcw (%esp)
; SSE2_32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE2_32-NEXT:    addl $8, %esp
; SSE2_32-NEXT:    retl
;
; SSE2_64_WIN-LABEL: x_to_s32:
; SSE2_64_WIN:       # %bb.0:
; SSE2_64_WIN-NEXT:    pushq %rax
; SSE2_64_WIN-NEXT:    fldt (%rcx)
; SSE2_64_WIN-NEXT:    fnstcw (%rsp)
; SSE2_64_WIN-NEXT:    movzwl (%rsp), %eax
; SSE2_64_WIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_64_WIN-NEXT:    movw %ax, {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    fldcw {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    fistpl {{[0-9]+}}(%rsp)
; SSE2_64_WIN-NEXT:    fldcw (%rsp)
; SSE2_64_WIN-NEXT:    movl {{[0-9]+}}(%rsp), %eax
; SSE2_64_WIN-NEXT:    popq %rcx
; SSE2_64_WIN-NEXT:    retq
;
; SSE2_64_LIN-LABEL: x_to_s32:
; SSE2_64_LIN:       # %bb.0:
; SSE2_64_LIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; SSE2_64_LIN-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE2_64_LIN-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE2_64_LIN-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; SSE2_64_LIN-NEXT:    retq
;
; SSE_32-LABEL: x_to_s32:
; SSE_32:       # %bb.0:
; SSE_32-NEXT:    subl $8, %esp
; SSE_32-NEXT:    fldt {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fnstcw (%esp)
; SSE_32-NEXT:    movzwl (%esp), %eax
; SSE_32-NEXT:    orl $3072, %eax # imm = 0xC00
; SSE_32-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fldcw {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fistpl {{[0-9]+}}(%esp)
; SSE_32-NEXT:    fldcw (%esp)
; SSE_32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; SSE_32-NEXT:    addl $8, %esp
; SSE_32-NEXT:    retl
;
; X87-LABEL: x_to_s32:
; X87:       # %bb.0:
; X87-NEXT:    subl $8, %esp
; X87-NEXT:    fldt {{[0-9]+}}(%esp)
; X87-NEXT:    fnstcw (%esp)
; X87-NEXT:    movzwl (%esp), %eax
; X87-NEXT:    orl $3072, %eax # imm = 0xC00
; X87-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X87-NEXT:    fldcw {{[0-9]+}}(%esp)
; X87-NEXT:    fistpl {{[0-9]+}}(%esp)
; X87-NEXT:    fldcw (%esp)
; X87-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X87-NEXT:    addl $8, %esp
; X87-NEXT:    retl
  %r = fptosi x86_fp80 %a to i32
  ret i32 %r
}

define i32 @t_to_u32(fp128 %a) nounwind {
; AVX512_32_WIN-LABEL: t_to_u32:
; AVX512_32_WIN:       # %bb.0:
; AVX512_32_WIN-NEXT:    subl $16, %esp
; AVX512_32_WIN-NEXT:    vmovups {{[0-9]+}}(%esp), %xmm0
; AVX512_32_WIN-NEXT:    vmovups %xmm0, (%esp)
; AVX512_32_WIN-NEXT:    calll ___fixunstfsi
; AVX512_32_WIN-NEXT:    addl $16, %esp
; AVX512_32_WIN-NEXT:    retl
;
; AVX512_32_LIN-LABEL: t_to_u32:
; AVX512_32_LIN:       # %bb.0:
; AVX512_32_LIN-NEXT:    subl $28, %esp
; AVX512_32_LIN-NEXT:    vmovaps {{[0-9]+}}(%esp), %xmm0
; AVX512_32_LIN-NEXT:    vmovups %xmm0, (%esp)
; AVX512_32_LIN-NEXT:    calll __fixunstfsi
; AVX512_32_LIN-NEXT:    addl $28, %esp
; AVX512_32_LIN-NEXT:    retl
;
; AVX512_64_WIN-LABEL: t_to_u32:
; AVX512_64_WIN:       # %bb.0:
; AVX512_64_WIN-NEXT:    subq $40, %rsp
; AVX512_64_WIN-NEXT:    callq __fixunstfsi
; AVX512_64_WIN-NEXT:    addq $40, %rsp
; AVX512_64_WIN-NEXT:    retq
;
; AVX512_64_LIN-LABEL: t_to_u32:
; AVX512_64_LIN:       # %bb.0:
; AVX512_64_LIN-NEXT:    pushq %rax
; AVX512_64_LIN-NEXT:    callq __fixunstfsi
; AVX512_64_LIN-NEXT:    popq %rcx
; AVX512_64_LIN-NEXT:    retq
;
; SSE3_32_WIN-LABEL: t_to_u32:
; SSE3_32_WIN:       # %bb.0:
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    calll ___fixunstfsi
; SSE3_32_WIN-NEXT:    addl $16, %esp
; SSE3_32_WIN-NEXT:    retl
;
; SSE3_32_LIN-LABEL: t_to_u32:
; SSE3_32_LIN:       # %bb.0:
; SSE3_32_LIN-NEXT:    subl $12, %esp
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    calll __fixunstfsi
; SSE3_32_LIN-NEXT:    addl $28, %esp
; SSE3_32_LIN-NEXT:    retl
;
; SSE3_64_WIN-LABEL: t_to_u32:
; SSE3_64_WIN:       # %bb.0:
; SSE3_64_WIN-NEXT:    subq $40, %rsp
; SSE3_64_WIN-NEXT:    callq __fixunstfsi
; SSE3_64_WIN-NEXT:    addq $40, %rsp
; SSE3_64_WIN-NEXT:    retq
;
; SSE3_64_LIN-LABEL: t_to_u32:
; SSE3_64_LIN:       # %bb.0:
; SSE3_64_LIN-NEXT:    pushq %rax
; SSE3_64_LIN-NEXT:    callq __fixunstfsi
; SSE3_64_LIN-NEXT:    popq %rcx
; SSE3_64_LIN-NEXT:    retq
;
; SSE2_32_WIN-LABEL: t_to_u32:
; SSE2_32_WIN:       # %bb.0:
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    calll ___fixunstfsi
; SSE2_32_WIN-NEXT:    addl $16, %esp
; SSE2_32_WIN-NEXT:    retl
;
; SSE2_32_LIN-LABEL: t_to_u32:
; SSE2_32_LIN:       # %bb.0:
; SSE2_32_LIN-NEXT:    subl $12, %esp
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    calll __fixunstfsi
; SSE2_32_LIN-NEXT:    addl $28, %esp
; SSE2_32_LIN-NEXT:    retl
;
; SSE2_64_WIN-LABEL: t_to_u32:
; SSE2_64_WIN:       # %bb.0:
; SSE2_64_WIN-NEXT:    subq $40, %rsp
; SSE2_64_WIN-NEXT:    callq __fixunstfsi
; SSE2_64_WIN-NEXT:    addq $40, %rsp
; SSE2_64_WIN-NEXT:    retq
;
; SSE2_64_LIN-LABEL: t_to_u32:
; SSE2_64_LIN:       # %bb.0:
; SSE2_64_LIN-NEXT:    pushq %rax
; SSE2_64_LIN-NEXT:    callq __fixunstfsi
; SSE2_64_LIN-NEXT:    popq %rcx
; SSE2_64_LIN-NEXT:    retq
;
; SSE_32_WIN-LABEL: t_to_u32:
; SSE_32_WIN:       # %bb.0:
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    calll ___fixunstfsi
; SSE_32_WIN-NEXT:    addl $16, %esp
; SSE_32_WIN-NEXT:    retl
;
; SSE_32_LIN-LABEL: t_to_u32:
; SSE_32_LIN:       # %bb.0:
; SSE_32_LIN-NEXT:    subl $12, %esp
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    calll __fixunstfsi
; SSE_32_LIN-NEXT:    addl $28, %esp
; SSE_32_LIN-NEXT:    retl
;
; X87_WIN-LABEL: t_to_u32:
; X87_WIN:       # %bb.0:
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    calll ___fixunstfsi
; X87_WIN-NEXT:    addl $16, %esp
; X87_WIN-NEXT:    retl
;
; X87_LIN-LABEL: t_to_u32:
; X87_LIN:       # %bb.0:
; X87_LIN-NEXT:    subl $12, %esp
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    calll __fixunstfsi
; X87_LIN-NEXT:    addl $28, %esp
; X87_LIN-NEXT:    retl
  %r = fptoui fp128 %a to i32
  ret i32 %r
}

define i32 @t_to_s32(fp128 %a) nounwind {
; AVX512_32_WIN-LABEL: t_to_s32:
; AVX512_32_WIN:       # %bb.0:
; AVX512_32_WIN-NEXT:    subl $16, %esp
; AVX512_32_WIN-NEXT:    vmovups {{[0-9]+}}(%esp), %xmm0
; AVX512_32_WIN-NEXT:    vmovups %xmm0, (%esp)
; AVX512_32_WIN-NEXT:    calll ___fixtfsi
; AVX512_32_WIN-NEXT:    addl $16, %esp
; AVX512_32_WIN-NEXT:    retl
;
; AVX512_32_LIN-LABEL: t_to_s32:
; AVX512_32_LIN:       # %bb.0:
; AVX512_32_LIN-NEXT:    subl $28, %esp
; AVX512_32_LIN-NEXT:    vmovaps {{[0-9]+}}(%esp), %xmm0
; AVX512_32_LIN-NEXT:    vmovups %xmm0, (%esp)
; AVX512_32_LIN-NEXT:    calll __fixtfsi
; AVX512_32_LIN-NEXT:    addl $28, %esp
; AVX512_32_LIN-NEXT:    retl
;
; AVX512_64_WIN-LABEL: t_to_s32:
; AVX512_64_WIN:       # %bb.0:
; AVX512_64_WIN-NEXT:    subq $40, %rsp
; AVX512_64_WIN-NEXT:    callq __fixtfsi
; AVX512_64_WIN-NEXT:    addq $40, %rsp
; AVX512_64_WIN-NEXT:    retq
;
; AVX512_64_LIN-LABEL: t_to_s32:
; AVX512_64_LIN:       # %bb.0:
; AVX512_64_LIN-NEXT:    pushq %rax
; AVX512_64_LIN-NEXT:    callq __fixtfsi
; AVX512_64_LIN-NEXT:    popq %rcx
; AVX512_64_LIN-NEXT:    retq
;
; SSE3_32_WIN-LABEL: t_to_s32:
; SSE3_32_WIN:       # %bb.0:
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_WIN-NEXT:    calll ___fixtfsi
; SSE3_32_WIN-NEXT:    addl $16, %esp
; SSE3_32_WIN-NEXT:    retl
;
; SSE3_32_LIN-LABEL: t_to_s32:
; SSE3_32_LIN:       # %bb.0:
; SSE3_32_LIN-NEXT:    subl $12, %esp
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE3_32_LIN-NEXT:    calll __fixtfsi
; SSE3_32_LIN-NEXT:    addl $28, %esp
; SSE3_32_LIN-NEXT:    retl
;
; SSE3_64_WIN-LABEL: t_to_s32:
; SSE3_64_WIN:       # %bb.0:
; SSE3_64_WIN-NEXT:    subq $40, %rsp
; SSE3_64_WIN-NEXT:    callq __fixtfsi
; SSE3_64_WIN-NEXT:    addq $40, %rsp
; SSE3_64_WIN-NEXT:    retq
;
; SSE3_64_LIN-LABEL: t_to_s32:
; SSE3_64_LIN:       # %bb.0:
; SSE3_64_LIN-NEXT:    pushq %rax
; SSE3_64_LIN-NEXT:    callq __fixtfsi
; SSE3_64_LIN-NEXT:    popq %rcx
; SSE3_64_LIN-NEXT:    retq
;
; SSE2_32_WIN-LABEL: t_to_s32:
; SSE2_32_WIN:       # %bb.0:
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_WIN-NEXT:    calll ___fixtfsi
; SSE2_32_WIN-NEXT:    addl $16, %esp
; SSE2_32_WIN-NEXT:    retl
;
; SSE2_32_LIN-LABEL: t_to_s32:
; SSE2_32_LIN:       # %bb.0:
; SSE2_32_LIN-NEXT:    subl $12, %esp
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE2_32_LIN-NEXT:    calll __fixtfsi
; SSE2_32_LIN-NEXT:    addl $28, %esp
; SSE2_32_LIN-NEXT:    retl
;
; SSE2_64_WIN-LABEL: t_to_s32:
; SSE2_64_WIN:       # %bb.0:
; SSE2_64_WIN-NEXT:    subq $40, %rsp
; SSE2_64_WIN-NEXT:    callq __fixtfsi
; SSE2_64_WIN-NEXT:    addq $40, %rsp
; SSE2_64_WIN-NEXT:    retq
;
; SSE2_64_LIN-LABEL: t_to_s32:
; SSE2_64_LIN:       # %bb.0:
; SSE2_64_LIN-NEXT:    pushq %rax
; SSE2_64_LIN-NEXT:    callq __fixtfsi
; SSE2_64_LIN-NEXT:    popq %rcx
; SSE2_64_LIN-NEXT:    retq
;
; SSE_32_WIN-LABEL: t_to_s32:
; SSE_32_WIN:       # %bb.0:
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_WIN-NEXT:    calll ___fixtfsi
; SSE_32_WIN-NEXT:    addl $16, %esp
; SSE_32_WIN-NEXT:    retl
;
; SSE_32_LIN-LABEL: t_to_s32:
; SSE_32_LIN:       # %bb.0:
; SSE_32_LIN-NEXT:    subl $12, %esp
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; SSE_32_LIN-NEXT:    calll __fixtfsi
; SSE_32_LIN-NEXT:    addl $28, %esp
; SSE_32_LIN-NEXT:    retl
;
; X87_WIN-LABEL: t_to_s32:
; X87_WIN:       # %bb.0:
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_WIN-NEXT:    calll ___fixtfsi
; X87_WIN-NEXT:    addl $16, %esp
; X87_WIN-NEXT:    retl
;
; X87_LIN-LABEL: t_to_s32:
; X87_LIN:       # %bb.0:
; X87_LIN-NEXT:    subl $12, %esp
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    pushl {{[0-9]+}}(%esp)
; X87_LIN-NEXT:    calll __fixtfsi
; X87_LIN-NEXT:    addl $28, %esp
; X87_LIN-NEXT:    retl
  %r = fptosi fp128 %a to i32
  ret i32 %r
}
