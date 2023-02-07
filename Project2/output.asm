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

	mov dword eax, 3
	push eax
	pop eax
	mov dword [ebp-4], eax
	mov dword eax, 4
	push eax
	pop eax
	mov dword [ebp-8], eax
	mov dword eax, [ebp-4]
	push eax

        PRINT_STRING res
	PRINT_DEC 4, eax
	NEWLINE

	mov dword eax, [ebp-8]
	push eax

        PRINT_STRING res
	PRINT_DEC 4, eax
	NEWLINE
	call my_addthemnums
	pop ecx
	pop ecx
	pop eax
	mov dword [ebp-12], eax
	mov dword eax, [ebp-12]
	push eax
	jmp my_main_end
my_main_end:
	pop ebp
	ret

my_addthemnums:
	push ebp
	mov ebp, esp

	mov dword eax, [ebp+8]
	push eax
	mov dword eax, [ebp+12]
	push eax
	pop eax
	pop ebx
	add eax, ebx
	push eax
	pop eax
	mov dword [ebp-4], eax
	mov dword eax, [ebp-4]
	push eax
	jmp my_addthemnums_end
my_addthemnums_end:
	pop eax
	pop ebp
	ret

