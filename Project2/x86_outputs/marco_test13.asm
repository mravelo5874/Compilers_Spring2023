%include "io.inc" ; expected result: 138

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
	push dword 9872934
	push dword 809784
	call my_gcd
	mov dword [ebp-4], eax
	pop dword ecx
	pop dword ecx
	jmp my_main_end
my_main_end:
	pop dword eax
	pop ebp
	ret

my_gcd:
	push ebp
	mov ebp, esp

	push dword 0
	push dword 0
	pop dword eax
	mov dword [ebp-4], eax
	push dword [ebp+8]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	je my_auto_label_36
	jmp my_auto_label_38
my_auto_label_39:
	push dword [ebp+8]
	push dword [ebp+12]
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	jg my_auto_label_40
	push dword [ebp+12]
	push dword [ebp+8]
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp+12], eax
	jmp my_auto_label_41
my_auto_label_40:
	push dword [ebp+8]
	push dword [ebp+12]
	pop dword ebx
	pop dword eax
	sub eax, ebx
	push dword eax
	pop dword eax
	mov dword [ebp+8], eax
my_auto_label_41:
my_auto_break_20:
my_auto_label_38:
	push dword [ebp+12]
	push dword 0
	pop dword ebx
	pop dword eax
	cmp eax, ebx
	pop dword eax
	cmp eax, 0
	je not_label_a1
	push dword 0
	jmp not_label_b1
not_label_a1:
	push dword 1
	jmp not_label_b1
not_label_b1:
	je my_auto_label_39
my_auto_break_19:
	push dword [ebp+8]
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_label_37
my_auto_label_36:
	push dword [ebp+12]
	pop dword eax
	mov dword [ebp-4], eax
	jmp my_auto_break_18
my_auto_label_37:
my_auto_break_18:
	push dword [ebp-4]
	jmp my_gcd_end
my_gcd_end:
	pop dword eax
	pop dword ecx
	pop ebp
	ret

