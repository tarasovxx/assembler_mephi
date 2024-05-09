bits	64
;	Print enviroment variable
section	.data
err1:
	db	"Usage: "
err1len	equ	$-err1
err2:
	db	" name_of_variable", 10
err2len	equ	$-err2
err3:
	db	"Not found"
lf:
	db	10
err3len	equ	$-err3
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
	mov	edi, 1
	jmp	m10
m3:
	mov	rdi, [rsp+16]
	mov	ebx, 3
m4:
	inc	ebx
	mov	rsi, [rsp+rbx*8]
	or	rsi, rsi
	je	m9
	xor	ecx, ecx
m5:
	mov	al, [rdi+rcx]
	cmp	al, [rsi+rcx]
	jne	m6
	inc	ecx
	jmp	m5
m6:
	or	al, al
	jne	m4
	cmp	byte [rsi+rcx], "="
	jne	m4
	mov	eax, 1
	mov	edi, 1
	xor	edx, edx
m7:
	cmp	byte [rsi+rdx], 0
	je	m8
	inc	edx
	jmp	m7
m8:
	syscall
	mov	eax, 1
	mov	edi, 1
	mov	esi, lf
	mov	edx, 1
	syscall
	xor	edi, edi
	jmp	m10
m9:
	mov	eax, 1
	mov	edi, 2
	mov	esi, err3
	mov	edx, err3len
	syscall
	mov	edi, 1
m10:
	mov	eax, 60
	syscall
