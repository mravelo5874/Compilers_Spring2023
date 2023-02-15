%include "io.inc" ; expected result: 431

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
	push dword 0
	push dword 431
	pop dword eax
	mov dword [ebp-4], eax
	push dword 123
	pop dword eax
	mov dword [ebp-8], eax
	push dword 345
	pop dword eax
	mov dword [ebp-12], eax
	jmp my_auto_label_10
my_auto_label_11:
	jmp my_auto_label_12
my_auto_label_13:
	push dword [ebp-8]
	push dword 1
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-8], eax
my_auto_label_12:
	push dword [ebp-8]
	push dword [ebp-4]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_13
my_auto_break_6:
my_auto_label_10:
	push dword [ebp-8]
	push dword [ebp-12]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_11
my_auto_break_5:
	push dword [ebp-8]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

