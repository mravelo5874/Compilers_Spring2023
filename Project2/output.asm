%include "io.inc"

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

	mov dword eax, 7
	push eax
	call my_simple
	jmp my_main_end
my_main_end:
	pop ebp
	ret

my_simple:
	push ebp
	mov ebp, esp

	mov dword eax, [ebp+8]
	push eax
	mov dword eax, 1
	push eax
	pop eax
	pop ebx
	add eax, ebx
	push eax
	jmp my_simple_end
my_simple_end:
	pop eax
	pop ebp
	ret

