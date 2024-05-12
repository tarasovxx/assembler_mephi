bits	64
;	Compare exponent from mathlib and my own implementation
section	.data
msg1:
	db	"Input x", 10, 0
msg2:
	db	"%lf", 0
msg3:
	db	"sinh(%.10g)=%.10g", 10, 0
msg4:
	db	"mysinh(%.10g)=%.10g", 10, 0
section	.text
one	dq	1.0
three 	dq	3.0
six	dq	6.0
myexp:
	movsd	xmm1, xmm0
	movsd	xmm2, xmm0
	movsd	xmm3, [three]
	movsd	xmm4, [one]
	movsd	xmm6, [six]
.m0:
	movsd	xmm5, xmm2
	mulsd	xmm1, xmm0
	mulsd	xmm1, xmm0
	divsd	xmm1, xmm6
	addsd	xmm2, xmm1
	addsd	xmm3, xmm4
	movsd 	xmm6, xmm3
	addsd	xmm6, xmm4
	mulsd	xmm6, xmm3
	addsd	xmm3, xmm4
	;addsd	xmm3, xmm4
	ucomisd	xmm2, xmm5
	jne	.m0
	movsd	xmm0, xmm2
	ret
x	equ	8
y	equ	x+8
extern	printf
extern	scanf
extern	sinh
global	main
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, y
	mov	edi, msg1
	xor	eax, eax
	call	printf
	mov	edi, msg2
	lea	rsi, [rbp-x]
	xor	eax, eax
	call	scanf
	movsd	xmm0, [rbp-x]
	call	sinh
	movsd	[rbp-y], xmm0
	mov	edi, msg3
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	movsd	xmm0, [rbp-x]
	call	myexp
	movsd	[rbp-y], xmm0
	mov	edi, msg4
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	leave
	xor	eax, eax
	ret
