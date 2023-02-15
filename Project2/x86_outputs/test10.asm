%include "io.inc" ; expected result: 1597

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
	push dword 17
	call my_fibo
	mov dword [ebp-8], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_fibo:
	push ebp
	mov ebp, esp

	push dword 0
	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_16
	push dword [ebp+8]
	push dword 2
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_18
	push dword 0
	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	call my_fibo
	mov dword [ebp-8], eax
	pop dword ecx
	push dword 0
	push dword [ebp+8]
	push dword 2
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	call my_fibo
	mov dword [ebp-8], eax
	pop dword ecx
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_19
my_auto_label_18:
	push dword 1
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_19:
my_auto_break_9:
	jmp my_auto_label_17
my_auto_label_16:
	push dword 1
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_17:
my_auto_break_8:
	push dword [ebp-4]
	jmp my_fibo_end
my_fibo_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

