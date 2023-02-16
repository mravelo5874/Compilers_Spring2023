%include "io.inc" ; expected result: 71

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

my_method1:
	push ebp
	mov ebp, esp

	push dword 0
	push dword [ebp+8]
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_method1_end
my_method1_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_method2:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 0
	push dword [ebp+8]
	call my_method1
	mov dword [esp+4], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	push dword [ebp+12]
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_method2_end
my_method2_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_main:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 5
	push dword 6
	call my_method2
	mov dword [esp+8], eax
	pop dword ecx
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

