;Proyecto

;------------------------------------------------------
;Macros

%macro print 1
	mov dx,%1	; dx = cadena a imprimir
	mov ah,9	; ah = 9 = funcion para imprimir en consola una cadena
	int 21h		; imprimiendo
%endmacro

%macro ObtenerTexto 1  ;Obtiene texto ingresado desde teclado hasta llegar a un salto de linea
	xor si,si
	%%ObtenerChar:
		call getChar
		cmp al,0dh
		je %%FinOt

		mov %1[si],al
		inc si
		jmp %%ObtenerChar
	%%FinOt:
		mov al,24h   ;ascii de $ en hex
		mov %1[si],al
%endmacro
%macro AbrirF 1
	%%abrirF:
		mov ah,3dh
		mov al,010b
		mov dx,%1
		int 21h

		jc %%Error1
		mov bx,ax
		jmp %%Fin
	%%Error1:
		print msgError1
		call cerrarF
	%%Fin:

%endmacro
%macro leerF 1
	%%leer:
	;mov bx,ax
	mov ah,3fh
	mov dx,lectura

	mov cx,100
	int 21h

	jc %%Error2
	cmp ax,0
	jz %%Fin
	
	;concatenar lectura,guardado
	;%%Limpiando:
	print lectura
	;mov si,limpiar
	;mov di,lectura
	;mov cx,10
	;rep movsb
	jmp %%leer

	jmp %%Fin

	%%Error2:
		print msgError2
		;call cerrarF
	%%Fin:
	print CRLF
	print lectura
	print CRLF
	;call cerrarF

%endmacro
%macro escribirF 2
	mov ah,40h
	mov bx,ax
	mov cx,%1
	mov dx,%2
	int 21h
	jc %%Error3
	jmp %%Fin

	%%Error3:
		print CRLF
		print msgError3
		print CRLF
		;call cerrarF
	%%Fin:
		call cerrarF

%endmacro
%macro concatenar 2
	mov si,0
	mov di,0
	%%recorrer:
		mov al,%1[si]
		cmp al,36
		je %%concatenacion
		inc si
		jmp %%recorrer
	%%concatenacion:
		mov bl,%2[di]
		cmp bl,36
		je %%Terminar
		mov %1[si],bl
		inc si
		inc di
		jmp %%concatenacion
	%%Terminar:
		mov al,bl
		print CRLF
		print CRLF
		print %1
		print CRLF
		print CRLF
%endmacro
%macro comparar 2
	mov si,0
	
	%%recorriendo:
		mov al,%2[si]
		cmp %1[si],al
		jne %%fin
		cmp al,36
		jz %%final
		inc si
		jmp %%recorriendo
		%%final:
			print CRLF
			print prueba1
			print CRLF
			print prueba2
			print CRLF
		%%fin:
%endmacro
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
;------------------------------------------------------

;Segmento de data
section .data
	
	msg1M1 db '1. Ingresar  $'
	msg2M1 db '2. Registrar  $'
	msg3M1 db '3. Salir $'
	msg1M2 db '1. Top 10 puntos $'
	msg2M2 db '2. Salir $'
	msgUs db 'Ingrese el usuario: $'
	msgPw db 'Ingrese la contrasenia: $'
	msgLog db 'Inicar sesion..... $'
	msgReg db 'Registro de jugador..... $'
	msgError1 db 'ERROR: No se ha podido abrir el archivo $'
	msgError2 db 'ERROR: No se ha podido leer el archivo $'
	msgError3 db 'ERROR: No se ha podido escribir el archivo... $'
	msgError4 db 'ERROR: No se ha podido crear el archivo $'
	CRLF db 0dh,0ah,'$'
	Peticion db 'Ingresar una de las opciones:  $'
	Encabezado1 dq 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',10,13,'FACULTAD DE INGENIERIA',10,13,'CIENCIAS Y SISTEMAS',10,13,'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1',10,13,'NOMBRE: JORGE FERNANDO MENDOZA ESPINOZA',10,13,'CARNET: 201603184',10,13,'SECCION: A',10,13,'$'
	userN db 10 dup('$'),'$'
	passwN db 10 dup('$'),'$'
	usuarios db 'usuarios.txt $'
	lectura times 12 dq '$'
	limpiar times 12 dw '$'
	lenUs equ $- userN -1
	lenPw equ $- passwN -1
	guardado times 50 dw '$'
	;---------------------------------Variables del modo video----------------------
	buffer resb 64000
	microsegundos dw 0
	segundos dw 0
	minutos dw 0

	uni db 0,'$'
	dece db 0,'$'
	;-------Posicion del carrito
	coordX dw 180
	coordY dw 140
	;------Posicion de los obstaculos
	posOb dw 0
	;----------------------------------------------------------------------
	;--------Variables que pintan la nave
	naveFila1 DB 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
	naveFila2 DB 0 , 0 , 0 , 10 , 10 , 0 , 0 , 0 
	naveFila3 DB 0 , 7 , 10 , 10 , 10 , 10 , 7 , 0
	naveFila4 DB 0 , 0 , 10 , 15 , 15 , 10 , 0 , 0 
	naveFila5 DB 0 , 0 , 10 , 10 , 10 , 10 , 0 , 0 
    naveFila6 DB 0 , 7 , 10 , 10 , 10 , 10 , 7 , 0
    naveFila7 DB 0 , 10 , 10 , 10 , 10 , 10 , 10 , 0
	;---------------------------------------------------------

;Segmento de codigo
org 100h
section .text

Inicio:
	print msg1M1
	print CRLF
	
	print msg2M1
	print CRLF
	
	print msg3M1
	print CRLF
	
	print Peticion
	
	print CRLF
	

	call getChar
	
	sub al,48		; convirtiendo ascii a decimal y guardandolo en al
	
	cmp al,1		; comparar si se ingreso opc 1
	je Op1			; si se ingreso 1, me voy a opc 1
	cmp al,2		; comparar si se ingreso opc 2
	je Op2			; si se ingreso 2, me voy a opc 2
	cmp al,3		; comparar si se ingreso opc 3
	je Op3			; si se ingreso 3, me voy a opc 3
	
	
	jmp Inicio
	
Op2:
	print CRLF
	print msgReg
	print CRLF
	print msgUs
	print CRLF
	ObtenerTexto userN
	print msgPw
	print CRLF
	ObtenerTexto passwN
	print CRLF
	AbrirF usuarios
	leerF usuarios
	;print CRLF
	;escribirF lenUs,userN
	;AbrirF usuarios
	;leerF usuarios
	;print CRLF
	;escribirF lenPw,passwN
	jmp Inicio
Op1:
	print CRLF
	print msgLog
	print CRLF
	print msgUs
	print CRLF
	ObtenerTexto userN
	print msgPw
	print CRLF
	ObtenerTexto passwN
	print CRLF
	;Se separa lectura
	jmp Juego
	;jmp Inicio

	
; opcion para salir	
Op3:
	mov ax,4c00h	;funcion system.exit
	int 21h

Juego:
	mov al,13h
	xor ah,ah
	int 10h

	mov ax,0a00h
	mov es,ax
	xor di,di

mainLoop:
	mov bl,0
	call ClearScreen:	;Limpiar
	;-----------------Cronometro
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
;------------------------Subrutinas-----------------
getChar:
	mov ah,01h		; funcion para leer un caracter del teclado
	
	
	; aqui estaba el error, había colocado 21 sin especificar que era hexadecimal
	; y la interrupcion es 21 en hexadecimal, por lo que se debe agregar la h al 21
	
	int 21h			; inicio la lectura del caracter
	ret

cerrarF:
	mov ah,3eh
	int 21h
	ret
aleatoriaPos:
	rnd:
	mov ah,2Ch
	int 21h
	mov 
	ret

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

;verificarUser:
	;xor si,si
	;xor di,di
	;recorrer:
	;mov al,userN[si]
	;mov bl,passwN[di]
	;cmp al,bl
	;je
