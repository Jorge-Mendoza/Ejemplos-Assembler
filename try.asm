
%macro print 1
	mov dx,%1
	mov ah,9
	int 21h
%endmacro

;--------------------------Data------------------------
section .data	
	Msg1 DB "1. Opcion 1 $"
	Msg2 DB "2. Opcion 2 $"
	Msg3 DB "3. Opcion 3 $"
	Msg4 DB "4. Opcion 4 $"
	Msg5 DB "5. Salir $"
	prueba1 db 'Esta es una prueba $'
	prueba2 db 'Esta es una prueba $'
	users dw 'Jorge,12345',0dh,0ah,'Fernando,54321'
	usuario times 10 db '$'
	passw times 10 db '$'

	CRLF DB 0DH, 0AH, '$'
	
	Ingresar DB " Ingrese una opcion:  $"
	
	opc1 DB 0DH, 0AH,"----------entro opc1----------$"
	opc2 DB 0DH, 0AH,"----------entro opc2----------$"
	opc3 DB 0DH, 0AH,"----------entro opc3----------$"
	opc4 DB 0DH, 0AH,"----------entro opc4----------$"
	
;-----------------------Codigo---------------------------
org 100h
section .text

Inicio:
	print Msg1
	print CRLF
	
	print Msg2
	print CRLF
	
	print Msg3
	print CRLF
	
	print Msg4
	print CRLF
	
	print Msg5
	print CRLF
	
	
	print Ingresar

	call GetCH
	print CRLF
	
	sub al,48		; convirtiendo ascii a decimal y guardandolo en al
	
	cmp al,1		; comparar si se ingreso opc 1
	je Op1			; si se ingreso 1, me voy a opc 1
	cmp al,2		; comparar si se ingreso opc 2
	je Op2			; si se ingreso 2, me voy a opc 2
	cmp al,3		; comparar si se ingreso opc 3
	je Op3			; si se ingreso 3, me voy a opc 3
	cmp al,4		; comparar si se ingreso opc 4
	je Op4			; si se ingreso 4, me voy a opc 4
	cmp al,5		; comparar si se ingreso opc 4
	je Op5			; si se ingreso 4, me voy a opc 4
	
	jmp Inicio
	
Op1:
	;print opc1
	;print CRLF
	;call concatenar
	;call comparar
	mov si,0
	call Separar
	print CRLF
	pop si
	call Separar
	print CRLF
	jmp Inicio
Op2:
	print opc2
	print CRLF
	jmp Inicio
Op3:
	print opc3
	print CRLF
	jmp Inicio
Op4:
	print opc4
	print CRLF
	jmp Inicio
	
; opcion para salir	
Op5:
	mov ax,4c00h	;funcion system.exit
	int 21h
	
; --------------- subrutinas ------------------------------
; escanear una entrada del teclado
; y la guarda en el registro "AL" como ascii
GetCH:
	mov ah,01h		; funcion para leer un caracter del teclado
	
	
	; aqui estaba el error, había colocado 21 sin especificar que era hexadecimal
	; y la interrupcion es 21 en hexadecimal, por lo que se debe agregar la h al 21
	
	int 21h			; inicio la lectura del caracter
	ret

concatenar:
	mov si,0
	mov di,0
	recorrer:
		mov al,prueba1[si]
		cmp al,36
		je concatenacion
		inc si
		jmp recorrer
	concatenacion:
		mov bl,prueba2[di]
		cmp bl,36
		je Terminar
		mov prueba1[si],bl
		inc si
		inc di
		jmp concatenacion
	Terminar:
		mov al,bl
		print CRLF
		print CRLF
		print prueba1
		print CRLF
		print CRLF
		ret

comparar:
	mov si,0
	
	recorriendo:
		mov al,prueba2[si]
		cmp prueba1[si],al
		jne fin
		cmp al,36
		jz final
		inc si
		jmp recorriendo
		final:
			print CRLF
			print prueba1
			print CRLF
			print prueba2
			print CRLF
		fin:
			ret
;mov si,0
Separar:
	
	mov di,0
	;recorriendo:
	usuarios:
	mov al,users[si]
	cmp al,44
	je password
	mov usuario[di],al
	inc di
	inc si
	jmp usuarios
	password:
	mov bl,users[si]
	mov di,0
	cmp bl,10
	je finS
	cmp bl,36
	je finS
	mov passw[di],bl
	inc si
	inc di
	jmp password
	finS:
	push si
	print usuario
	print password
	ret
