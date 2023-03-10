; RUN: llc -mtriple=x86_64-linux-android < %s | FileCheck -check-prefix=CHECK-X86-64 %s 
; RUN: llc -mtriple=i686-linux-android < %s | FileCheck -check-prefix=CHECK-X86-32 %s 

define i32 @foo(i32 %n) local_unnamed_addr #0 {
  %a = alloca i32, i32 %n, align 16
  %b = getelementptr inbounds i32, i32* %a, i64 1198
  store volatile i32 1, i32* %b
  %c = load volatile i32, i32* %a
  ret i32 %c
}

attributes #0 =  {"probe-stack"="inline-asm"}

; CHECK-X86-64-LABEL: foo:
; CHECK-X86-64:       # %bb.0:
; CHECK-X86-64-NEXT:  	pushq	%rbp
; CHECK-X86-64-NEXT:  	.cfi_def_cfa_offset 16
; CHECK-X86-64-NEXT:  	.cfi_offset %rbp, -16
; CHECK-X86-64-NEXT:  	movq	%rsp, %rbp
; CHECK-X86-64-NEXT:  	.cfi_def_cfa_register %rbp
; CHECK-X86-64-NEXT:  	movq    %rsp, %rax
; CHECK-X86-64-NEXT:    movl    %edi, %ecx
; CHECK-X86-64-NEXT:  	leaq 15(,%rcx,4), %rcx
; CHECK-X86-64-NEXT:  	andq	$-16, %rcx
; CHECK-X86-64-NEXT:  	subq	%rcx, %rax
; CHECK-X86-64-NEXT:  	cmpq	%rsp, %rax
; CHECK-X86-64-NEXT:  	jl	.LBB0_3
; CHECK-X86-64-NEXT:  .LBB0_2: # =>This Inner Loop Header: Depth=1
; CHECK-X86-64-NEXT:  	movq	$0, (%rsp)
; CHECK-X86-64-NEXT:  	subq	$4096, %rsp # imm = 0x1000
; CHECK-X86-64-NEXT:  	cmpq	%rsp, %rax
; CHECK-X86-64-NEXT:  	jge	.LBB0_2
; CHECK-X86-64-NEXT:  .LBB0_3:
; CHECK-X86-64-NEXT:  	movq	%rax, %rsp
; CHECK-X86-64-NEXT:  	movl	$1, 4792(%rax)
; CHECK-X86-64-NEXT:  	movl	(%rax), %eax
; CHECK-X86-64-NEXT:  	movq	%rbp, %rsp
; CHECK-X86-64-NEXT:  	popq	%rbp
; CHECK-X86-64-NEXT:  .cfi_def_cfa %rsp, 8
; CHECK-X86-64-NEXT:   retq


; CHECK-X86-32-LABEL: foo:
; CHECK-X86-32:       # %bb.0:
; CHECK-X86-32-NEXT:    pushl   %ebp
; CHECK-X86-32-NEXT:    .cfi_def_cfa_offset 8
; CHECK-X86-32-NEXT:    .cfi_offset %ebp, -8
; CHECK-X86-32-NEXT:    movl    %esp, %ebp
; CHECK-X86-32-NEXT:    .cfi_def_cfa_register %ebp
; CHECK-X86-32-NEXT:    subl    $8, %esp
; CHECK-X86-32-NEXT:    movl    8(%ebp), %ecx
; CHECK-X86-32-NEXT:    movl    %esp, %eax
; CHECK-X86-32-NEXT:    leal    15(,%ecx,4), %ecx
; CHECK-X86-32-NEXT:    andl    $-16, %ecx
; CHECK-X86-32-NEXT:    subl    %ecx, %eax
; CHECK-X86-32-NEXT:    cmpl    %esp, %eax
; CHECK-X86-32-NEXT:    jl  .LBB0_3
; CHECK-X86-32-NEXT:  .LBB0_2: # =>This Inner Loop Header: Depth=1
; CHECK-X86-32-NEXT:    movl    $0, (%esp)
; CHECK-X86-32-NEXT:    subl    $4096, %esp # imm = 0x1000
; CHECK-X86-32-NEXT:    cmpl    %esp, %eax
; CHECK-X86-32-NEXT:    jge .LBB0_2
; CHECK-X86-32-NEXT:  .LBB0_3:
; CHECK-X86-32-NEXT:    movl    %eax, %esp
; CHECK-X86-32-NEXT:    movl    $1, 4792(%eax)
; CHECK-X86-32-NEXT:    movl    (%eax), %eax
; CHECK-X86-32-NEXT:    movl    %ebp, %esp
; CHECK-X86-32-NEXT:    popl    %ebp
; CHECK-X86-32-NEXT:    .cfi_def_cfa %esp, 4
; CHECK-X86-32-NEXT:    retl

