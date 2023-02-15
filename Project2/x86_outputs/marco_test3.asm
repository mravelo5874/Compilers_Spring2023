%include "io.inc" ; expected result: 78

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
	push dword 1
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	push dword 1
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_24
	push dword 2
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_25
my_auto_label_24:
	push dword [ebp-4]
	push dword 1
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_25:
my_auto_break_12:
	push dword [ebp-4]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_26
	push dword 43
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_27
my_auto_label_26:
	push dword [ebp-4]
	push dword 99999
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_27:
my_auto_break_13:
	push dword [ebp-4]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_28
	push dword 1
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_29
my_auto_label_28:
	push dword 78
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_29:
my_auto_break_14:
	push dword [ebp-4]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

