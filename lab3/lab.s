bits	64
;	remove all palindromes in string in file
section	.data
size	equ	4096
namelen	equ	1024
anslen	equ	3
err1:
	db	"Usage: "
err1len	equ	$-err1
err3:
	db	" name_of_variable", 10
err2len	equ	$-err3
err4:
	db	"NotFound"
err3len	equ	$-err4
err2:
	db	"No such file or direcrtory!", 10
err13:
	db	"Permission denied!", 10
err21:
	db	"Is a directory!", 10
err36:
	db	"File name too long", 10
err255:
	db	"Unknown error!", 10
errlist:
	times	2	dd	err255
	dd	err2
	times	10	dd	err255
	dd	err13
	times	7	dd	err255
	dd	err21
	times	14	dd	err255
	dd	err36
	times	269	dd	err255
ans:
	times	anslen	db	0
fdr:
	dd	-1
section	.text
global	_start
_start:
	cmp	dword [rsp], 2
	je	.m3
	mov	eax, 1
	mov	edi, 2
	mov	esi, err1
	mov	edx, err1len
	syscall
	mov	eax, 1
	mov	edi, 2
	mov	rsi, [rsp+8]
	xor	edx, edx
.m1:
	cmp	byte [rsi+rdx], 0
	je	.m2
	inc	edx
	jmp	.m1
.m2:
	syscall
	mov	eax, 1
	mov	edi, 2
	mov	esi, err2
	mov	edx, err2len
	syscall
	mov	edi, 1
	jmp	.m8
.m3:
	mov	rdi, [rsp+16]
	mov	ebx, 3
.m4:
	inc	ebx
	mov	rsi, [rsp+rbx*8]
	or	rsi, rsi
	je	.m9
	xor	ecx, ecx
.m5:
	mov	al, [rdi+rcx]
	cmp	al, [rsi+rcx]
	jne	.m6
	inc	ecx
	jmp	.m5
.m6:
	or	al, al
	jne	.m4
	cmp	byte [rsi+rcx], "="
	jne	.m4
	inc 	ecx
	mov	eax, 2
	add	rsi, rcx
	mov	rdi, rsi
	xor	esi, esi
	syscall
	or	eax, eax
	jge	.m_help
	mov	ebx, eax
	neg	ebx
	jmp	.m11
.m_help:
	mov	[fdr], eax
.m3_help:
	mov	edi, [fdr]
	call	work
	mov	ebx, eax
	neg	ebx
	jmp 	.m6_help

.m9:
	mov	eax, 1
	mov	edi, 2
	mov	esi, err3
	mov	edx, err3len
	syscall
	mov	edi, 1

.m11:
	or	ebx, ebx
	je	.m6_help
	mov	eax, 1
	mov	edi, 1
	mov	esi, [errlist+rbx*4]
	xor	edx, edx

.m12:
	inc	edx
	cmp	byte [rsi+rdx-1], 10
	jne	.m12
	syscall

.m6_help:
	cmp	dword [fdr], -1
	je	.m8
	mov	eax, 3
	mov	edi, [fdr]
	syscall

.m8:
	mov	eax, 60
	syscall



bufin	equ	size
bufout	equ	size+bufin
buftmp	equ	size+bufout
fr	equ	buftmp+4
letter	equ	fr+4
n	equ	letter+4
work:
	push	rbp
	mov	rbp, rsp
	sub	rsp, n
	and	rbp, -16
	push	rbx
	mov	[rbp-fr], edi
	mov	dword [rbp-letter], 0
	mov	dword [rbp-n], 0
.m0:
	mov	eax, 0
	mov	edi, [rbp-fr]
	lea	rsi, [rbp-bufin]
	mov	edx, size
	syscall
	or	eax, eax
	jle	.m8
	mov	ebx, [rbp-letter]
	mov	edx, [rbp-n]
	lea	rsi, [rbp-bufin]
	lea	rdi, [rbp-buftmp]
	lea	r8, [rbp-bufout]
	mov	ecx, eax
.input:
	mov	al, [rsi]
	inc	rsi
	cmp	al, 10
	je	.end_word
	cmp	al, ' '
	je	.end_word
	cmp	al, 9
	je	.end_word
	mov	[rdi], al
	;or	edx, edx
	;je	.m2
	;test	edx, 1
	;jne	.m3
	;or	ebx, ebx
	;jne	.m2
	;mov	byte [rdi], ' '
	inc	rdi
	inc	ebx
	jmp	.m6
.end_word:
	or	ebx, ebx
	je	.m4
	xor	ebx, ebx
	inc 	edx
	lea	r9, [rbp - buftmp]
	lea	r11, [rbp - buftmp]
	mov	r12, rdi
	dec	r12
.check_palindrome:
	mov	r13b, [r12]
	mov	r10b, [r9]
	cmp 	r10b, r13b
	jne	.delete_word
	;cmp	r12, r9
	;je	.insert_word
	inc	r9
	dec	r12
	cmp	r9, r12
	jae	.insert_word
	jmp 	.check_palindrome
	xor	ebx, ebx
	;inc	edx
.delete_word:
	xor	ebx, ebx
	lea	rdi, [rbp-buftmp]
	jmp	.m4
.insert_word:
	cmp	r11, rdi
	je	.m3
	mov 	r13b, byte [r11]
	mov	byte [r8], r13b
	inc	r11
	inc	r8
	jmp	.insert_word

.m3:
	lea	rdi, [rbp-buftmp]
	cmp	al, 10
	jne	.insert_space

.m4:
	;lea	rdi, [rbp - buftmp]
	;mov	byte [r8], ' '
	;inc	r8
	;or	edx, edx
	;je	.insert_space
	;xor	edx, edx
	
	cmp	al, 10
	jne	.m6
	xor	ebx, ebx
	mov	byte [r8], 10
	inc	r8
	jmp	.m6
.insert_space:
	mov	byte [r8], ' '
	inc 	r8
.m6:
	dec	ecx
	jne	.input
	mov	[rbp-letter], ebx
	mov	[rbp-n], edx
	lea	rsi, [rbp-bufout]
	mov	rdx, r8
	sub	rdx, rsi
	mov	ebx, edx
.m7:
	mov	eax, 1
	mov	edi, 0
	;mov	edi, [rbp-fw] ; for file with file descryptor fw
	syscall
	or	eax, eax
	jl	.m8
	sub	ebx, eax
	je	.m0
	lea	rsi, [rbp+rax-bufout]
	mov	edx, ebx
	jmp	.m7
.m8:
	pop	rbx
	leave
	ret
