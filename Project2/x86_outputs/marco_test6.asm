%include "io.inc" ; expected result: 65536

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
	push dword 0
	push dword 2
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword [ebp-4]
	call my_recursive
	mov dword [esp+4], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-8], eax
	push dword [ebp-8]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

my_recursive:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 777
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp+8]
	push dword 9999
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_30
	push dword [ebp+8]
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_31
my_auto_label_30:
	push dword 0
	push dword [ebp+8]
	push dword [ebp+8]
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	call my_recursive
	mov dword [esp+4], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_31:
my_auto_break_15:
	push dword [ebp-4]
	jmp my_recursive_end
my_recursive_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

