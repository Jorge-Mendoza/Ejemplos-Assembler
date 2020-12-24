;Codigo graficas
;macros

%macro print 1
	mov dx,%1
	mov ah,9
	int 21h
%endmacro


%macro abrirA 1
	%%abrirF:
		mov ah,3dh
		mov al,00h
		mov dx,%1
		int 21h

		jc %%Error1
		mov bx,ax
		jmp %%Fin
	%%Error1:
		;print msgError1
		call cerrarF
	%%Fin:

%endmacro

%macro leerA 2
	%%leer:
	;mov bx,ax
	mov ah,3fh
	mov dx,%2

	mov cx,%1
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
	;jmp %%leer

	jmp %%Fin

	%%Error2:
		;print msgError2
		;call cerrarF
	%%Fin:
	print CRLF
	print lectura
	print CRLF
	;call cerrarF

%endmacro
%macro guardarNumeros 4  ;buffer, cantidad, arreglo numero
	xor bx,bx
	xor si,si 
	xor di,di  
	%%INICIO:
		mov bl,%1[si]   ;Lectura del archivo caracter por caracter
		cmp bl,36 ; Simbolo $, teminé de leer
		je %%FIN
		cmp bl,48    ;bl<48
		jl %%Salir
		cmp bl,57
		jg %%Salir
		jmp %%RECONOCER
	%%RECONOCER:
		mov bl,%1[si]
		cmp bl,48
		jl %%GUARDAR
		cmp bl,57
		jg %%GUARDAR 
		inc si 
		mov %4[di],bl 
		inc di 
		jmp RECONOCER
	%%GUARDAR:
		push si
		convertirDec %4
		xor bx,bx
		mov bl, %2
		mov %3[bx],al
		LimpiarBuffer %4,20
		inc %2
		pop si
		xor bx,bx
		xor ax,ax
		jmp %%INICIO

	%%SALIR:
		inc si 
		xor di, di
		jmp %INICIO
	%%FIN:
		xor ax,ax
		mov al, %2
		mov cantidad2, ax

%endmacro
%macro convertirDec 1
	xor ax,ax
	xor bx, bx 
	xor cx, cx 
	mov bx,10   ;multiplicador 10
	xor si, si 

	%%INICIO:
		mov cl,%1[si]
		cmp cl,48
		jl %%FIN
		cmp cl,57
		jg %%FIN
		inc si 
		sub cl,48
		mul bx
		add ax,cx
		jmp %%INICIO 
	%%FIN:
%endmacro
%macro LimpiarBuffer 2
	xor bx,bx
	%%INICIO:
		mov %1[bx],36
		inc bx
		cmp bx,%2
		je %%FIN
		jmp %%INICIO 
	%%FIN:
%endmacro
%macro copiarArreglo 2   ;fuente, destino
	xor si,si 
	xor bx,bx 
	%%INICIO:
		mov bl, cantidad
		cmp si,bx
		je %%FIN
		mov al, %1[si]
		mov %2[si],al 
		inc si 
		jmp %%INICIO
	%%FIN:
%endmacro
%macro DeterminarMayor 0
	xor si, si 
	xor ax, ax
	xor bx, bx
	xor cx,cx
	xor dx,dx
	mov dx,cantidad2
	dec dx
	%%BURBUJA:
		mov al, arreglo[si]
		mov bl, arreglo[si+1]
		cmp al,bl 
		jl %%MENOR
		inc si 
		inc cx 
		cmp cx,dx
		jne %%BURBUJA
		mov cx,0
		mov si,0
		jmp %%VERIFICAMOS
	%%MENOR:
		mov arreglo[si],bl 
		mov arreglo[si+1],al 
		inc si 
		inc cx
		cmp cx,dx
		jne %%BURBUJA
		mov cx,0
		mov si,0
		jmp %%VERIFICAMOS
	%%VERIFICAMOS:
		mov al,arreglo[si]
		mov bl,arreglo[si+1]
		cmp al,bl 
		jl %%RESETEAR
		inc si 
		inc cx
		cmp cx,dx 
		jne %%VERIFICAMOS
		jmp %%FIN
	%%RESETEAR:
		MOV SI,0
		mov cx,0
		jmp %%BURBUJA
	%%FIN:
		xor ax,ax
		mov al,arreglo[0]
		mov maximo,ax

%endmacro
%macro Burbuja 0
;convertir velocidad en hz
	mov cl,9
	sub cl,velocidad1
	inc cl
	mov ax,500
	mov bl,cl 
	mul bl 
	mov tiempo,ax
	BurbujaAsc

%endmacro
%macro BurbujaAsc 0
	xor si, si 
	xor ax, ax 
	xor bx,bx 
	xor cx,cx
	xor dx,dx
	mov dl,cantidad
	dec dx
	Graficar arreglo
	%%BURBUJA:
		mov al,arreglo[si]
		mov bl,arreglo[si+1]
		cmp al,bl 
		jg %%MAYOR
		inc si
		inc cx
		cmp cx,dx
		jne %%Burbuja
		mov cx,0
		mov si,0
		jmp %%VERIFICAMOS
	%%MAYOR:
		mov arreglo[si],bl
		mov arreglo[si+1],al
		Graficar arreglo
		inc si
		inc cx
		cmp cx,dx
		jne %%Burbuja
		mov cx,0
		mov si,0
		jmp %%VERIFICAMOS
	%%VERIFICAMOS:
		mov al,arreglo[si]
		mov bl,arreglo[si+1]
		cmp al,bl
		jg %%RESETEAR
		inc si 
		inc cx 
		cmp cx,dx
		jne %%VERIFICAMOS
		jmp %%FIN
	%%RESETEAR:
		mov si,0
		mov cx,0
		jmp %%BURBUJA 
	%%FIN:
		GraficarFinal arreglo 


%endmacro
%macro GraficarFinal  1
	pushear
	obtenerNumeros
	DeterminarTamano tamanoX,espacio,cantidad2,espaciador
	pushearVideo %1
	ModoGrafico
	imprimirVN numerosMos,16h,02h
	poppearVideo %1
	graficarBarras cantidad2,espacio2,%1
	call getChar
	call getChar
	ModoTexto
	poppear
%endmacro
%macro Graficar 1
	pushear
	obtenerNumeros
	DeterminarTamano tamanoX,espacio,cantidad2,espaciador
	pushearVideo %1
	ModoGrafico
	imprimirVN numerosMos,16h,02h
	poppearVideo %1
	graficarBarras cantidad2,espacio2,%1
	ModoTexto
	poppear
%endmacro
%macro ModoTexto 0
	mov ax,0003h
	int 10
	mov ax, data  ;@data
	mov ds,ax
%endmacro
%macro ModoGrafico 0
	;Inciar el modo video
	mov ax,0013h
	int 10h
	mov ax,0A000h
	MOV ds,ax
%endmacro

%macro imprimirVN 3     ;cadena, fila, columna
	push ds
	push dx
	xor dx,dx
	mov ah,02h
	mov bh,0	;pagina
	mov dh,%2
	mov dl, %3
	int 10h

	mov dx,%1
	mov ah,0
	int 21h
%endmacro

%macro graficarBarras 3 ; cantidad,espacio,arreglo
	xor cx,cx
	%%INICIO:
		cmp cx,%1
		je %%FIN
		PUSH cx
		mov si,cx
		xor ax,ax
		mov al,%3[si]
		mov valor, al
		push ax
		DeterminarColor
		xor ax,ax
		mov ax,maximo
		mov max,al
		dibujarBarra %2,valor,max
		pop ax
		mov valor,al 
		DeterminarSonido
		pop cx
		inc cx
		jmp %%INICIO 
	%%FIN:

%endmacro
%macro DeterminarColor 0
	cmp valor,1
	jb %%FIN
	cmp valor,20
	ja %%SEGUNDO
	mov dl,4
	jmp %%FIN

	%%SEGUNDO:
		cmp valor,40
		ja %%TERCERO
		mov dl,1
		jmp %%FIN
	%%TERCERO:
		cmp valor,60
		ja %%CUARTO
		mov dl,44
		jmp %%FIN
	%%CUARTO:
		cmp valor,80
		ja %%QUINTO
		mov dl,2
		jmp %%FIN
	%%QUINTO:
		cmp valor,99
		ja %%FIN
		mov dl,15
		jmp %%FIN
	%%FIN:
%endmacro
%macro DeterminarSonido 0
	cmp valor,1
	jb %%FIN
	cmp valor,20
	ja %%SEGUNDO
	Sound 100
	jmp %%FIN

	%%SEGUNDO:
		cmp valor,40
		ja %%TERCERO
		Sound 300
		jmp %%FIN
	%%TERCERO:
		cmp valor,60
		ja %%CUARTO
		Sound 500
		jmp %%FIN
	%%CUARTO:
		cmp valor,80
		ja %%QUINTO
		Sound 700
		jmp %%FIN
	%%QUINTO:
		cmp valor,99
		ja %%FIN
		Sound 900
		jmp %%FIN
	%%FIN:
%endmacro
%macro Sound 1
	mov al,86h
	out 43h,al
	mov ax,(1193180/%1)
	out 42h,al
	mov al,ah
	out 42h,al
	in al,61h
	or al,00000011b
	out 61h,al 
	delay tiempo 
	in al,61h
	and al,11111100b
	out 61h,al 
%endmacro
%macro delay 1
	push si,si 
	push di,di 
	mov si,%1

	%%D1:
		dec si 
		jz %%FIN
		mov di,%1
	%%D2:
		DEC di
		jnz %%D2
		jmp %%D1
	%%FIN:
		POP di 
		pop si 
%endmacro
%macro dibujarBarra 3	;espaciado,valor,max
	xor cx,cx
	DeterminarTamañoY %2,%3
	%%INICIO:
		CMP cx,tamanoX
		je %%FIN
		push cx
		mov ax,170   ;170 es el tamaño que tenemos en y para dibujarBarra
		mov dx,ax
		sub bl,%2
		xor bh,bh
		mov si,bx
		mov bx,30 	;
		add bx,%1
		add bx,cx
		PintarY
		pop cx
		inc cl
		jmp %%INICIO 
	%%FIN:
		MOV AX,espaciador
		add %1,ax

%endmacro

%macro DeterminarTamañoY 2 ;valor, max
	xor ax,ax
	mov al,%1
	mov bl,130
	mulbl
	mov bl,max
	div bl 
	mov %1,al
%endmacro
%macro PintarY 0
	mov cx,si
	%%EJEY:
		cmp cx,ax
		je %%FIN
		mov di,cx
		push ax
		push dx
		mov ax,320
		mul di
		mov di,ax
		pop dx
		pop ax
		mov [di+bx],dl
		inc cx
		jmp %%EJEY
	%%FIN:
%endmacro

%macro obtenerNumeros 0
	pushear
	xor si,si 
	xor dx,dx
	mov dl,cantidad
	LimpiarBuffer numerosMos,60
	%%INICIO:
		LimpiarBuffer resultado,20
		cmp si,dx
		je %%FIN
		push si
		push dx
		xor ax,ax
		mov al, arreglo[si]
		ConvertirString resultado
		insertarNumero resultado
		pop dx
		pop si 
		inc si 
		jmp %%INICIO
	%%FIN:	
		poppear
%endmacro
%macro pushear 0
 push ax
 push bx
 push cx
 push dx
 push si 
 push di 
%endmacro
%macro poppear 0
	pop ax
	pop bx
	pop cx
	pop dx
	 pop si 
	 pop di
%endmacro
%macro ConvertirString 1
	xor si,si 
	xor cx,cx
	xor bx,bx
	xor dx,dx
	mov dl,10
	test ax,1000000000000000
	jnz %%NEGATIVO
	jmp %%DIVIDIR2
	%%NEGATIVO:
		neg ax
		mov %1[si],45
		inc si
		jmp %%DIVIDIR2
	%%DIVIDIR:
		xor ah,ah

	%%DIVIDIR2:
		div dl
		inc cx
		push ax
		cmp al,00h   ; al=residuo de la division
		je %%FINCR3
		jmp %%DIVIDIR
	%%FINCR3:
		pop ax
		add ah,30h
		mov %1[si],ah
		inc si 
		loop %%FINCR3
		mov ah,24h
		mov %1[si],ah
		inc si 
	%%FIN:
%endmacro
%macro insertarNumero 1
	xor si,si 
	xor di,di 
	%%INICIO:
		cmp si,60
		je %%FIN
		mov al,numerosMos[si]
		cmp al,36
		je %%SIGUIENTE
		inc si
		jmp %%INICIO
	%%SIGUIENTE:
		mov al,%1[si]
		cmp al,36
		je %%FIN
		mov numerosMos[si]al
		inc di 
		inc si 
		jmp  %%SIGUIENTE
	%%FIN:
		mov numerosMos[si],32

%endmacro
%macro DeterminarTamano 4 ;tamanoX,espacio,cantidad2,espaciador
	mov ax,260 ;tamaño para dibujar por el marco
	mov bx,%3
	xor bh,bh
	div bl     ;dividiendo el lienzo por la cantidad
	xor dx,dx
	mov dl,al	;guardando el cociente en dl
	mov %4,dx
	xor ah,ah
	mov bl,25
	mul bl
	mov bl,100
	div bl     ;sacando el 25% de todo el ancho a tomar

	mov %2,al    ;guardo el cociente
	mov bx,%4
	sub bl,%2		;restamos el espacio entre cada barra
	mov %1,bx      ;Guardamos el ancho en tamaño x


%endmacro
%macro pushearVideo 1
	pushArreglo %1
	push maximo
	push tamanoX
	push espaciador
	push cantidad2
	push tiempo
%endmacro
%macro poppearVideo 1
	pop tiempo
	pop cantidad2
	pop espaciador
	pop tamanoX
	pop maximo
	popArreglo %1
%endmacro
%macro pushArreglo 1
	xor si,si 
	%%INICIO:
		xor ax,ax
		cmp si,cantidad2
		je %%FIN
		MOV al,%1[si]
		push ax
		inc si 
		jmp %%INICIO 
	%%FIN:
%endmacro
%macro popArreglo 1
	xor si,si 
	MOV SI, cantidad2
	DEC si 
	%%INICIO:
		cmp si,0
		jl %%FIN
		pop ax
		mov %1[si]
		dec Si
		jmp %%INICIO
	%%FIN:
%endmacro
;--------------------------------------------------------------------
section .data
velocidad db  0ah,0dh,'Ingrese una velocidad (0-9)',32,'$'
opcion db 0ah,0dh,'Seleccione una opcion:',32,'$'
opcion1 db 0ah,0dh,'1. Cargar Datos',32,'$'
opcion2 db 0ah,0dh,'2. Graficas',32,'$'
opcion3 db 0ah,0dh,'3. Salir',32,'$'

ruta db 'entrada.xml',32,'$'
bufferLectura db 1000 dup('$')
lenL equ $- bufferLectura -1

arreglo db 30 dup(0)
arregloInicial db 30 dup (0)
arregloBurbuja db 30 dup(0)

numero db 20 dup('$')
cantidad db 0
cantidad2 dw 0
maximo dw 0
max dw 0

velocidad1 db 0
tiempo dw 500

numerosMos db 60 dup('$')  ;guardara los digitos
resultado db 20 dup('$')

tamanoX  dw 0
espacio db 0
espaciador dw 0
espacio2 dw 0
valor db 20
org 100h
section .text

Inicio:
	Menu:
		print opcion1
		print opcion2
		print opcion3
		print opcion
		call getChar
		cmp al,49
		je Cargar
		cmp al,50
		je Bubble
		cmp al,51
		je Salir
;-----------------------------------------------
	Cargar:
	abrirA ruta
	leerA lenL,bufferLectura
	call cerrarF

	guardarNumeros bufferLectura,cantidad,arreglo,numero
	copiarArreglo arreglo,arregloInicial
	DeterminarMayor 
	copiarArreglo arregloInicial,arreglo
	jmp Menu:
;----------------------------------------------
	Bubble:
		print velocidad
		call getChar
		sub al,48
		mov velocidad1,al
		Burbuja
		copiarArreglo arreglo,arregloBurbuja
		copiarArreglo arregloInicial,arreglo
		jmp Menu
;---------------------------------------------
	Salir:
		mov ax,4c00h 	;funcion para terminar el programa
		int 21h

		;------------------------------------------Subrutinas
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