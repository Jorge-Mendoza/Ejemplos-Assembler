;macros

%macro print 1
	mov dx,%1
	mov ah,9
	int 21h
%endmacro


%macro abrirA 1
	%%abrirF:
		mov ah,3dh
		mov al,010b
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

%macro leerF 2
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