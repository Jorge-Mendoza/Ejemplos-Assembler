;Navecita
;-------------------------------Macros----------------------------------------
%macro DivNumeros 2 	;1= LA CANTIDAD QUE LLEVA EL CRONOMETRO, 2 POSICION DONDE  QUIERO IMPRIMIRLO
	mov al,[%1]		;numero al registro al
	aam 		;Divide los numeros en digitos; al= unidades y ah=decenas
				;Preparamos la unidad para ser impresa, es decir le sumamos el ascii
	add al,30h
	mov [uni],al
	;Preparamos la decena para ser impresa, es decir le sumamos el ascii
	mov ah,30h
	mov [dece],ah
	Imprimir dece, %2+01h
	Imprimir uni, %2+02h
%endmacro
%macro Imprimir 2	;1= lo que se quiere imprimir, 2= corrimiento del cursor
	;Funcion 02h, interrupcion 10
	;correr el cursor n cantidad de veces
	;donde dl=N
	mov ah,02h
	mov bh,0	;pagina
	mov dh,0	;fila
	mov dl,%2	;columna
	int 10h
	;Imprimimos en consola
	mov dx,%1
	mov ah,09h
	int 21h
%endmacro
%macro MDibujarNave 1
	mov di,ax
	mov si,%1
	cld
	mov cx,8
	rep movsb
%endmacro
;------------------------------------------------------------------------------
org 100h
section .text
inicio:
	mov al,13h
	xor ah,ah	;Iniciando modo video
	int 10h

	;posicionar directamente a la memoria de video
	mov ax,0A00h
	mov es,ax
	xor di,di

mainLoop:
	mov bl,0 	;definiendo el color de fondo de mi pantalla
	call ClearScreen
	;_-----------Cronometro-----------------
	Tiempo:
		mov ax,[microsegundos]
		inc ax
		cmp ax,60
		je masSeg
		mov [microsegundos],ax
		jmp ImprimirTiempo
	masSeg:
		mov ax,[segundos]
		inc ax
		cmp ax,60
		je masMin
		mov [segundos],ax
		mov ax,0
		mov [microsegundos],ax
		jmp ImprimirTiempo
	masMin:
		mov ax,[minutos]
		inc ax
		mov [minutos],ax

		mov ax,0
		mov [segundos],ax
		mov [microsegundos],ax
	ImprimirTiempo:
		DivNumeros minutos, 1eh  	;Enviamos el numero a imprimir en pantalla y la posicion donde queremos que se muestre
		DivNumeros segundos, 21h
		DivNumeros microsegundos,024h
;-------------------------------Nave
mov ax,[CoordY]
mov bx,[CoordX]
call dibujarNave
call Flip
;---------------------------------Delay--------------------------
mov cx,0000h
mov dx,0ffffh
call Delay

call HasKey
jz mainLoop
call GetCh
cmp al,'b'
jne MOv1
;je finProg
;jmp mainLoop
finProg:
	mov ax,3h	;funcion para modo texto
	int 10h

	mov ax,4c00h 	;funcion para terminar el programa
	int 21h
MOv1:
	cmp al,'d'
	jne Mov2
	mov ax,[CoordX]
	inc ax
	mov [CoordX],ax
	jmp mainLoop
Mov2:
	cmp al,'a'
	jne Mov3

	mov ax,[CoordX]
	dec ax
	mov [CoordX],ax
	jmp mainLoop
Mov3:
	cmp al,'w'
	jne Mov4

	mov ax,[CoordY]
	dec ax
	mov [CoordY],ax
	jmp mainLoop
Mov4:
	cmp al,'s'
	jne mainLoop

	mov ax,[CoordY]
	inc ax
	mov [CoordY],ax
	jmp mainLoop
;--------------------------Subrutinas---------------------------------------------
ClearScreen:	;Limpiar la pantalla y pintarla de negro, procedimeitno directo a la memoria de video
	mov ax,ds	;Se apunto a data segment
	mov es,ax 	;Guardar la direccion base de datos
	mov di,buffer

	mov al,bl	;Pasando el color negro a la parte baja de ax
	mov ah,bl	;Pasando el color negro a la parte alta de ax

	shl eax,16	;shl hace un corrimiento para ir llenado, setteando el color negro en el registro
	mov al,bl
	mov ah,bl

	mov cx,16000	;64000 bytes/4 bytes por copia =16000
	rep stosd    	;ciclo "stro string double word" repertir 16000
	ret
;----------------------------------------------------------------------------------------
Delay:
	mov ah,86h
	int 15h
	ret
;---------------------------------------------------------------------------------
;--------------------------Leer el buffer de mi teclado--------------------

HasKey:
	push ax
	mov ah,01h
	int 16h
	pop ax
	ret
	;---------------------------------------------------------------------------
GetCh:
xor ah,ah
int 16h
ret
;---------------------------------------------------------------------------------
;bx=coordenada x
;ax=coordenada y
;y*320 +x =(x,y)
;10*320+10=3300
dibujarNave:
	push ax
	mov ax,ds 
	mov es,ax	;guardando la direccion base
	pop ax
	mov cx,bx	;coordenada en x
	shl cx,8
	shl bx,6
	add bx,cx 	;bx=320
	add ax,bx 	;sumar x a y
	add ax,buffer
	;mov di, ax 		; di=(10,10)=2332
	MDibujarNave naveFila1 	; pinta mi fila 1 en la posicion di
	add ax,320
	MDibujarNave naveFila2 	; pinta mi fila 1 en la posicion di
	add ax,320
	MDibujarNave naveFila3 	; pinta mi fila 1 en la posicion di
	add ax,320
	MDibujarNave naveFila4 	; pinta mi fila 1 en la posicion di
	add ax,320
	MDibujarNave naveFila5 	; pinta mi fila 1 en la posicion di
	add ax,320
	MDibujarNave naveFila6 	; pinta mi fila 1 en la posicion di
	add ax,320
	MDibujarNave naveFila7 	; pinta mi fila 1 en la posicion di
	;add ax,320
	ret
;---------------------------------------------------------------------------
;flip copiar de buffer a pantalla casi como un clearscreen mvsd ocmo stosd pero cpia de memoria a meoria
Flip:
	mov ax,0A000h
	mov es,ax

	mov di,0
	mov si,buffer
	mov cx,16000
	call VSync
	rep movsd
	ret
;----------------------------------------------------------------
VSync:
	mov dx,03dah
	WaitNotVSync:
		in al,dx
		and al,08h
		jnz WaitNotVSync
	WaitVSync:
		in al,dx
		and al,08
		jz WaitVSync
	ret

;--------------------------------------------------------------------------------
section .data
	;doble buffer
	;Variables de tipo entero
	buffer resb 64000   ;Se reserva una cantidada de espacios en la memoria, esta ocacion 64000 bytes de la seccion de datos
	microsegundos dw 0
	segundos dw 0
	minutos dw 0
	;varoabñes de tipo string
	uni db 0,'$'
	dece db 0,'$'
	;------------------ Varialbe que van a llevar la posicion de minave-------
	CoordX dw 180
	CoordY dw 140
	;--------Variables que pintan la nave
	naveFila1 DB 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
	naveFila2 DB 0 , 0 , 0 , 10 , 10 , 0 , 0 , 0 
	naveFila3 DB 0 , 7 , 10 , 10 , 10 , 10 , 7 , 0
	naveFila4 DB 0 , 0 , 10 , 15 , 15 , 10 , 0 , 0 
	naveFila5 DB 0 , 0 , 10 , 10 , 10 , 10 , 0 , 0 
    naveFila6 DB 0 , 7 , 10 , 10 , 10 , 10 , 7 , 0
    naveFila7 DB 0 , 10 , 10 , 10 , 10 , 10 , 10 , 0