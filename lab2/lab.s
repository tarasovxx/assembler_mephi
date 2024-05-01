bits	64
;	Sorting rows by matrix in sum 
; Почему в памяти обращаемся на 8 бит больше
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
	db	0, 0, 2
sum:
	db	0, 0, 0, 0
section	.text
global	_start
_start:
	mov	cl, byte [n]
	cmp	cl, 1
	jle	end
	xor	r8, r8
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
while_: ;while 
	cmp	al, bl
	jae	end
	cmp	sil, 0
	jne	end
	inc	sil
	; push	rcx
	movzx	rax, al
	movzx	dx, [sum + rax]
	mov	dil, al
	mov	r8, rax ;TODO
	; mov	esi, ebx
left_to_right:
	; mov	edi, eax
	xor 	bp, bp
	inc	dil
	movzx	rdi, dil
	cmp	[sum + rdi], dl
	cmovg	dx, [sum + rdi]
	cmovg	r8, rdi
	cmovl	si, bp ;TODO
	cmp	dil, bl
	jne	left_to_right
	; dec	ebx
	je	swap
swap:
	cmp	si, 0
	jne	right_to_left
	;mov	ecx
	xchg	dl, [sum + rbx]
	mov 	[sum + r8], dl
	xor	si, si
	;mov	ecx, [n]
	mov	bpl, [m]
	mov	cl, bpl
	;shl	ebp, 2
	;shl 	ecx, 2
	movzx	di, bl
	;mov	r8, [matrix + r8]
	;mov	edi, [matrix +  ebp]
	imul 	di, bp
	imul	r8, rbp ;TODO
	jmp 	swap_rows ;TODO

	jmp	right_to_left

swap_rows:
	mov	spl, [matrix + r8] ; указательна начала строки жирной
	xchg	[matrix + rdi], spl
	mov	[matrix + r8], spl
	inc	r8
	inc	dil
	; mov	edx, [rdi + rsi * 4]
	; mov	[rdi+rbx*4], edx
	; mov	[rdi+rsi*4], eax
	; mov	eax, [n]
	; shl	eax, 2
	; add	edi, eax
	loop	swap_rows
	dec	bl
	cmp	al, bl
	jae	end
	mov	cl, bl
	mov	dil, bl
	movzx	dx, byte [sum + rbx]
	mov	sil, 1
	jmp	right_to_left

right_to_left:
	; mov	edi, eax
	dec	dil
	xor 	bp, bp
	cmp	dx, [sum + rdi]
	cmovl	dx, [rdi + sum]
	cmovl	r8, rdi
	cmovl	si, bp
	loop	right_to_left
	cmp	si, 0
	je	swap_backward
	jmp	while_



	; cmp	esi, ebx
	; je	m7
	; mov	edx, [rbx * 4 + sum]
	; mov	[rbx*4+sum], eax
	; mov	[rsi*4+sum], edx
	; mov	ecx, [m]
	; mov	edi, matrix
swap_backward:
	cmp	sil, 0
	jne	while_
	; mov	ecx
	xchg	dl, [sum + rax]
	mov 	[sum + r8], dl
	xor	sil, sil
	mov	bpl, [m]
	mov	cl, bpl
	movzx	di, al
	;shl	ebp, 2
	imul	di, bp
	imul	r8, rbp
	jmp 	swap_rows_backward

swap_rows_backward:
	mov	spl, [matrix + r8] ; указательна начала строки жирной
	xchg	spl, [matrix + rdi] 
	mov	[matrix + r8], spl
	inc	r8
	inc	dil
	; mov	edx, [rdi + rsi * 4]
	; mov	[rdi+rbx*4], edx
	; mov	[rdi+rsi*4], eax
	; mov	eax, [n]
	; shl	eax, 2
	; add	edi, eax
	loop	swap_rows_backward
	inc 	al
	cmp	al, bl
	jae	end
	jmp	while_	
end:
	mov	eax, 60
	mov	edi, 0
	syscall
