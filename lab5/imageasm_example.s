bits	64
%ifdef	SSE
global	work_image_asmSSE
%else
global	work_image_asm
%endif
section	.text
%ifdef	SSE
work_image_asmSSE:
	push	rbp
	mov	rbp, rsp
%else
work_image_asm:
%endif
	or	edx, edx
	jle	.e
	or	ecx, ecx
	jle	.e
	mov	eax, edx
	mul	rcx
%ifdef	SSE
	mov	r8, 4
	div	r8
	mov	rcx, rax
	mov	rax, 0ff000000ffh
	push	rax
	push	rax
	mov	rax, 2ab000002abh
	push	rax
	push	rax
	mov	rax, 0ff000000ff000000h
	push	rax
	push	rax
	movaps	xmm2, [rbp-16]
	movaps	xmm5, [rbp-32]
.l:
	movaps	xmm0, [rdi]
	movaps	xmm1, [rbp-48]
	pand	xmm1, xmm0
	movaps	xmm3, xmm0
	movaps	xmm4, xmm0
	psrld	xmm3, 8
	psrld	xmm4, 16
	pand	xmm0, xmm2
	pand	xmm3, xmm2
	pand	xmm4, xmm2
	paddw	xmm0, xmm3
	paddw	xmm0, xmm4
	movaps	xmm6, xmm0
	pmulhuw	xmm0, xmm5
	pmullw	xmm6, xmm5
	psllw	xmm0, 5
	psrlw	xmm6, 11
	por	xmm0, xmm6
	por	xmm1, xmm0
	pslld	xmm0, 8
	por	xmm1, xmm0
	pslld	xmm0, 8
	por	xmm1, xmm0
	movaps	[rsi], xmm1 
	add	rdi, 16
	add	rsi, 16
	loop	.l
	mov	rcx, rdx
	jrcxz	.e
%else
	mov	rcx, rax
%endif
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
%ifdef	SSE
	add	rsp, 48
	leave
%endif
	ret
