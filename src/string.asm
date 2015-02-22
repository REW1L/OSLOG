section .text
_strcmp:; char func(char*, char*)
	push bp
	mov bp, sp
	mov di, [bp+4]
	mov si, [bp+6]
	xor ax, ax
	xor dx, dx
	compare_string:
		mov al, [es:di]
		mov dl, [ds:si]
		inc di
		inc si
		cmp al, dl
	jnz bad_end_comparing
		and al, dl
	jnz compare_string
	jmp good_end_comparing
	bad_end_comparing:
	xor ah, ah
	dec di
	mov al, [es:di]
	sub ax, dx
	good_end_comparing:
	pop bp
ret
_findChar:; func(char, char*)
	push bp
	mov bp, sp
	mov ax, [bp+4]
	mov bx, [bp+6]
	xor si, si
	find_char:
		mov ah, [bx+si]
		cmp ah, al
	jz end_of_findchar
		inc si
		test ah, ah
	jnz find_char
	mov si, 0ffffh
	end_of_findchar:
	mov ax, si
	pop bp
ret
_countWords: ; int func(char*)
	push bp
	mov bp, sp
	mov bx, [bp+4]
	mov dx, 0
	mov cx, 0
	mov ah, ' '
	miss_spaces:
		mov al, [bx]
		inc bx
		test al, al
	jz end_of_counting
		cmp al, ah
	jz miss_spaces
		inc cx
	continue_word:
		cmp al, ah
	jz miss_spaces
		test al, al
	jz end_of_counting
		mov al, [bx]
		inc bx
	jmp continue_word
	end_of_counting:
	mov ax, cx
	pop bp
ret


_itoa: ; func(int, char*)
	push bp
	mov bp, sp
; round to negative infinity for cut fraction part 
	push 1011100000000b
	push '0'
	xor si, si
	fldcw word [bp-2]
	mov word [bp-2], 10
	fild word [bp-2]
	fild word [bp+6]
	itoa_go:
		fprem
		fiadd word [bp-4]
		sub sp, 2
		mov di, sp
		fistp word [di]
		fild word [bp+6]
		fidiv word [bp-2]
		frndint
		fist word [bp+6]
		inc si
		mov ax, word [bp+6]
		test ax, ax
	jnz itoa_go
	mov di, [bp+4]
	itostrsave:
		pop ax
		mov [di], al
		inc di
		dec si
	jnz itostrsave
	mov byte [di], 0
	finit
	add sp, 4
	pop bp
ret

_strlen:; int func(char*)
	push bp
	mov bp, sp
	mov bx, [bp+4]
	xor si, si
	count_chars:
		mov al, [bx+si]
		inc si
		test al, al
	jnz count_chars
	mov ax ,si
	pop bp
ret

_strOut: ; void func(char*)
	push bp
	mov bp, sp
	mov bp, [bp+4]
	mov cx, 1
	mov al, [ds:bp]
	call _setCursor
	string:
		call _charOut
		inc bp
		mov al, [ds:bp]
		inc dl
		call _setCursor
		test al, al
	jnz string
	pop bp
ret

; only in textMode
_strIn: ; void func(char*)
	push bp
	mov bp, sp
	mov si, [bp+4]
	string_input:
		call _charIn
		cmp ah, 1ch
	jz end_input
		cmp ah, 0eh
	jz backsp
		mov cx, 1
		mov [si], al
		call _charOut
		inc si
		inc dl
		call _setCursor
	jmp string_input
	backsp:
		test dl, dl
	jz string_input
		mov al, 0
		dec si
		dec dl
		call _setCursor
		mov byte [si], 0
		call _charOut
	jmp string_input
	end_input:
	mov byte [si], 0
	pop bp 
ret

_bcdtostr: ;func (char x, char* str)
	push bp
	mov bp, sp
	mov ax, [bp+4]
	mov bp, [bp+6]
	mov cx, ax
	shr cx, 4
	add cx, '0'
	and ax, 15
	add ax, '0'
	mov [ds:bp], cl
	mov [ds:bp+1], al
	mov byte [ds:bp+2], 0
	pop bp
ret

_setTextColor: ; void func(int color)
	push bp
	mov bp, sp
	mov bl, [bp+4]
	pop bp
ret

_copyStr:; func(char*, char*)
	push bp
	mov bp, sp
	mov si, [bp+6]
	mov di, [bp+4]
	xor bp, bp
	copying:
		mov ax, [bp+si]
		mov [bp+di], ax
		inc bp
		test ax, ax
	jnz copying
	pop bp
ret

_charOut:
	mov ah, 9
	int 10h
ret

_getCursor:
	mov ah, 3
	int 10
ret

_charIn:
	mov ah, 0
	int 16h
ret

_setCursor:
	mov ah, 2
	int 10h
ret