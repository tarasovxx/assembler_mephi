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
xc resq 1
yc resq 1
x0 resq 1
y0 resq 1

section	.text
work_image_asm:
    	; rdi = src, rsi = dst, rdx = w, rcx = h, r8 - new_w, r9 - new_h, xmm0 = angle_RAD
	or	edx, edx
	jle	.exit
	or	ecx, ecx
	jle	.exit
	or      r8, r8
        jle     .exit
	or      r9, r9
	jle     .exit
	;movsd 	xmm8,[DEG_TO_RAD]
	;mulsd	xmm8, xmm0 ; xmm0 angle rad
	;movsd 	xmm9, xmm8
	; Вычисление угла в радианах
    	;movsd xmm1, [DEG_TO_RAD]
   	;mulsd xmm0, xmm1
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
	;cvtss2sd r14, xmm8
	;cvtss2sd r15, xmm9
	; Подготовка центров изображения
    	mov 	eax, edx
    	shr 	eax, 1
    	mov 	ebx, eax ; xc = w / 2
	mov 	[xc], ebx
    	mov 	eax, ecx
    	shr 	eax, 1
    	mov 	r10d, eax ; yc = h / 2 
	mov	[yc], r10d
	mov 	eax, r8d
    	shr 	eax, 1
    	mov 	r11d, eax ; x0 = new_w / 2
	mov 	[x0], r11d
    	mov 	eax, r9d
    	shr 	eax, 1
    	mov 	r12d, eax ; y0 = new_h / 2 
	mov	[y0], r12d
	xor	r13, r13 ; ptrY
.y_loop:
	cmp 	r13, r9
	jge	.exit
	xor	r14, r14 ; ptrX
.x_loop:
	cmp	r14, r8
	jge	.y_next

	; coord proc
	mov	r11, r13 ;y
	mov	r12, r14 ;x
    	sub 	r12, [x0]
    	sub 	r11, [y0]
	cvtsd2si r10, xmm8 ;cos
	cvtsd2si r15, xmm9 ;sin
	mov	rax, r10
	imul 	rax, r12
	mov	rbx, r15
	imul	rbx, r11
	sub	rax, rbx
	add	rax, [xc] ; eax - srcX
	imul	r15, r12
	imul	r10, r11
	add 	r10, r15 ;r11
	add	r10, [yc] ; r10 - srcY
	
	; Проверка границ
    	cmp 	rax, 0
    	jl 	.x_next
    	cmp 	rax, rdx
    	jge 	.x_next
    	cmp 	r10, 0
    	jl 	.x_next
    	cmp 	r10, rcx
    	jge 	.x_next

	; Индексирование и копирование пикселей
    	mov 	rbx, r10
    	imul 	rbx, rdx
    	add 	rbx, rax
    	shl 	rbx, 2 ; ebx - srcIndex
   	;mov r10d, eax 

    	;mov eax, r8d
	mov 	rax, r13
    	imul 	rax, r8
    	add 	rax, r14
    	shl 	rax, 2 ; eax - dstIndex
    	;mov r11d, eax
.write:
	mov al, [rdi + rbx]
    	mov [rsi + rax], al
    	mov al, [rdi + rbx + 1]
    	mov [rsi + rax + 1], al
    	mov al, [rdi + rbx + 2]
    	mov [rsi + rax + 2], al
    	mov al, [rdi + rbx + 3]
    	mov [rsi + rax + 3], al

.x_next:
    	inc r14
    	jmp .x_loop

.y_next:
    	inc r13
    	jmp .y_loop
.exit:
	ret

