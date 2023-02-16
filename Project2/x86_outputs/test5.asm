%include "io.inc" ; expected result: 90

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
	push dword 10
	push dword 20
	call my_foo
	mov dword [esp+8], eax
	pop dword ecx
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

my_foo:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 0
	push dword [ebp+8]
	call my_bar
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
	jmp my_foo_end
my_foo_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_bar:
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
	jmp my_bar_end
my_bar_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

