%include "io.inc" ; expected result: 120

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
	push dword 5
	call my_fact
	mov dword [esp+4], eax
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

my_fact:
	push ebp
	mov ebp, esp

	push dword 0
	push dword [ebp+8]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_14
	push dword [ebp+8]
	push dword 0
	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	call my_fact
	mov dword [esp+4], eax
	pop dword ecx
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_15
my_auto_label_14:
	push dword 1
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_15:
my_auto_break_7:
	push dword [ebp-4]
	jmp my_fact_end
my_fact_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

