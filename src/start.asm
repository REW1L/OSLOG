BITS 16
org 0x7c00
global _start
section .text
_start:
	
; set videomode 80x25
	mov ax, 3 
	int 10h

; set cursor in center of screen
	mov ah, 2 
	mov bh, 0
	mov dx, 0C2Ch
	int 10h

; out loader string
	mov cx, 1 
	mov si, 9
	mov bl, 9
	mov bp, titl
	print_title:
		mov ah, 9
		mov al, [bp+si]
		int 10h
		mov ah, 2
		dec dx
		int 10h
		dec si
	jnz print_title

; set cursor after string for beauty
	mov ah, 2
	mov dx, 0C2Dh 
	int 10h

; copying new program in RAM
	mov ax, 020ah ; func for copy into RAM, 10 sections
	mov cx, 2
	mov bx, 1000h
	mov es, bx
	xor bx, bx
	mov dx, 180h; head = 0, disk = 0
	int 13h

	mov ax, 1
	mov al, '!'
	mov ah, 9
	mov cx, 1
	mov bl, 5
	int 10h
	mov ax, 1000h
	mov ds, ax
	mov ss, ax
	xor bx, bx
	jmp 1000h:0000h
ret


titl db ' LOADER...', 0

times 510-($-$$) db 0

dw 0AA55h
