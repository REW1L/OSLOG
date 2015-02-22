
section .text

_setVideo:
	push bp
	mov bp, sp
	mov ax, [bp+4]
	xor ah, ah
	int 10h
	pop bp
ret	

;clearing all video memory
_clearVideo: ; void func(void)
	mov di, 0
	mov ax, 0A000h
 	mov es, ax
 	mov al, 0
	clr:
		mov byte [es:di], al
		dec di
	jnz clr
ret

; in mode 13h

_drawRect: ;void func(int x, int y, int width, int height, int color, char fill)
	push bp
	mov bp, sp
	mov ax, [bp+0eh]
	test ax, ax
	jnz filledrect
		mov ax, [bp+0ch]
		push ax
		mov ax, [bp+4]
		mov bx, [bp+6]
		mov dx, [bp+0ah]
		add dx, bx
		push dx
		push ax
		push bx
		push ax
		call _drawVector
		mov ax, [bp+4]
		add ax, [bp+8]
		mov [esp], ax
		mov [esp+4], ax
		call _drawVector
		mov ax, [bp+4]
		mov [esp], ax
		mov ax, [bp+6]
		add ax, [bp+0ah]
		mov [esp+2], ax
		call _drawVector
		mov ax, [bp+6]
		mov [esp+2], ax
		mov [esp+6], ax
		call _drawVector
		add sp, 10
		jmp exitdrawingrect
	filledrect:
		mov ax, [bp+0ch]
		mov bx, [bp+6] ; y
		mov cx, [bp+8]
		add cx, [bp+4]
		push cx ; width
		push ax ; color
		mov ax, [bp+4] ; x
		mov dx, [bp+0ah] ; y1
		add dx, bx
		push dx
		push ax
		push bx
		push ax
		drawfilledrect:
			call _drawVector
			mov ax, [esp]
			inc ax
			mov [esp], ax
			mov [esp+4], ax
			cmp [esp+0ah], ax
		jns drawfilledrect
		add sp, 12
	exitdrawingrect:
	pop bp
ret

_setbackground: ; func(int segment)
	push bp
	mov bp, sp
	mov cx, ds
	mov ax, [bp+4]
	mov es, ax
	mov ax, 0a000h
	mov ds, ax
	xor bp, bp
	copysectortovideo:
		mov ax, [es:bp]
		mov [ds:bp], ax
		sub bp, 2
	jnz copysectortovideo
	pop bp
ret

_drawPixel:; func(x, y ,color)
	push bp
	mov bp, sp
	push 320
	mov ax, 0a000h
	mov es, ax
	fild word [bp+6]
	fimul word [bp-2]
	fiadd word [bp+4]
	fistp dword [bp-2]
	mov al, [bp+8]
	mov bp, [bp-2]
	mov [es:bp], al
	add sp, 2
	pop bp
ret

_drawVector:; func(char color, int y1, int x1, int y, int x)
	push bp
	mov bp, sp
	push si
; test horizontal line
	;mov word [bresincdec], 5657h
	mov byte [bresenhamincdec], 4fh
	;mov ax, [bp+4]
	;sub ax, [bp+8]
	;jns getabsY
	;	neg ax
	;getabsY:
	;mov bx, [bp+6]
	;sub bx, [bp+0ah]
	;jns checkwidthheight
	;	neg bx
	;checkwidthheight:
;
	;cmp ax, bx
	;jns checklineposition
	;	mov ax, [bp+4]
	;	mov bx, [bp+6]
	;	mov cx, [bp+8]
	;	mov dx, [bp+0ah]
	;	; ax=x0; bx=y0; cx=x1; dx=y1;
	;	mov [bp+4], bx
	;	mov [bp+6], ax
	;	mov [bp+8], dx
	;	mov [bp+0ah], cx
	;	;mov word [bresincdec], 5756h
	;checklineposition:

	mov ax, [bp+4]
	sub ax, [bp+8]
	neg ax
	jns checkY
		neg ax
		mov bx, [bp+4]
		mov cx, [bp+8]
		mov [bp+4], cx
		mov [bp+8], bx
		mov bx, [bp+6]
		mov cx, [bp+0ah]
		mov [bp+6], cx
		mov [bp+0ah], bx
	checkY:
	mov bx, [bp+6]
	sub bx, [bp+0ah]
	jns checkZero
		neg bx
		mov byte [bresenhamincdec], 47h
	checkZero:
	test ax, ax
	jz notchangedop
	test bx, bx
	jz notchangedop

; Bresenham's algorithm ; bx - deltay, ax - deltax
	xor cx, cx ; error
	mov si, [bp+4] ; x0
	mov di, [bp+6] ; y0
	mov dx, [bp+0ch] ; color
	push ax
	push dx
	push di
	;bresincdec dw 5657h ; push di, push si
	push si
	mov dx, [bp+8]
	drawBresenhamsLine:
		call _drawPixel
		add cx, bx
		shl cx, 1
		cmp cx, [esp+6]
		js iteration_brline
			shr cx, 1
			bresenhamincdec db 47h
			mov [esp+2], di
			sub cx, [esp+6]
			jmp noneedtoshr
		iteration_brline:
		shr cx, 1
		noneedtoshr:
		inc si
		mov [esp], si
		cmp si, dx
	jnz drawBresenhamsLine
	add sp, 8
	jmp exitdrawingline

; not diagonal lines
	notchangedop:
	cmp ax, bx
	jz drawpoint
	mov si, [bp+6]
	mov di, [bp+4]
	mov cx, [bp+0ah]
	mov dx, [bp+8]
	test ax, ax
	jz notchangedX
	test bx, bx
	jz notchangedY

;vertical line
	notchangedX:
	mov bx, si
	cmp di, dx
	jns y1biggerthany
		mov ax, di
		mov di, dx
		mov dx, ax
	y1biggerthany:
		mov dx, 2

	preparetodrawverticalline:
	mov ax, [bp+0ch]
	push ax
	push si
	push di
	inc cx
	drawverticalline:
		call _drawPixel
		inc bx
		mov [esp+edx], bx 
		cmp bx, cx
	jnz drawverticalline
	add sp, 6
	jmp exitdrawingline

; horizontal line
	notchangedY:
	cmp cx, si
	jns x1biggerthanx
		mov ax, si
		mov si, cx
		mov cx, ax
	x1biggerthanx:
	mov bx, di
	mov cx, dx
	xor dx, dx
	jmp preparetodrawverticalline

	drawpoint:
		mov ax, [bp+0ch]
		push ax
		mov ax, [bp+6]
		push ax
		mov ax, [bp+4]
		push ax
		call _drawPixel
		add sp, 6

	exitdrawingline:
	pop si
	pop bp
ret