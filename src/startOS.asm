global _start
section .text
_start:
	; for normal work of filesystem 
	call _checkFileSysExist
	test ax, ax
	jz filesysex
		call _formatDisk
	filesysex:
; beautiful picture
	call _outLogo
; because too small os for long loading
	mov cx, 0ffffh
	mov ax, 1000h
	delay:
			dec cx
			jnz $-1
		dec ax
	jnz delay
; set videomode for work in console
	mov bx, VIDEO_80x25 
	mov bx, [bx]
	mov di, VIDEO_MODE ; var with videomode
	mov word [di], bx
	mov ax, 3
	push ax
	call _setVideo
	add sp, 2
	xor dx, dx
start_os:
; main cicle in os
; if video isn't 80x25, set it
	mov ah, 0fh
	int 10h
	xor al, 3
	jnz filesysex
; set cursor where it must be
	mov ax, cs
	mov es, ax
	call _retCursor
	call _setCursor
; get command from user
	mov bx, 7
	mov ax, command
	push ax
	call _strIn
	add sp, 2
	call _nextLine

	call _saveCursor

	call _checkCommand

	jmp start_os
ret

_checkCommand:
	push bp
	mov bp, sp
	mov bx, command
	push bx
; get words for any parameters
	call _countWords
	pop bx
	push ax
	push bx
;	dec bx
;del spaces from begining
;	del_spaces:
;		inc bx
;		mov cl, [bx]
;		cmp cl, ' '
;	jz del_spaces
;	mov [esp], bx
; get command if more than 2 parameters
	cmp ax, 2
	js onlycommand
		mov bx, command-1
		getcommand:
			inc bx
			cmp byte [bx], ' '
		jnz getcommand
		mov byte [bx], 0
	onlycommand:

	jmp start_check

	comp_comm:
		push cx
		call _strcmp
		add sp, 2
		test ax, ax
	jmp bx
; checking in all list of commands
; check in programs if com "run"
	start_check:
	mov cx, getlen
	mov bx, $+5 ; to jnz
	jmp comp_comm
	jnz ch_countwords
		push last_command
		call _strlen
		add sp, 2
		mov bx, textlen
		jmp out_num

	ch_countwords:
	mov cx, countwords
	mov bx, $+5
	jmp comp_comm
	jnz ch_findchar
		push last_command
		call _countWords
		add sp, 2
		mov bx, numofw
		jmp out_num

	ch_findchar:
	mov cx, findchar
	mov bx, $+5
	jmp comp_comm
	jnz ch_stmem
		mov ax, [bp-2]
		cmp ax, 2
		jnz near com_not_found
		mov bx, last_command
		push bx
		mov bx, command
		mov bl, [bx+9]
		xor bh, bh
		push bx
		call _findChar
		add sp, 4
		mov bx, indexofchar
		jmp out_num

	ch_stmem:
	mov cx, stmem
	mov bx, $+5
	jmp comp_comm
	jnz ch_numoffloppy
		call _stmem
		mov bx, outstmem
		jmp out_num

	ch_numoffloppy:
	mov cx, numoffloppy
	mov bx, $+6
	jmp comp_comm
	jnz ch_neucheck
		call _getNumOfFloppy
		mov bx, outnumoffloppy
		jmp out_num

	ch_neucheck:
	mov cx, neucheck
	mov bx, $+6
	jmp comp_comm
	jnz ch_getallmem
		call _neucheck
		mov bx, outneucheck
		push bx
		jz nexneu
			mov byte [bx+13], 'Y'
		jmp neuoutch
		nexneu:
			mov byte [bx+13], 'N'
		neuoutch:
			call _retCursor
			call _strOut
			add sp, 2
			jmp end_of_check

	ch_getallmem:
	mov cx, getallmem
	mov bx, $+6
	jmp comp_comm
	jnz ch_getmonitortype
		call _getAllMem
		mov bx, outgetallmem
		jmp out_num

	ch_getmonitortype:
	mov cx, monitortype
	mov bx, $+6
	jmp comp_comm
	jnz ch_sizeofos
		call _getMonitorType
		push ax
		mov bx, outmonitortype
		push bx
		call _retCursor
		call _strOut
		add sp, 2
		call _strOut
		add sp, 2
		jmp end_of_check

	ch_sizeofos:
	mov cx, sizeofos
	mov bx, $+6
	jmp comp_comm
	jnz ch_getdiskinfo
		mov bx, outsizeofos
		mov ax, sizeofprogram
		jmp out_num

	ch_getdiskinfo:
	mov cx, diskinfo
	mov bx, $+6
	jmp comp_comm
	jnz ch_openfile
		call _outDiskInfo
		jmp end_of_check

	ch_openfile:
	mov cx, openfile
	mov bx, $+6
	jmp comp_comm
	jnz ch_format
		cmp word [bp-2], 2
		jnz near com_not_found
		mov ax, 2000h
		push ax
		mov ax, command+4
		push ax
		mov ax, 100h
		push ax
		call _openFile
		add sp, 6
		test ax, ax
	jnz near com_not_found
		push 2000h
		call _loadProgramFromAddr
		add sp, 2
		jmp end_of_check

	ch_format:
	mov cx, format
	mov bx, $+6
	jmp comp_comm
	jnz ch_floppytype
		call _formatDisk
		push formatout
		call _retCursor
		call _strOut
		add sp, 2
		jmp end_of_check

	ch_floppytype:
	mov cx, floppytype
	mov bx, $+6
	jmp comp_comm
	jnz ch_reboot
		call _retCursor
		push floppytypeout
		call _strOut
		call _getTypeOfFloppy
		mov [esp], ax
		call _strOut
		add sp, 2
		jmp end_of_check

	ch_reboot:
	mov cx, reboot
	mov bx, $+6
	jmp comp_comm
	jnz ch_help
		call _reboot

	ch_help:
	mov cx, help
	mov bx, $+6
	jmp comp_comm
	jnz com_not_found
		push help
		call _retCursor
		outcom:
			call _strOut
			call _nextLine
			mov si, [esp]
			findendofcom:
				inc si
				mov al, [si]
				test al, al
			jnz findendofcom
			inc si
			mov [esp], si
			cmp si, sizeofprogram
		jnz outcom
		add sp, 2
		jmp end_of_check



	out_num:
		push bx
		push ax
		mov ax, outtext
		push ax
		call _itoa
		add sp, 4

		call _retCursor

		call _strOut

		mov ax, outtext
		push ax
		call _strOut
		add sp, 4
	jmp end_of_check

	com_not_found:
		mov ax, comnotfound
		push ax
		call _retCursor

		call _strOut
		mov ax, command
		push ax
		call _strOut
		add sp, 4
	
	end_of_check:
	call _nextLine
	call _saveCursor
	push last_command
	call _copyStr ; save prev com
	call _timer ; refresh time
	add sp, 6
	pop bp
ret

_saveCursor:
	mov bx, crsr
	mov [bx], dx
ret

_retCursor:
	mov bx, crsr
	mov dx, [bx]
	call _setCursor
	mov bx, 2
ret

_nextLine:
	push bp
	mov si, VIDEO_MODE
	inc dh
	cmp dh, [si+1]
	jnz new_line
	; if cursor is on the edge of screen
		mov ax, 0601h
		xor cx, cx
		mov dl, [VIDEO_MODE+3]
		mov dh, [VIDEO_MODE+1]
		sub dx, 01h
		int 10h
	new_line:
	xor dl, dl
	call _setCursor
	pop bp
ret

_outDiskInfo:
	push bp
	mov bp, sp
	call _getDiskInfo
	push cx
	xor ax, ax
	mov al, dh
	push ax
	push outtext
	call _itoa
	add sp, 4

	call _retCursor
	push outdiskheads
	call _strOut
	push outtext
	call _strOut
	call _nextLine
	add sp, 4

	mov cx, [bp-2]
	mov al, ch
	mov ah, cl
	shr ah, 6
	and ah, 3
	push ax
	push outtext
	call _itoa
	add sp, 4

	push outdiskcylinders
	call _strOut
	push outtext
	call _strOut
	call _nextLine
	add sp, 4

	mov cx, [bp-2]
	and cx, 111111b
	mov [bp-2], cx
	push outtext
	call _itoa
	add sp, 4

	push outdisksectors
	call _strOut
	push outtext
	call _strOut
	add sp, 4
	pop bp
ret

_formatDisk:
	push bp
	xor ax, ax
	mov es, ax
	mov bx, 7e00h
	clrtempsector:
		mov byte [es:bx], 0ffh
		inc bx
		cmp bx, 8000h
	js clrtempsector
	mov bx, 7e00h
	mov ax, 0301
	mov cx, 1
	mov dx, 80h
	formathdd:
		inc cx
		int 13h
		cmp cx, 63
	jnz formathdd
; save first os 
	push _start
	push sizeofprogram
	push nameofos
	call _saveFile
	add sp, 6
	pop bp
ret

_reboot:
	xor sp, sp
	jmp 0000:7c00h
ret

_outLogo:
	push bp
	push 13h
	call _setVideo
; open picture in 3000h seg
	mov ax, 3000h
	push ax
	push logo
	push 0
	call _openFile
	add sp, 8
; copy palette from bmp
	mov ax, 3000h
	mov es, ax
	mov bx, 0ffh
	copy_palette:
		mov ax, bx
		mov dx, 3c8h
		out dx, al
		mov dx, 3c9h
		mov al, [es:ebx*4+56]
		shr al, 2
		out dx, al
		mov al, [es:ebx*4+55]
		shr al, 2
		out dx, al
		mov al, [es:ebx*4+54]
		shr al, 2
		out dx, al
		dec bx
	jnz copy_palette

	mov al, 1
	mov dx, 3c8h
	out dx, al
	xor ax, ax
	mov dx, 3c9h
	out dx, al
	out dx, al
	out dx, al

; copy picture to video
	mov bx, 1078+14400
	mov ax, 0a000h
	mov ds, ax
	mov bp, 9600
	mov di, 14400
	xor ah, ah
	movelogotovideo:
		mov si, 220
		movelineoflogo:
			mov al, [es:bx]
			cmp al, 1
			jz gowithoutchange
				mov [ds:bp+si], al
			gowithoutchange:
			dec si
			dec bx
			dec di
			cmp si, 100
		jnz movelineoflogo
		add bp, 320
		cmp di, 1
	jns movelogotovideo
	mov ax, cs
	mov ds, ax
	pop bp
ret

%include "video.asm"

%include "filesystem.asm"

%include "userprogram.asm"

%include "hardwarecheck.asm"

%include "time.asm"

%include "string.asm"

VIDEO_MODE dw 0
dw 0

VIDEO_80x25 db 80, 25
VIDEO_40x25 db 40, 25
VIDEO_320x240 dw 320, 240

time db 0,0

crsr dw 0 ; pointer of cursor

;strings 
logo db 'loglogo', 0
numofw db 'Number of words: ', 0
textlen db 'Lenght of text: ', 0
indexofchar db 'Char index in text: ', 0
comnotfound db 'Command not found: ', 0
outstmem db 'Standart memory (KB): ', 0
outnumoffloppy db 'Number of floppy drives: ', 0
outneucheck db 'Coprocessor: ', 0, 0
floppytypeout db 'Floppy type: ', 0
outgetallmem db 'Extended memory (KB): ', 0
outmonitortype db 'Monitor type: ', 0
outsizeofos db 'Size of OS (BYTES): ', 0
outhelp db 'Commands help list: ', 0
outdiskheads db 'Disk heads: ', 0
outdiskcylinders db 'Disk cylinders: ', 0
outdisksectors db 'Disk sectors: ', 0
nameofos db 'sysfile', 0
formatout db 'Formatting finished', 0
openfileerr db 'File not found: ', 0
outtext times 10 db 0
command times 200 db 0
last_command times 200 db 0

; commands
help db 'help', 0
openfile db 'run', 0
reboot db 'reboot', 0
format db 'format', 0
getlen db 'getlen', 0
countwords db 'countwords', 0
findchar db 'findchar', 0
stmem db 'stmem', 0
numoffloppy db 'numoffloppy', 0
neucheck db 'neucheck', 0
getallmem db 'getallmem (NOT WORKING)', 0
monitortype db 'monitortype', 0
sizeofos db 'sizeofos', 0
floppytype db 'floppytype', 0
diskinfo db 'diskinfo', 0

sizeofprogram db 0