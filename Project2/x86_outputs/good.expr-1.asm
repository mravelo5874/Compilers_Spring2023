%include "io.inc" ; expected result: 5

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

my_method1:
	push ebp
	mov ebp, esp

	push dword 0
	push dword [ebp+8]
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	push dword 10
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	push dword 5
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	push dword 5
	mov dword eax, [esp+4]
	cmp eax, 0
	jl idiv_neg_label_0
	mov dword edx, 0
	jmp idiv_op_0
idiv_neg_label_0:
	mov dword edx, -1
	jmp idiv_op_0
idiv_op_0:
	pop dword ebx
	pop dword eax
	idiv dword ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_method1_end
my_method1_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_main:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 5
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword [ebp-4]
	call my_method1
	mov dword [ebp-8], eax
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

