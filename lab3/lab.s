bits	64
;	remove all palindromes in string in file
section	.data
size	equ	4096
namelen	equ	1024
anslen	equ	3
msg1:
	db	"Input filename for read", 10
msg1len equ	$-msg1
err2:
	db	"No such file or direcrtory!", 10
err13:
	db	"Permission denied!", 10
err21:
	db	"Is a directory!", 10
err36:
	db	"File name too long", 10
err150:
	db	"Program does not require parameters!", 10
err255:
	db	"Unknown error!", 10
errlist:
	times	2	dd	err255
	dd	err2
	times	10	dd	err255
	dd	err13
	times	6	dd	err255
	dd	err21
	times	14	dd	err255
	dd	err36
	times	113	dd	err255
	dd	err150
	times	155	dd	err255
name1:
	times	namelen	db	0
ans:
	times	anslen	db	0
fdr:
	dd	-1
section	.text
global	_start
_start:
	cmp	dword [rsp], 2
	je	.m0
	mov	ebx, 150
	jmp	.m4
.m0:
	mov	eax, 1
	mov	edi, 1
	mov	esi, msg1
	mov	edx, msg1len
	syscall
	mov	eax, 0
	mov	edi, 0
	mov	esi, name1
	mov	edx, namelen
	syscall
	or	eax, eax
	jle	.m1
	cmp	eax, namelen
	jl	.m2
.m1:
	mov	ebx, 151
	jmp	.m4
.m2:
	mov	byte [rax+name1-1], 0 ; затираем нулём, так как в конце \n
	mov	eax, 2 ; открыть файл
	mov	edi, name1
	xor	esi, esi
	syscall
	or	eax, eax
	jmp	.m_help
	mov	ebx, eax
	neg	ebx
	jmp	.m4
.m_help:
	mov	[fdr], eax

.m3:
	mov	edi, [fdr]
	call	work
	mov	ebx, eax
	neg	ebx
.m4:
	or	ebx, ebx
	je	.m6
	mov	eax, 1
	mov	edi, 1
	mov	esi, [errlist+rbx*4]
	xor	edx, edx
.m5:
	inc	edx
	cmp	byte [rsi+rdx-1], 10
	jne	.m5
	syscall
.m6:
	cmp	dword [fdr], -1
	je	.m7
	mov	eax, 3
	mov	edi, [fdr]
	syscall
.m7:
	;cmp	dword [fdw], -1
	je	.m8
	mov	eax, 3
	;mov	edi, [fdw]
	syscall
.m8:
	mov	edi, ebx
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
