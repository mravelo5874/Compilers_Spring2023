%include "io.inc" ; expected result: not provided

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

my_foo:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 0
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_0
my_auto_label_1:
	push dword [ebp+8]
	push dword 10
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp+8], eax
	jmp my_auto_break_0
my_auto_label_0:
	push dword [ebp+8]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jg my_auto_label_1
my_auto_break_0:
	push dword [ebp-4]
	jmp my_foo_end
my_foo_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_main:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 5
	call my_foo
	mov dword [esp+4], eax
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

