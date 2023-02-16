%include "io.inc" ; expected result: 7

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
	push dword 3
	pop dword eax
	mov dword [ebp-4], eax
	push dword 4
	pop dword eax
	mov dword [ebp-8], eax
	push dword 0
	push dword [ebp-4]
	push dword [ebp-8]
	call my_addthemnums
	mov dword [esp+8], eax
	pop dword ecx
	pop dword ecx
	pop dword eax
	mov dword [ebp-12], eax
	push dword [ebp-12]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

my_addthemnums:
	push ebp
	mov ebp, esp

	push dword 0
	push dword [ebp+8]
	push dword [ebp+12]
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_addthemnums_end
my_addthemnums_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

