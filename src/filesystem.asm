section .text
_openFile: ; func(void* buffer, char* name, int segment)
	push bp
	mov bp, sp
	mov si, [bp+6]
	xor bx, bx
	mov es, bx
	mov bx, 200h
	clearbuff:
		mov word [bx+7e00h], 0
		sub bx, 2
	jns clearbuff
	mov bx, 7e00h
	mov cx, 1
	push si
	getfileptr:
		mov dx, 80h
		mov ax, 0201h
		inc cx
		int 13h
		checksector:
			push bx
			call _strcmp
			add sp, 2
			test ax, ax
		jz endfinding
			add bx, 16
			cmp bx, 8000h
		jnz checksector
		cmp cx, 63
	jnz getfileptr
		mov ax, 1
		jmp exitfromopeningfile
	endfinding:
	mov ax, [bp+4]
	push ax
	mov ax, [es:bx+14]
	add ax, 7
	push ax
	mov ax, [es:bx+12]
	push ax
	call _prepareFor13h
	mov si, [bp+8]
	mov es, si
	mov ah, 2
	int 13h

	mov ax, 0
	add sp, 6
	exitfromopeningfile:
	add sp, 2
	pop bp
ret

_saveFile: ; func(void* ptr, int size, char* name)
	push bp
	mov bp, sp
	sub sp, 4
	mov dword [bp-2], 0
	mov dword [bp-4], 0
	mov cx, 2 ; copying from second section 
	xor si, si
	checkplace:
		mov ax, 0201h
		mov es, si
		mov bx, 7E00h
		mov dx, 80h; head = 0, disk = 0
		int 13h
		mov bx, 7DF0h
		checkinsection:
			add bx, 16
			mov ax, [es:bx]
			test ax, ax
		jz foundplace
			mov ax, [es:bx+14]
			mov [bp-2], ax
			mov ax, [es:bx+12]
			mov [bp-4], ax
			cmp bx, 8000h
		jnz checkinsection
		inc cx
		cmp cx, 11
	jnz checkplace
		mov ax, 1
		ret
	foundplace:
	xor si, si
	mov di, [bp+4]
	savename:
		mov al, [di]
		mov [es:bx+si], al
		inc si
		inc di
		test al, al
	jz savezeros
		cmp si, 12
	jnz savename
	mov al, 0
	savezeros:
		mov [es:bx+si], al
		inc si
		cmp si, 12
	jnz savezeros
	savesize:
	mov di, [bp+6]
	mov [es:bx+si], di
	
	xor di, di
	mov ax, [bp-4]
	takesizeinclusters:
		inc di
		sub ax, 4097
	jns takesizeinclusters

	add di, [bp-2]

	add si, 2
	mov [es:bx+si], di
	add di, 7

;saveTable
	xor ax, ax
	mov ax, 0301h
	mov bx, 7e00h
	int 13h

	mov bx, [bp+8]
	push bx
	push di
	mov ax, [bp+6]
	push ax
	mov ax, ds
	mov es, ax
	call _prepareFor13h

	mov ah, 3
	int 13h

	add sp, 10
	pop bp
ret


_prepareFor13h: ; func(int* buf, int placeinclusters, int size)
	push bp
	mov bp, sp
	sub sp, 8
	; start of getting place
	mov word [bp-6], 1011100000000b
	fldcw word [bp-6]

; getting max cyls
	mov ah, 8
	int 13h
	mov al, ch
	mov ah, cl
	shr ah, 6
	mov ch, dh
	and ch, 11
	
	mov word [bp-6], cx
	fild word [bp-6] ; load max num of sectors
	mov [bp-6], ax
	mov di, [bp+6] ; load place in clusters
	mov [bp-8], di
	mov ax, 1 ; for repeating parts
	savefileneuwork:
		fild word [bp-8] ; location in clusters
		mov word [bp-4], 8 ; for size in sectors 
		fimul word [bp-4] ; get size in sectors
		test ax, ax
	jz get_final_heads
		fprem ; get final sector
		fistp word [bp-2] ; save final sector
		mov cx, [bp-2]
		mov dh, cl
		shr dh, 6
		and cx, 111111b ; save final sector for int 13h
		dec ax
		jmp savefileneuwork
	get_final_heads:
		fdiv st1 ;get place in cylinders
		frndint ; they should be int
		fist word [bp-2] ; save num of cyls

		fidiv word [bp-6] ; get num of heads
		frndint ; heads in int
		fistp word [bp-4] ; save num of heads
		mov ah, [bp-4] ; save num of heads for int 13h
		shl ah, 2
		or dh, ah
	;get_final_cyls:
		fild word [bp-6] ; load max num of cyls
		fild word [bp-2] ; load num of cyls in neu
		fprem ; get final num of cyls
		fistp word [bp-2] ; save num of cyls
		mov ax, [bp-2] ; magic for normal work with cyls
		and ah, 11b
		shl ah, 6
		mov ch, al ; save cyls for int 13h
		or cl, ah
		add cl, 2
	finit
;end of getting place

	mov ax, [bp+4]
	xor si, si
	takesizeinsectors:
		inc si
		sub ax, 513
	jns takesizeinsectors
	
	mov ax, si
	mov dl, 80h
	mov bx, [bp+8]
; end of preparing to 13h
	add sp, 8
	pop bp
ret

_checkFileSysExist:
	mov ax, 0201h ; func for copy into RAM, 6 sections
	mov cx, 2
	xor bx, bx
	mov es, bx
	mov bx, 7e00h
	mov dx, 80h; head = 0, disk = 0
	int 13h
	test byte [es:bx], 0ffh
	jnz filesystex
		mov ax, 1
		ret
	filesystex:
	mov ax, 0
ret

%ifdef _strcmp
_strcmp:; char func(char*, char*)
	push bp
	mov bp, sp
	mov di, [bp+4]
	mov si, [bp+6]
	xor ax, ax
	xor dx, dx
	compare_string:
		mov al, [es:di]
		mov dl, [cs:si]
		inc di
		inc si
		test al, dl
	jz end_comparing
		cmp al, dl
	jz compare_string
	sub ax, dx
	end_comparing:
	pop bp
ret
%endif