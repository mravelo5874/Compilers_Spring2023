%include "io.inc" ; expected result: 1601

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
	push dword 40
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword [ebp-4]
	call my_eulers
	mov dword [ebp-12], eax
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

my_eulers:
	push ebp
	mov ebp, esp

	push dword 0
	push dword [ebp+8]
	push dword [ebp+8]
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	push dword [ebp+8]
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	push dword 41
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_eulers_end
my_eulers_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

