%include "io.inc" ; expected result: 479001600

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
	push dword 12
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword [ebp-4]
	call my_factorial
	mov dword [esp+4], eax
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_factorial:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 1
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp+8]
	push dword 2
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_34
	push dword [ebp+8]
	push dword 0
	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	call my_factorial
	mov dword [esp+4], eax
	pop dword ecx
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_35
my_auto_label_34:
	push dword [ebp+8]
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_35:
my_auto_break_17:
	push dword [ebp-4]
	jmp my_factorial_end
my_factorial_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

