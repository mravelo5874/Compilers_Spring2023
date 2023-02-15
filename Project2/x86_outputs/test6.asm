%include "io.inc" ; expected result: 30

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
	push dword 10
	pop dword eax
	mov dword [ebp-4], eax
	push dword 10
	push dword 20
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-8], eax
	jmp my_auto_label_2
my_auto_label_3:
	push dword [ebp-4]
	push dword 1
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_2:
	push dword [ebp-4]
	push dword [ebp-8]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_3
my_auto_break_1:
	push dword [ebp-4]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

