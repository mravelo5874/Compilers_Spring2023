%include "io.inc" ; expected result: 15

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
	push dword 0
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_20
my_auto_label_21:
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
	jmp my_auto_break_10
my_auto_label_20:
	push dword [ebp+8]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jg my_auto_label_21
my_auto_break_10:
	push dword [ebp-4]
	jmp my_method1_end
my_method1_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_main:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 5
	call my_method1
	mov dword [esp+4], eax
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

