%include "io.inc" ; expected result: 34

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
	push dword 9
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword [ebp-4]
	call my_calc_fib_num
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

my_calc_fib_num:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 0
	push dword 0
	push dword 0
	pop dword eax
	mov dword [ebp-8], eax
	push dword 0
	pop dword eax
	mov dword [ebp-12], eax
	push dword [ebp+8]
	push dword 2
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jl my_auto_label_32
	push dword 0
	push dword [ebp+8]
	push dword 1
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	call my_calc_fib_num
	mov dword [ebp-16], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-8], eax
	push dword 0
	push dword [ebp+8]
	push dword 2
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	call my_calc_fib_num
	mov dword [ebp-16], eax
	pop dword ecx
	pop dword eax
	mov dword [ebp-12], eax
	push dword [ebp-8]
	push dword [ebp-12]
	pop dword ebx
	pop dword eax
	add eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_33
my_auto_label_32:
	push dword [ebp+8]
	pop dword eax
	mov dword [ebp-4], eax
my_auto_label_33:
my_auto_break_16:
	push dword [ebp-4]
	jmp my_calc_fib_num_end
my_calc_fib_num_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

