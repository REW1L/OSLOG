global _start
org 100h
section .text
_start:
	push bp
	mov bp, sp
	push 13h
	call _setVideo
	add sp, 2
; paint window
	push 0
	push 9
	push 180
	push 300
	push 10
	push 10
	call _drawRect
	add sp, 12
	mov dx, 210h
	call _setCursor
	mov bx, 8
; set title
	push window
	call _strOut
; draw separators
	push 9
	push 30
	push 310
	push 30
	push 10
	call _drawVector
	mov word [esp+2], 130
	mov word [esp+6], 130
	call _drawVector
	add sp, 12
	push 1
	push 151
	push 40
	push 50
	push 80
	push 30
	drawbuttons:
		call _drawRect
		mov si, [esp]
		add si, 70
		mov [esp], si
		cmp si, 300
	js drawbuttons
	add sp, 12
; write captions for buttons
	mov dx, 0c05h
	call _setCursor
	mov bx, 15
	push stat
	call _strOut
	mov dx, 0c0dh
	call _setCursor
	mov word [esp], typemon
	call _strOut
	mov dx, 0c16h
	call _setCursor
	mov word [esp], time
	call _strOut
	mov dx, 0c1fh
	call _setCursor
	mov word [esp], exit
	call _strOut
	add sp, 2

	push 1 ; variable for status of selected button
	mov si, 1
	maincicle:
		xor ax, ax
		int 16h
		cmp ah, 4dh
		jnz checkleftarrow
			mov si, [esp]
			inc si
			mov [esp], si
			jmp endcheckkeys
		checkleftarrow:
		cmp ah, 4bh
		jnz checkenter
			mov si, [esp]
			dec si
			mov [esp], si
			jmp endcheckkeys
		checkenter:
		cmp ah, 1ch
		jnz maincicle
			jmp btnpushed
		endcheckkeys:
		cmp si, 5 ; only 4 buttons
		js silowerthan5
			mov si, 1
			mov [esp], si
		silowerthan5:
		test si, si ; better ux
		jnz siisnotzero
			mov si, 4
			mov [esp], si
		siisnotzero:
		selectbtn:
			call _setAllBtnsDeselected
			mov si, [esp]
			cmp si, 1
			jnz select2
				push 30
				call _selectBtn
				jmp endselectbtn
			select2:
			cmp si, 2
			jnz select3
				push 100
				call _selectBtn
				jmp endselectbtn
			select3:
			cmp si, 3
			jnz select4
				push 170
				call _selectBtn
				jmp endselectbtn
			select4:
			cmp si, 4
			jnz endselectbtn
				push 240
				call _selectBtn
		endselectbtn:
		add sp, 2
	jmp maincicle
		btnpushed:
	; clear output part
			push 1
			push 0
			push 38
			push 278
			push 131
			push 11
			call _drawRect
; set cursor place on start of output part
			add sp, 12
			mov dx, 1203h
			call _setCursor
			mov bx, 5
			mov si, [esp]
			cmp si, 1
			jnz near secbtnpushed
; output status of many things
				push keyboard
				call _strOut
				call _checkStateOfKeyboard
				test ax, ax
				jnz keyboardYES
					mov word [esp], no
					jmp endkeyboardcheck
				keyboardYES:
					mov word [esp], yes
				endkeyboardcheck:
				call _strOut
				call _nextLine

				mov word [esp], mathcop
				call _strOut
				call _neucheck
				test ax, ax
				jnz neuexists
					mov word [esp], no
					jmp endofcheckneu
				neuexists:
					mov word [esp], yes
				endofcheckneu:
				call _strOut
				call _nextLine

				mov word [esp], memerr
				call _strOut
				call _checkErrInMem
				test ax, ax
				jnz errexist
					mov word [esp], no
					jmp endofcheckerr
				errexist:
					mov word [esp], yes
				endofcheckerr:
				call _strOut
				add sp, 2
				jmp maincicle
			secbtnpushed:
			cmp si, 2
			jnz thirbtnpushed
; output other stats
				push floptype
				call _strOut
				call _getTypeOfFloppy
				mov [esp], ax
				call _strOut
				call _nextLine
				mov word [esp], montype
				call _strOut
				call _getMonitorType
				mov [esp], ax
				call _strOut
				add sp, 2
				jmp maincicle
			thirbtnpushed:
; btn for time
			cmp si, 3
			jnz near fourbtnpushed
				push changetime
				call _strOut
				add sp, 2
				call _getTime ;getting time
				mov [nowtime], ax ; saving time
; get str of hours and mins
				mov cx, ax 
				and cx, 15
				shr ax, 8
				push timehour
				push ax
				call _bcdtostr
				mov [esp], cx
				mov word [esp+2], timemin
				call _bcdtostr
				add sp, 4
				push 0 ; mins/hours
				mov dx, 1213h
				cicleforchangetime:
					mov si, [esp]
					push dx
	; select mins/hours
					test si, si
					jnz changingmin
						mov bx, 7
						call _outHours
						mov bx, 8
						call _outMins
						jmp listenkeyboard
					changingmin:
						mov bx, 8
						call _outHours
						mov bx, 7
						call _outMins
	;change time on key press
					listenkeyboard:
						pop dx
						mov ah, 0
						int 16h
						entertimebtn:
						cmp ah, 1ch
						jnz esctimebtn
	; save time on enter
							mov ax, [nowtime]
							push ax
							call _setTime
							add sp, 4
							jmp maincicle
						esctimebtn:
						cmp ah, 1
						jnz checknumberinput
	; don't save time on esc and clear output
							push 1
							push 0
							push 38
							push 278
							push 131
							push 11
							call _drawRect
							add sp, 14
							jmp maincicle
						checknumberinput:
	;not good ux, but it works
	; check if user pushed button with number and if this num is correct
						cmp al, '0'
						js cicleforchangetime
						cmp al, ':'
						jns cicleforchangetime
						cmp dl, 13h
						jnz chklstnumofhour
							cmp al, '3'
							jns cicleforchangetime
							mov ah, [nowtime+1]
							and ah, 1111b
							sub al, '0'
							shl al, 4
							or ah, al
							mov [nowtime+1], ah
							inc dl
							jmp cicleforchangetime
						chklstnumofhour:
						cmp dl, 14h
						jnz chkfrstnumofmin
							mov ah, [nowtime+1]
							cmp ah, 20h
							js normfb
								cmp al, '4'
								js normfb
									mov al, '3'
							normfb:
							and ah, 0f0h
							sub al, '0'
							or ah, al
							mov [nowtime+1], ah

							inc dl
							mov si, [esp]
							not si
							mov [esp], si
							jmp cicleforchangetime
						chkfrstnumofmin:
						cmp dl, 15h
						jnz chksecnumofmin
							cmp al, '6'
							jns cicleforchangetime
							mov ah, [nowtime]
							and ah, 0fh
							sub al, '0'
							shl al, 4
							or ah, al
							mov [nowtime], ah
							inc dl
							jmp cicleforchangetime
						chksecnumofmin:
						cmp dl, 16h
						jnz cicleforchangetime
							sub al, '0'
							mov ah, [nowtime]
							and ah, 0f0h
							or ah, al
							mov [nowtime], ah
							mov dl, 13h
							mov si, [esp]
							not si
							mov [esp], si
							jmp cicleforchangetime

			fourbtnpushed:
			cmp si, 4
			jnz maincicle
	; exit from program
				add sp, 2
				pop bp
				ret
	jmp maincicle
ret

_outHours:
	xor ax, ax
	mov al, [nowtime+1] ; get mins in bcd
	push timehour
	push ax
	call _bcdtostr ; convert bcd to str
	add sp, 2
	mov dx, 1210h
	call _setCursor ; print hours
	call _strOut
	add sp, 2
ret
_outMins:
	xor ax, ax
	mov al, [nowtime]
	push timemin
	push ax
	call _bcdtostr
	add sp, 2
	mov dx, 1213h
	call _setCursor
	call _strOut
	add sp, 2
ret

_selectBtn: ; func(int x)
	push bp
	mov bp, sp
	mov ax, [bp+4]
; set border in light colors
	push 0
	push 10
	push 40
	push 50
	push 80
	push ax
	call _drawRect
	add sp, 12
	pop bp
ret

_setAllBtnsDeselected:
	push bp
	mov bp, sp
	push 0
	push 151
	push 40
	push 50
	push 80
	push 30
	drawdeselect:
		call _drawRect
		mov si, [esp]
		add si, 70
		mov [esp], si
		cmp si, 300
	js drawdeselect
	add sp, 12
	pop bp
ret

_nextLine:
	inc dh
	mov dl, 3
	call _setCursor
ret

nowtime db 0, 0
timemin db '  ', 0
timehour db '  ', 0


montype db 'Monitor type: ', 0
keyboard db 'Keyboard: ', 0
mathcop db 'Coprocessor: ', 0
memerr db 'Memory error: ', 0
floptype db 'Floppy type: ', 0
yes db 'YES', 0
no db 'NO', 0
changetime db 'Change time:   :', 0

window db 'Window', 0
stat db 'Stat', 0
typemon db 'MType', 0
time db 'STime', 0
exit db 'Exit', 0

%include "hardwarecheck.asm"
%include "video.asm"
%include "string.asm"