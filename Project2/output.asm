%include "io.inc"

section .text
	global CMAIN
CMAIN:
	push ebp;
	mov ebp, esp;
	call main
	add esp, 4;
	PRINT_DEC 4, eax
	NEWLINE
	pop ebp;
	ret

main:
	mov dword [ebp-4], 0
	mov dword [ebp-8], 0
	mov dword [ebp-12], 0
	mov dword eax, 3
	push eax
	mov dword [ebp-4], eax
	mov dword eax, 4
	push eax
	mov dword [ebp-8], eax
	mov dword eax, 0
	push eax
	mov dword eax, [ebp-4]
	push eax
	mov dword eax, [ebp-8]
	push eax
	push ebp
	call addThemNums
	mov ebp, esp
	mov dword [ebp-12], eax
	mov dword eax, [ebp-12]
	push eax
	jump main_END
	pop ebp
	ret
main_end:
	mov eax, 1	pop ebp
	ret

addThemNums:
	mov dword [ebp-4], 0
	mov dword eax, [ebp8]
	push eax
	mov dword eax, [ebp12]
	push eax
	pop eax
	pop ebx
	add eax, ebx
	push eax
	mov dword [ebp-4], eax
	mov dword eax, [ebp-4]
	push eax
	jump addThemNums_END
	pop ebp
	ret
addThemNums_end:
	mov eax, 1	pop ebp
	ret

