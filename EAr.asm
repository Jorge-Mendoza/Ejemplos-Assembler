
%macro print 1
	mov dx,%1
	mov ah,9
	int 21h
%endmacro

section .data
	arreglo db 7 dup('$'), '$'
	;arreglo times 10 '$'
	msg1 db '1) Ingresar Texto',00h,0Ah,'$'
	msg2 db '2) Mostrar Texto',00h,0Ah,'$'
	msg3 db '1) Salir',00h,0Ah,'$'
	msg4 db 'Escoja opcion:',00h,0Ah,'$'
	msg5 db 'Ingresar texto:',00h,0Ah,'$'
org 100h
section .text
	Menu:
	print msg1
	print msg2
	print msg3
	print msg4
	call GetCh
	sub al,48

	cmp al,1
	je Opcion1

	cmp al,2
	je Opcion2

	cmp al,3
	je Opcion3

	jmp Menu


;--------------------Subrutinas----------------------------
GetCh:
	mov ah,01h
	int 21
	ret