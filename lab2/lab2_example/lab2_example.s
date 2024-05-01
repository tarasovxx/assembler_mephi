bits	64
;	Sorting columns of matrix by max elements
section	.data
n:
	dd	3
m:
	dd	5
matrix:
	dd	4, 6, 1, 8, 2
	dd	1, 2, 3, 4, 5	
	dd	0, -7, 3, -1, -1
max:
	dd	0, 0, 0, 0, 0
section	.text
global	_start
_start:
	mov	ecx, [m]
	cmp	ecx, 1
	jle	m8
	mov	ebx, matrix
m1:
	xor	edi, edi
	mov	eax, [rbx]
	push	rcx
	mov	ecx, [n]
	dec	ecx
	jecxz	m3
m2:
	add	edi, [m]
	cmp	eax, [rbx+rdi*4]
	cmovl	eax, [rbx+rdi*4]
	loop	m2
m3:
	add	edi, [m]
	mov	[rbx+rdi*4], eax
	add	ebx, 4
	pop	rcx
	loop	m1
	xor	ebx, ebx
	mov	ecx, [m]
	dec	ecx
m4:
	push	rcx
	mov	eax, [rbx*4+max]
	mov	edi, ebx
	mov	esi, ebx
m5:
	inc	edi
	cmp	eax, [rdi*4+max]
	cmovg	eax, [rdi*4+max]
	cmovg	rsi, rdi
	loop	m5
	cmp	esi, ebx
	je	m7
	mov	edx, [rbx*4+max]
	mov	[rbx*4+max], eax
	mov	[rsi*4+max], edx
	mov	ecx, [n]
	mov	edi, matrix
m6:
	mov	eax, [rdi+rbx*4]
	mov	edx, [rdi+rsi*4]
	mov	[rdi+rbx*4], edx
	mov	[rdi+rsi*4], eax
	mov	eax, [m]
	shl	eax, 2
	add	edi, eax
	loop	m6
m7:
	inc	ebx
	pop	rcx
	loop	m4
m8:
	mov	eax, 60
	mov	edi, 0
	syscall
