%include "io.inc" ; expected result: 8

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
	push dword 7
	call my_simple
	mov dword [ebp-4], eax
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

my_simple:
	push ebp
	mov ebp, esp

	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	jmp my_simple_end
my_simple_end:
	pop dword eax
	pop ebp
	ret

