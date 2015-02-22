section .text

_loadProgramFromAddr: ; func(int cs)
	push bp
	mov bp, sp

	mov ax, [bp+4]
	mov es, ax
	mov word [cs:segoff], ax

	xor bp, bp ; copying regs for return
	mov [es:bp+32], cs
	mov [es:bp+34], ds
	mov [es:bp+36], ss
	mov [es:bp+38], sp

	mov word [es:bp+40], exfromprog ; copy offset to return
	mov word [es:bp+42], 1000h ; copy segment of os

	mov bx, _exitprogram ; copying exit func into new segment
	xor si, si
	createexit:
		mov dl, [cs:bx+si]
		mov [es:bp+si], dl
		inc si
		cmp dl, 0c3h
	jnz createexit

	mov ds, ax ; changing segment regs
	mov ss, ax
	mov sp, 0ffffh ; change sp for new prog
	push 0 ; push addres of return

	jmp far [cs:insoff] ; far jump to user program
	exfromprog:
	call _retCursor
	pop bp
ret

insoff dw 100h
segoff dw 0

_exitprogram: ; copying all for os
	xor bx, bx
	mov ax, [cs:bx+32]
	mov es, ax
	mov ax, [cs:bx+34]
	mov ds, ax
	mov ax, [cs:bx+38]
	mov sp, ax
	mov ax, [cs:bx+36]
	mov ss, ax
	jmp far [cs:bx+40] ; jump to return to os
ret

