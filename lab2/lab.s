bits	64
;	Sorting rows by matrix in sum 
section	.data
n:
	dd	3
m:
	dd	5
matrix:
	dd	4, 6, 1, 8, 2
	dd	1, 2, 3, 4, 5	
	dd	0, -7, 3, -1, -1
sum:
	dd	0, 0, 0, 0
section	.text
global	_start
_start:
	mov	ecx, [n]
	;dec 	ecx
	cmp	ecx, 1
	jle	end
	xor	r8, r8
	mov	ebx, matrix
m1:
	xor	edi, edi
	mov	eax, [rbx]
	push	rcx
	mov	ecx, [m]
	dec	ecx
	jecxz	m3
m2:
	;inc	edi
	add 	ebx, 4
	add	eax, [rbx]
	;add	ebx, 4
	loop	m2
m3:
	;mov	ebx, [rbx + rdi * 4 + 4]
	xor	edi, edi
	add	ebx, 4
	mov	edi, sum
	mov	[rdi + r8], eax
	add	r8, 4
	pop	rcx
	loop	m1
	xor	ebx, ebx
	mov	ecx, [n]
	mov	eax, 0 ; left
	mov	ebx, [n] ; right 
	dec	ebx;
	mov	esi, 0; ; flag
	dec	ecx
while_: ;while 
	cmp	eax, ebx
	jae	end
	cmp	esi, 0
	jne	end
	inc	esi
	; push	rcx
	mov	edx, [sum + eax * 4]
	mov	edi, eax
	mov	r8, rax
	; mov	esi, ebx
left_to_right:
	; mov	edi, eax
	mov 	ebp, 0
	inc	edi
	cmp	[sum + rdi * 4], edx
	cmovg	edx, [rdi * 4 + sum]
	cmovg	r8, rdi
	cmovl	esi, ebp ;TODO
	cmp	edi, ebx
	jne	left_to_right
	; dec	ebx
	je	swap
swap:
	cmp	esi, 0
	jne	right_to_left
	;mov	ecx
	xchg	edx, [sum + ebx * 4]
	mov 	[sum + r8 * 4], edx
	xor	esi, esi
	;mov	ecx, [n]
	mov	ebp, [m]
	mov	ecx, ebp
	shl	ebp, 2
	;shl 	ecx, 2
	mov	edi, ebx
	;mov	r8, [matrix + r8]
	;mov	edi, [matrix +  ebp]
	imul 	edi, ebp
	imul	r8, rbp
	jmp 	swap_rows ;TODO

	jmp	right_to_left

swap_rows:
	mov	esp, [matrix + r8] ; указательна начала строки жирной
	xchg	[matrix + edi], esp
	mov	[matrix + r8], esp
	add	r8, 4
	add	edi, 4
	; mov	edx, [rdi + rsi * 4]
	; mov	[rdi+rbx*4], edx
	; mov	[rdi+rsi*4], eax
	; mov	eax, [n]
	; shl	eax, 2
	; add	edi, eax
	loop	swap_rows
	dec	ebx
	cmp	eax, ebx
	jae	end
	mov	ecx, ebx
	mov	edi, ebx
	mov	edx, [sum + ebx * 4]
	mov	esi, 1
	jmp	right_to_left

right_to_left:
	; mov	edi, eax
	dec	edi
	mov 	ebp, 0
	cmp	[sum + rdi * 4], edx
	cmovl	edx, [rdi * 4 + sum]
	cmovl	r8, rdi
	cmovl	esi, ebp
	loop	right_to_left
	cmp	esi, 0
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
	cmp	esi, 0
	jne	while_
	; mov	ecx
	xchg	edx, [sum + eax * 4]
	mov 	[sum + r8 * 4], edx
	xor	esi, esi
	mov	ebp, [m]
	mov	ecx, ebp
	mov	edi, eax
	shl	ebp, 2
	imul	edi, ebp
	imul	r8, rbp
	jmp 	swap_rows_backward

swap_rows_backward:
	mov	esp, [matrix + r8] ; указательна начала строки жирной
	xchg	esp, [matrix + edi] 
	mov	[matrix + r8], esp
	add	r8, 4
	add	edi, 4
	; mov	edx, [rdi + rsi * 4]
	; mov	[rdi+rbx*4], edx
	; mov	[rdi+rsi*4], eax
	; mov	eax, [n]
	; shl	eax, 2
	; add	edi, eax
	loop	swap_rows_backward
	inc 	eax
	cmp	eax, ebx
	jae	end
	jmp	while_	
end:
	mov	eax, 60
	mov	edi, 0
	syscall
