bits	64
global	work_image_asm
section	.text
work_image_asm:
	or	edx, edx
	jle	.e
	or	ecx, ecx
	jle	.e
	mov	eax, edx
	mul	rcx
	mov	rcx, rax
	mov	r8b, 3
.m:
	movzx	ax, byte [rdi]
	movzx	dx, byte [rdi+1]
	add	ax, dx
	movzx	dx, byte [rdi+2]
	add	ax, dx
	div	r8b
	mov	[rsi], al
	mov	[rsi+1], al
	mov	[rsi+2], al
	mov	al, [rdi+3]
	mov	[rsi+3], al
	add	rdi, 4
	add	rsi, 4
	loop	.m
.e:
	ret


bits 64
global rotate_image_asm
section .text
rotate_image_asm:
    ; rdi = src, rsi = dst, rdx = w, rcx = h, xmm0 = angle
    sub rsp, 8  ; for local variable rad
    cvtsi2sd xmm1, rdx
    divsd xmm1, [double_2]
    cvtsi2sd xmm2, rcx
    divsd xmm2, [double_2]
    movsd [rsp], xmm0  ; rad = angle
    xor r8, r8  ; y = 0
.loop_y:
    xor r9, r9  ; x = 0
.loop_x:
    ; calculate srcX and srcY
    ; ...
    ; copy pixel if in bounds
    ; ...
    inc r9
    cmp r9, rdx
    jl .loop_x
    inc r8
    cmp r8, rcx
    jl .loop_y
    add rsp, 8
    ret

section .data
double_2: dq 2.0
