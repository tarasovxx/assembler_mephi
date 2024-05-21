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
msg5:
	db	"Input accuracy", 10, 0
usage:
	db	"Usage: %s file", 10, 0
format_string:
	db	"%d) sinh(x) = %.14f", 10, 0
mode:
	db	"w", 0
abs_mask:
	dq	0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF

section	.text
one	dq	1.0
three 	dq	3.0
six	dq	6.0
xm0	equ	8
xm1	equ	xm0+8
xm2	equ 	xm1+8
xm3	equ	xm2+8
xm4	equ	xm3+8
xm5	equ	xm4+8
xm6	equ	xm5+8
xm7	equ	xm6+8
cnt	equ	xm7+4
fw	equ	cnt+4
mysinh:
	; open output file
    	;mov rdi, filename
    	;mov rsi, "w"
    	;call fopen
    	;mov [file_handle], rax
	push	rbp
	mov	rbp, rsp
	sub	rsp, fw
	and	rsp, -16
	mov	[rbp-fw], rdi
	movsd	[rbp-xm7], xmm1
	;movsd	[rsp-xm0], xmm0
	
	movsd	xmm1, xmm0
	movsd	xmm2, xmm0
	movsd	xmm3, [three]
	movsd	xmm4, [one]
	movsd	xmm6, [six]
	mov	rdi, 1
.m0:
	movsd	xmm5, xmm2
	mulsd	xmm1, xmm0
	mulsd	xmm1, xmm0
	divsd	xmm1, xmm6
	addsd	xmm2, xmm1
	inc	rdi
	
	; print calculation step to file
    	; rdi is good already
	movsd	[rbp-xm0], xmm0
	movsd	[rbp-xm1], xmm1
	movsd	[rbp-xm2], xmm2
	movsd	[rbp-xm3], xmm3
	movsd	[rbp-xm4], xmm4
	movsd	[rbp-xm5], xmm5
	movsd	[rbp-xm6], xmm6
	mov	[rbp-cnt], rdi
	movsd	xmm0, xmm2
	;movsd	xmm1, xmm2

	mov	rdx, rdi
	mov	edi, [rbp-fw]
	mov	rsi, format_string
    	mov 	eax, 1
    	call 	fprintf
	movsd 	xmm0, [rbp-xm0]
	movsd 	xmm1, [rbp-xm1]
	movsd 	xmm2, [rbp-xm2]
	movsd 	xmm3, [rbp-xm3]
	movsd 	xmm4, [rbp-xm4]
	movsd 	xmm5, [rbp-xm5]
	movsd 	xmm6, [rbp-xm6]
	movsd	xmm7, [rbp-xm7]
	mov	rdi, qword [rbp-cnt]

	addsd	xmm3, xmm4
	movsd 	xmm6, xmm3
	addsd	xmm6, xmm4
	mulsd	xmm6, xmm3
	addsd	xmm3, xmm4
	;TODO
	movsd	xmm8, xmm1
	andpd	xmm8, [abs_mask]
	;ucomisd	xmm2, xmm5
	ucomisd	xmm8, xmm7
	ja	.m0
	movsd	xmm0, xmm2
	; close output file
    	;mov rdi, [file]
    	;call fclose
	leave
	ret

x	equ	8
y	equ	x+8
accur	equ	y+8
prog	equ	accur+8
file	equ	prog+8
fw1	equ	file+4

extern	printf
extern	scanf

extern	sinh

extern	fclose
extern	fopen
extern	fprintf

extern	stderr
extern 	perror

global	main
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, fw1
	and	rsp, -16
	cmp	edi, 2
	je	.m1
	mov	rdi, [stderr]
	mov	rdx, [rsi]
	mov	esi, usage
	xor 	eax, eax
	call 	fprintf
	mov	eax, 1
	jmp	.m3
.m1:
	mov	rax, [rsi]
	mov	[rbp-prog], rax
	mov	rdi, [rsi+8]
	mov	[rbp-file], rdi
	mov	esi, mode
	call 	fopen ;return FILE*
	or	rax, rax
	jne	.m2
	mov	rdi, [rbp-file]
	call	perror
	mov	eax, 1
	jmp	.m3
.m2:
	mov	[rbp-fw1], rax
	mov	edi, msg1
	xor	eax, eax
	call	printf
	mov	edi, msg2
	lea	rsi, [rbp-x]
	xor	eax, eax
	call	scanf
	or	eax, eax
	jl	.m3
	mov	edi, msg5
	xor	eax, eax
	call	printf
	mov	edi, msg2
	lea	rsi, [rbp-accur]
	xor	eax, eax
	call	scanf
	or	eax, eax
	jl	.m3
	movsd	xmm0, [rbp-x]
	call	sinh
	movsd	[rbp-y], xmm0
	mov	edi, msg3
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-accur]
	andpd	xmm1, [abs_mask]
	ucomisd	xmm1, [rbp-accur]
	jne	.m3
	mov	rdi, [rbp-fw1]
	call	mysinh
	movsd	[rbp-y], xmm0
	mov	edi, msg4
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	xor	eax, eax
.m3:
	leave
	;xor	eax, eax
	ret
