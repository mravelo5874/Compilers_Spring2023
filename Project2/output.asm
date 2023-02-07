%include "io.inc"

section .data
	res db 'result: ', 0
	eax_v db 'eax val: ', 0
	ebx_v db 'ebx val: ', 0
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

	PRINT_STRING m_start
	NEWLINE


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	push ebp
	mov ebp, esp


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	mov dword ebx, 7
	push ebx

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	call simple

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	jmp main_end

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

main_end:

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE


	PRINT_STRING m_end
	NEWLINE

	pop ebp
	ret

simple:

	PRINT_STRING m_start
	NEWLINE


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	push ebp
	mov ebp, esp


	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	mov dword ebx, [ebp+8]
	push ebx

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	mov dword ebx, 1
	push ebx

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	pop ebx
	add eax, ebx

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

	jmp simple_end

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE

simple_end:

	PRINT_STRING eax_v
	PRINT_DEC 4, eax
	NEWLINE


	PRINT_STRING ebx_v
	PRINT_DEC 4, ebx
	NEWLINE


	PRINT_STRING stack
	pop ebx
	PRINT_DEC 4, ebx
	push ebx
	NEWLINE


	PRINT_STRING m_end
	NEWLINE

	pop ebp
	ret

