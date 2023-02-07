%include "io.inc"

section .data
	res db 'result: ', 0
	eax_v db 'eax val: ', 0
	ebp_v db 'ebp val: ', 0
	esp_v db 'esp val: ', 0
	m_start db 'start method', 0
	m_end db 'end method', 0
	stack db 'stack: ', 0
section .text
	global CMAIN
CMAIN:
	push ebp
	mov ebp, esp

	call main
	PRINT_STRING res
	PRINT_DEC 4, eax
	NEWLINE

	pop ebp
	ret

main:
	push ebp
	mov ebp, esp

	mov dword eax, 2
	push eax
	call simple
	jmp main_end
        push eax
main_end:
	pop eax
	pop ebp
	ret

simple:
	push ebp
	mov ebp, esp

	mov dword eax, [ebp+8]
	push eax
	mov dword eax, 2
	push eax
	pop eax
	pop ebx
	imul eax, ebx
	push eax
	jmp simple_end
simple_end:
	pop eax
	pop ebp
	ret

