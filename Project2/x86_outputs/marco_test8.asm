%include "io.inc" ; expected result: 1

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
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	pop dword eax
	cmp eax, 0
	je not_label_a0
	push dword 0
	jmp not_label_b0
not_label_a0:
	push dword 1
	jmp not_label_b0
not_label_b0:
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

