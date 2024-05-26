bits	64
global	work_image_asm

section .data
double_2 dq 2.0
PI dq 3.141592653589793
DEG_TO_RAD dq 0.017453292519943
section .bss
sin_angle resq 1
cos_angle resq 1
angle_rad resq 1
cy resq 1
section	.text
work_image_asm:
    	; rdi = src, rsi = dst, rdx = w, rcx = h, xmm0 = angle
	or	edx, edx
	jle	.exit
	or	ecx, ecx
	jle	.exit
	;mov	eax, edx
	;mul	rcx
	;mov	rcx, rax
	movsd 	xmm8, [DEG_TO_RAD]
	mulsd	xmm8, xmm0 ; xmm0 angle rad
	movsd 	xmm9, xmm8
	; Вычисление угла в радианах
    	movsd xmm1, [DEG_TO_RAD]
   	mulsd xmm0, xmm1
   	movsd qword [angle_rad], xmm0
	;fsin	xmm8
	;fsin
	;fcos	xmm9
	;fcos
	; Вычисление косинуса и синуса угла
    	fld qword [angle_rad]
    	fsin
    	fstp qword [sin_angle]
    	fld qword [angle_rad]
    	fcos
    	fstp qword [cos_angle]
	movsd	xmm8, [cos_angle]
	movsd	xmm9, [sin_angle]
	; Подготовка центров изображения
    	mov 	eax, edx
    	shr 	eax, 1
    	mov 	ebx, eax ; cx = w / 2
    	mov 	eax, ecx
    	shr 	eax, 1
    	mov 	ebp, eax ; cy = h / 2 TODO
	xor	r8, r8
.y_loop:
	cmp 	r8, rcx
	jge	.exit
	xor	r9, r9
.x_loop:
	cmp	r9, rdx
	jge	.y_next

	; coord proc
	mov 	eax, r9d
    	sub 	eax, ebx
    	cvtsi2sd xmm0, eax
    	mov 	eax, r8d
    	sub 	eax, ebp
    	cvtsi2sd xmm1, eax

	movapd 	xmm4, xmm0
    	mulsd xmm4, xmm2
    	movapd xmm5, xmm1
    	mulsd xmm5, xmm3
    	subsd xmm4, xmm5
	cvtsi2sd xmm6, ebx
 	addsd xmm4, xmm6

    	movapd xmm5, xmm0
    	mulsd xmm5, xmm3
    	movapd xmm6, xmm1
    	mulsd xmm6, xmm2
    	addsd xmm5, xmm6
	cvtsi2sd xmm7, ebp
    	addsd xmm5, xmm7

    	cvttsd2si r10d, xmm4
    	cvttsd2si r11d, xmm5

	; Проверка границ
    	cmp 	r10d, 0
    	jl 	.x_next
    	cmp 	r10d, edx
    	jge 	.x_next
    	cmp 	r11d, 0
    	jl 	.x_next
    	cmp 	r11d, ecx
    	jge 	.x_next

	; Индексирование и копирование пикселей
    	mov eax, r11d
    	imul eax, edx
    	add eax, r10d
    	shl eax, 2
   	mov r10d, eax

    	mov eax, r8d
    	imul eax, edx
    	add eax, r9d
    	shl eax, 2
    	mov r11d, eax

	mov al, [rdi + r10]
    	mov [rsi + r11], al
    	mov al, [rdi + r10 + 1]
    	mov [rsi + r11 + 1], al
    	mov al, [rdi + r10 + 2]
    	mov [rsi + r11 + 2], al
    	mov al, [rdi + r10 + 3]
    	mov [rsi + r11 + 3], al

.x_next:
    	inc r9
    	jmp .x_loop

.y_next:
    	inc r8
    	jmp .y_loop
.exit:
	ret

