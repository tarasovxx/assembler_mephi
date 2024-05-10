bits	64
;	Sorting rows by matrix in sum 
; db: [-128, 127] || [0, 255]
section	.data
n:
	db	4
m:
	db	3
matrix:
	db	1, 0, 2
	db	-1, 3, -1	
	db	2, 1, 1
	db 	0, 0, 2
ans:	times	12	db	0
sum:
	db	0, 0, 0, 0
ind:
	db	0, 1, 2, 3
section	.text
global	_start
_start:
	mov	cl, byte [n]
	cmp	cl, 1
	jle	end
	xor	r8, r8
	xor	r13, r13
	mov	rbx, matrix
m1:
	xor	dil, dil
	;movzx 	rbx, bl
	mov	al, [rbx]
	movzx	rcx, cl
	push	rcx
	mov	cl, [m]
	dec	cl
	jecxz	m3
m2:
	inc 	bl
	;movzx	rbx, bl
	add	al, [rbx]
	loop	m2
m3:
	xor	dil, dil
	inc	bl
	mov	rdi, sum
	mov	byte [rdi + r8], al
	inc	r8
	pop	rcx
	loop	m1
	xor	bl, bl
	mov	cl, [n]
	xor	ax, ax ; left
	movzx	rbx, byte [n] ; right 
	dec	bl;
	xor	si, si ; flag
	dec	cl
while: ;while 
	xor	dil, dil
	cmp	al, bl
	jae	return_ans
	cmp	sil, 0
	jne	end
	inc	sil
	movzx	rax, al
	movzx	dx, [sum + rax]
	mov	dil, al
	mov	r8w, ax
left_to_right:
	xor 	bp, bp
	inc	dil
	movzx	rdi, dil
	cmp	[sum + rdi], dl
	cmovg	dx, [sum + rdi]
	cmovg	r8w, di
	cmovl	si, bp
	cmp	dil, bl
	jne	left_to_right
	mov	r9b, 1; for swap, continue right_to_left
	mov	r10, rbx
	dec	rbx
	cmp	si, 0
	je	swap
	jne 	right_to_left

right_to_left_prepare:
	mov	sil, 1

right_to_left:
	dec	dil
	xor 	bp, bp
	cmp	dl, [sum + rdi]
	cmovg	dx, [rdi + sum]
	cmovg	r8w, di
	cmovg	si, bp
	cmp	al, dil
	jne	right_to_left
	mov	r9b, 0
	mov	r10, rax
	inc 	rax
	cmp	si, 0
	je	swap
	jne 	while

swap:
	cmp	si, 0
	jne	while
	xchg	dl, [sum + r10]
	mov 	[sum + r8], dl
	mov	r11b, [ind + r8]
	xchg	r11b, [ind + r10]
	mov	[ind + r8], r11b
	cmp	r9b, 1
	je 	right_to_left_prepare
	jne	while

return_ans:
	cmp	dil, [n]
	je	end
	movzx	r8, byte [m]
	xor	rcx, rcx
	movzx	rbx, byte [ind+rdi]
	imul	r8, rbx
	inc	dil
lo1:
	mov	dl, [matrix+r8]
	mov	[ans+r13], dl
	inc	r13
	inc	r8
	inc	cl
	cmp	cl, [m]
	je	return_ans
	jne	lo1
	
end:
	mov	eax, 60
	mov	edi, 0
	syscall
