bits	64
; (a * e - b * c + (d/b)) / ((b + c) * a)
section .data
a dq 1073741809
b dd -15
c dd 33554217
d db 127
e dw 32710
temp1  dq 0
temp2  dq 0
temp3  dq 0
temp4  dq 0
temp5  dq 0
err_msg db "Division by zero error", 0
overflow_msg db "Overflow error", 0
section .bss
result resq 1
section .text
global _start
_start:
; temp3 = d / b
    movsx eax, byte [d]
    cdq
    mov ebx, [b] 
    cmp ebx, 0
    je divide_error
    idiv ebx ; EDX:EAX/op -> EAX - result 
    movsxd rax, eax ;Move doubleword to quadword with sign- extension.
    mov [temp3], rax 

; temp1 = a * e
    xor rdx, rdx
    mov rax, [a]
    movsx rdx, word [e]
    imul rax, rdx
    jo overflow_error
    ; отлов переполнения
    mov [temp1], rax

; temp2 = b * c
    mov eax, [b]
    imul eax, [c]
    jo overflow_error
    movsxd rax, eax
    mov [temp2], rax

; temp4 = b + c
    mov eax, [b]
    add eax, dword [c]
    jo overflow_error
    movsxd rax, eax
    mov [temp4], rax

; temp5 = temp1 - temp2 + temp3
    mov rax, [temp1]
    sub rax, [temp2]
    add rax, [temp3]
    jo overflow_error
    mov [temp5], rax

; result = temp5 / (temp4 * a)
    mov rcx, [temp4]
    imul rcx, qword [a]
    jo overflow_error
    cmp rcx, 0
    je divide_error
    mov rax, [temp5]
    ; cqo;
    ;mov rcx, rax  
    ;xor rax, rax
    ;mov rax, rdx 
    cqo ; prepared the dividend in rdx:rax     
    idiv rcx ; RDX:RAX / op -> RAX - result
    mov [result], rax

exit:
    xor edi, edi 
    mov eax, 60
    syscall

divide_error:
    mov edi, 1 
    mov eax, 1
    mov edx, 23 ; Message length
    lea rsi, [rel err_msg] ; Message to write
    syscall
    ;xor edi, edi
    mov edi, 1
    mov eax, 60
    syscall

overflow_error:
    mov edi, 1 
    mov eax, 1
    mov edx, 14 ; Message length
    lea rsi, [rel overflow_msg] ; Message to write
    syscall
    ;xor edi, edi
    mov edi, 2
    mov eax, 60
    syscall
