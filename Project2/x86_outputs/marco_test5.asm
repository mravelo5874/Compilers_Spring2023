%include "io.inc" ; expected result: 1

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

my_try_and:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 1
	push dword -1
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp+8]
	push dword [ebp+12]
	pop dword ebx
	cmp ebx, 0
	jne and_label_a0
	jmp and_label_b0
and_label_a0:
	mov dword ebx, 1
	jmp and_label_b0
and_label_b0:
	pop dword eax
	cmp eax, 0
	jne and_label_c0
	jmp and_label_d0
and_label_c0:
	mov dword eax, 1
	jmp and_label_d0
and_label_d0:
	cmp eax, ebx
	je and_label_e0
	push dword 0
	jmp and_label_f0
and_label_e0:
	push dword 1
	jmp and_label_f0
and_label_f0:
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_try_and_end
my_try_and_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_try_or:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 1
	push dword -1
	pop dword ebx
	pop dword eax
	imul eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp+8]
	push dword [ebp+12]
	pop dword ebx
	cmp ebx, 0
	jne or_label_a0
	jmp or_label_b0
or_label_a0:
	mov dword ebx, 1
	jmp or_label_b0
or_label_b0:
	pop dword eax
	cmp eax, 0
	jne or_label_c0
	jmp or_label_d0
or_label_c0:
	mov dword eax, 1
	jmp or_label_d0
or_label_d0:
	add eax, ebx
	cmp eax, 0
	jg or_label_e0
	push dword 0
	jmp or_label_f0
or_label_e0:
	push dword 1
	jmp or_label_f0
or_label_f0:
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp-4]
	jmp my_try_or_end
my_try_or_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

my_main:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 0
	push dword 0
	push dword 2
	push dword 4
	call my_try_and
	mov dword [ebp-12], eax
	pop dword ecx
	pop dword ecx
	pop dword eax
	mov dword [ebp-4], eax
	push dword 0
	push dword 1
	push dword 3
	call my_try_or
	mov dword [ebp-12], eax
	pop dword ecx
	pop dword ecx
	pop dword eax
	mov dword [ebp-8], eax
	push dword 0
	push dword [ebp-4]
	push dword [ebp-8]
	call my_try_or
	mov dword [ebp-12], eax
	pop dword ecx
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop dword ecx
	pop dword ecx
	pop ebp
	ret

