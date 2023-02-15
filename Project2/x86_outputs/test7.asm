%include "io.inc" ; expected result: 123

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
	push dword 0
	push dword 431
	pop dword eax
	mov dword [ebp-4], eax
	push dword 123
	pop dword eax
	mov dword [ebp-8], eax
	push dword 345
	pop dword eax
	mov dword [ebp-12], eax
	push dword [ebp-4]
	push dword [ebp-8]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_4
	push dword [ebp-8]
	push dword [ebp-12]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_8
	push dword [ebp-12]
	pop dword eax
	mov dword [ebp-16], eax
	jmp my_auto_label_9
my_auto_label_8:
	push dword [ebp-8]
	pop dword eax
	mov dword [ebp-16], eax
my_auto_label_9:
my_auto_break_4:
	jmp my_auto_label_5
my_auto_label_4:
	push dword [ebp-4]
	push dword [ebp-12]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_6
	push dword [ebp-12]
	pop dword eax
	mov dword [ebp-16], eax
	jmp my_auto_label_7
my_auto_label_6:
	push dword [ebp-4]
	pop dword eax
	mov dword [ebp-16], eax
my_auto_label_7:
my_auto_break_3:
my_auto_label_5:
my_auto_break_2:
	push dword [ebp-16]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

