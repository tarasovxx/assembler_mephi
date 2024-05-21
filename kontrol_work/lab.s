bits 64
section .data
buflen	equ	20 + 1
buf_in:	times 	buflen	 db 0
buf_out: times	buflen	db 0
section	.text
global _start
_start:
	mov 	eax, 0
	mov	edi, 0
	mov 	esi, buf_in
	mov	edx, buflen
	syscall
	or	eax, eax
	je	.end
	xor	ecx, ecx ; WHILE TRUE

.prepare:
	xor	r8, r8 ; ind buf_in
	xor	r9, r9 ; ind buf_out
	xor	si, si ; flag
	mov	si, 1
.work:
	mov	al, byte [buf_in + r8]
	cmp	al, 32
	je	.is_separator
	cmp	al, 10
	je	.is_separator
	cmp	al, 0
	je	.afterwork
	jmp	.is_letter
.is_separator:
	inc	r8
	mov	si, 1
	jmp	.work

.is_letter:
	cmp	si, 1
	je	.write
	inc	r8
	jmp	.work
.write:
	mov	[buf_out + r9], al
	inc	r9
	mov	si, 0
	jmp	.work
.afterwork:
	mov	eax, 1
	mov	edi, 1
	mov	esi, buf_out
	mov	rdx, r9
	syscall
.end:
	mov	eax, 60
	; edi is good
	syscall
	
