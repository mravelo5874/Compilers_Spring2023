%include "io.inc"

section .text
	global CMAIN
CMAIN:
	push ebp
	mov ebp, esp
	call main
	add esp, 4
	PRINT_DEC 4, eax
	NEWLINE
	pop ebp
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
	call addthemnums
	mov ebp, esp
	mov dword [ebp-12], eax
	mov dword eax, [ebp-12]
	push eax
	jmp main_end
main_end:
	mov eax, 1
	pop ebp
	ret

addThemNums:
	mov dword [ebp-4], 0
	mov dword eax, [ebp+8]
	push eax
	mov dword eax, [ebp+12]
	push eax
	pop eax
	pop ebx
	add eax, ebx
	push eax
	mov dword [ebp-4], eax
	mov dword eax, [ebp-4]
	push eax
	jmp addthemnums_end
addThemNums_end:
	mov eax, 1
	pop ebp
	ret

