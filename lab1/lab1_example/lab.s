bits	64
;	res=(a+b)*d*e/c-(c+d)/a
section	.data
res:
	dq	0
a:
	dw	40
b:
	dw	100
c:
	dw	20
d:
	dw	20
e:
	dw	30
section	.text
global	_start
_start:
	movsx	ebx, word[a]
	movsx	ecx, word[c]
	movsx	edi, word[d]
	movsx	eax, word[e]
	imul	edi
	idiv	ecx
	movsx	esi, word[b]
	add	esi, ebx
	imul	esi
	mov	esi, eax
	sal	rdx, 32
	or	rsi, rdx
	mov	eax, ecx
	add	eax, edi
	cdq
	idiv	ebx
	cdqe
	sub	rsi, rax
	mov	[res], rsi
	mov	eax, 60
	mov	edi, 0
	syscall
