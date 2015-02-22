section .text

_timer:
	push bp
	mov ah, 2
	int 1ah
	mov ax, 0b800h
	mov es, ax
	mov bp, 148
	mov si, 12
	mov byte [es:bp+4], ':'
	mov byte [es:bp+5], 7
	mov byte [es:bp+1], 7
	mov byte [es:bp+3], 7
	mov byte [es:bp+7], 7
	mov byte [es:bp+9], 7
	mov dl, ch
	shr dl, 4
	add dl, '0'
	mov [es:bp], dl
	mov dl, ch
	and dl, 0fh
	add dl, '0'
	mov [es:bp+2], dl
	mov dl, cl
	shr dl, 4
	add dl, '0'
	mov [es:bp+6], dl
	mov dl, cl
	and dl, 0fh
	add dl, '0'
	mov [es:bp+8], dl
	pop bp	
ret

