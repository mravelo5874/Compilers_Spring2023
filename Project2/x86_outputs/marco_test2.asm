%include "io.inc" ; expected result: 1066

section .data
	res db 'result: ', 0
section .text
	global CMAIN
CMAIN:
	push ebp
	mov ebp, esp

	call my_main
	PRINT_STRING res
	PRINT_DEC 4, eax
	NEWLINE

	pop ebp
	ret

my_main:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 2
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword [ebp-4]
	call my_super_while
	mov dword [esp+4], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_super_while:
	push ebp
	mov ebp, esp

	jmp my_auto_label_22
my_auto_label_23:
	push dword 0
	push dword [ebp+8]
	call my_triple
	mov dword [esp+4], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp+8], eax
	push dword 0
	push dword [ebp+8]
	call my_half
	mov dword [esp+4], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp+8], eax
my_auto_label_22:
	push dword [ebp+8]
	push dword 999
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_23
my_auto_break_11:
	push dword [ebp+8]
	jmp my_super_while_end
my_super_while_end:
	pop dword eax
	pop ebp
	ret

my_triple:
	push ebp
	mov ebp, esp

	push dword [ebp+8]
	push dword 3
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	jmp my_triple_end
my_triple_end:
	pop dword eax
	pop ebp
	ret

my_half:
	push ebp
	mov ebp, esp

	push dword [ebp+8]
	push dword 2
	mov dword eax, [esp+4]
	cmp eax, 0
	jl idiv_neg_label_1
	mov dword edx, 0
	jmp idiv_op_1
idiv_neg_label_1:
	mov dword edx, -1
	jmp idiv_op_1
idiv_op_1:
	pop dword ebx
	pop dword eax
	idiv dword ebx
	push dword eax
	jmp my_half_end
my_half_end:
	pop dword eax
	pop ebp
	ret

