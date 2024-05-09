bits	64
;	Print text file
section	.data
err1:
	db	"Usage: "
err1len	equ	$-err1
err2:
	db	" filename", 10
err2len	equ	$-err2
section	.text
global	_start
_start:
	cmp	dword [rsp], 2
	je	m3
	mov	eax, 1
	mov	edi, 2
	mov	esi, err1
	mov	edx, err1len
	syscall
	mov	eax, 1
	mov	edi, 2
	mov	rsi, [rsp+8]
	xor	edx, edx
m1:
	cmp	byte [rsi+rdx], 0
	je	m2
	inc	edx
	jmp	m1
m2:
	syscall
	mov	eax, 1
	mov	edi, 2
	mov	esi, err2
	mov	edx, err2len
	syscall
	jmp	m4
m3:
	mov	rdi, [rsp+16]
	call	work
	mov	edi, eax
	jmp	m5
m4:
	mov	edi, 1
m5:
	mov	eax, 60
	syscall
size	equ	4096
buf	equ	size
filename	equ	buf+8
fd	equ	filename+4
work:
	push	rbp
	mov	rbp, rsp
	sub	rsp, size+16
	mov	[rbp-filename], rdi
	mov	eax, 2
	xor	esi, esi
	syscall
	mov	[rbp-fd], eax
	or	eax, eax
	jge	.m1
	mov	edi, eax
	push	rax
	call	writeerr
	pop	rax
	jmp	.m4
.m1:
	xor	eax, eax
	mov	edi, [rbp-fd]
	lea	rsi, [rbp-buf]
	mov	edx, size
	syscall
	or	eax, eax
	je	.m3
	jg	.m2
	mov	edi, eax
	push	rax
	call	writeerr
	pop	rax
	jmp	.m3
.m2:
	mov	edx, eax
	mov	eax, 1
	mov	edi, 1
	lea	rsi, [rbp-buf]
	syscall
	jmp	.m1
.m3:
	push	rax
	mov	eax, 3
	mov	edi, [rbp-fd]
	syscall
	pop	rax
.m4:
	leave
	ret
section	.data
nofile:
	db	"No such file or directory", 10
nofilelen	equ	$-nofile
permission:
	db	"Permission denied", 10
permissionlen	equ	$-permission
unknown:
	db	"Unknown error", 10
unknownlen	equ	$-unknown
section .text
writeerr:
	cmp	edi, -2
	jne	.m1
	mov	esi, nofile
	mov	edx, nofilelen
	jmp	.m3
.m1:
	cmp	edi, -13
	jne	.m2
	mov	esi, permission
	mov	edx, permissionlen
	jmp	.m3
.m2:
	mov	esi, unknown
	mov	edx, unknownlen
.m3:
	mov	eax, 1
	mov	edi, 2
	syscall
	ret
