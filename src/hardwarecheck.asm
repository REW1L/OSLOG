section .text

_getAllMem:
	mov al, 18h
	out 70h, al
	in al, 71h
	mov ah, al
	mov al, 17h
	out 70h, al
	in al, 71h
ret

_getTime:
	mov al, 4
	out 70h, al
	in al, 71h
	shl ax, 8
	mov al, 2
	out 70h, al
	in al, 71h
ret

_getMonitorType:
	mov al, 14h
	out 70h, al
	in al, 71h
	test al, 4
	jz monitor_doesnotexist
	shr al, 4
	and al, 3
	test al, al
	jnz secmontype
		mov ax, montypeegavga
		ret
	secmontype:
	cmp al, 1
	jnz thirdmontype
		mov ax, montypecga4025
		ret
	thirdmontype:
	cmp al, 2
	jnz fourthmontype
		mov ax, montypecga8025
		ret
	fourthmontype:
	cmp al, 3
	jnz monitor_doesnotexist
		mov ax, montypemda
		ret
	monitor_doesnotexist:
		mov ax, montypenotexist
ret

_neucheck:
	int 11h
	shr ax, 1
	and ax, 1
ret

_stmem:
	int 12h
ret

_getNumOfFloppy:
	int 11h
	mov dx, ax
	test dx, 1
	jnz floppy_exists
		xor ax, ax
	jmp getNumOfFloppy_end
	floppy_exists:
		shr ax, 6
		and ax, 3
		inc ax
	getNumOfFloppy_end:
ret

_getTypeOfFloppy:
	xor ax, ax 
	mov al, 10h
	out 70h, al
	in al, 71h
	test al, al
	jnz checksectypeoffloppy
		mov ax, floppytypenodrive
		ret
	checksectypeoffloppy:
	cmp al, 1
	jnz checkthirdtypeoffloppy
		mov ax, floppytype360kb
		ret
	checkthirdtypeoffloppy:
	cmp al, 2
	jnz checkfourtypeoffloppy
		mov ax, floppytype12mb
		ret
	checkfourtypeoffloppy:
	cmp al, 3
	jnz checkfivetypeoffloppy
		mov ax, floppytype720kb
		ret
	checkfivetypeoffloppy:
	cmp al, 4
	jnz exitofcheckingtypeoffloppy
		mov ax, floppytype144mb
		ret
	exitofcheckingtypeoffloppy:
	mov ax, floppytypeundefined
ret

_checkErrInMem:
	xor ax, ax
	mov al, 0eh
	out 70h, al
	in al, 71h
	shr al, 4
	and al, 1
ret

_checkStateOfKeyboard:
	xor ax, ax
	mov al, 14h
	out 70h, al
	in al, 71h
	shr al, 2
	and al, 1
ret

_getDiskInfo:
	push bp
	mov bp, sp
	mov ah, 8
	mov dl, 80h
	int 13h
	pop bp
ret

_setTime: ; func(int x)
	push bp
	mov bp, sp
	mov cx, [bp+4]
	mov al, 4
	out 70h, al
	mov al, ch
	out 71h, al
	mov al, 2
	out 70h, al
	mov al, cl
	out 71h, al
	pop bp
ret

;floppy types
floppytypenodrive db 'No Drive', 0
floppytype360kb db '360 KB 5 1/4 Drive', 0
floppytype12mb db '1.2 MB 5 1/4 Drive', 0
floppytype720kb db '720 KB 3 1/2 Drive', 0
floppytype144mb db '1.44 MB 3 1/2 Drive', 0
floppytypeundefined db 'Undefined', 0

;monitor types
montypeegavga db 'EGA/VGA', 0
montypecga4025 db '40x25 CGA', 0
montypecga8025 db '80x25 CGA', 0
montypemda db 'MDA', 0
montypenotexist db 'No Monitor', 0