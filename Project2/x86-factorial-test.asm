%include "io.inc"

section .data
    msg db 'Hello, world!', 0
    rec db 'Recursive call:n is ', 0
    ans db 'Answer is ', 0

section .text
    global CMAIN
CMAIN:
    push ebp; set up the frame base register
    mov ebp, esp; 
    
    PRINT_STRING msg; print a greeting
    NEWLINE

    push dword 10; push parameter for fact (10)
    call FACT
    add esp, 4; pop parameter

    PRINT_STRING ans; print answer
    PRINT_DEC 4, eax
    NEWLINE

    pop ebp; restore frame base register and return
    ret

FACT:
    push ebp
    mov ebp, esp

    PRINT_STRING rec; useful for debugging
    PRINT_DEC 4, [ebp+8] ; print n
    NEWLINE

    mov eax, [ebp+8];load n
    push eax
    mov eax, 0; load 0 
    pop ebx ; n is in ebx
    cmp ebx, eax ; (n-0)
    jle exitFact
   
    mov eax, [ebp+8]; push n to prepare for n*fact(n-1)
    push eax
    
    ;convoluted compiler-like code to compute (n-1)
    ;dec instruction is easier but needs special case in compiler
    mov eax, [ebp+8]; push n 
    push eax
    mov eax, 1 
    pop ebx
    sub ebx, eax
    mov eax, ebx
    
    push eax
    call FACT
    add esp, 4; pop parameter (n-1), return value in eax
    pop ebx; this contains the value of n
    imul eax, ebx; compute n*fact(n-1) in eax

    pop ebp
    ret
    
exitFact:
    mov eax, 1
    pop ebp  
    ret

    