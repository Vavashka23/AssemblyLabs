.model small
.stack 100h
 
.data
mas1	db 31 dup (0)	;input array
mas2	db 11 dup (0)	;output array
msg1 	db "Enter array(0-9):",0Dh,0Ah,'$'
msg2 	db "Second array:",0Dh,0Ah,'$'
error   db "Error!",0Dh,0Ah,'$'
space   db " - ",'$'
new_string db 0Dh,0Ah,'$'
 
.code 

output proc
    mov ah, 09h
    int 21h
    ret
endp  

input proc 
    mov si, 0
    mov cx, 30
    loop1: 
    mov ah,01h
	mov al,00h
	int 21h
	sub al,30h
	mov [mas1+si],al
	add si,1
	loop loop1      
	mov [mas1+si],'$'
	ret 
endp 


start:
	mov ax,@data
	mov ds,ax
	
	lea dx, msg1
	call output
	 
;enter array
	call input
	lea dx, new_string
    call output
      
    mov si,0
	mov cx,30
count_numbers:         
cmp si, 29
jg next
    mov dl, [mas1+si]  
    cmp dl, 0
    jne one  
    add mas2[0], 1
    inc si
    jmp count_numbers
    one:
    cmp dl, 1
    jne two 
    add mas2[1], 1  
    inc si 
    jmp count_numbers 
    two:
    cmp dl, 2
    jne three 
    add mas2[2], 1  
    inc si
    jmp count_numbers
    three:
    cmp dl, 3
    jne four 
    add mas2[3], 1  
    inc si
    jmp count_numbers
    four:
    cmp dl, 4
    jne five 
    add mas2[4], 1  
    inc si 
    jmp count_numbers 
    five:
    cmp dl, 5
    jne six 
    add mas2[5], 1  
    inc si
    jmp count_numbers
    six:
    cmp dl, 6
    jne seven 
    add mas2[6], 1  
    inc si
    jmp count_numbers
    seven:
    cmp dl, 7
    jne eight 
    add mas2[7], 1  
    inc si
    jmp count_numbers
    eight: 
    cmp dl, 8
    jne nine  
    add mas2[8], 1  
    inc si
    jmp count_numbers
    nine:
    cmp dl, 9
    jne end_loop 
    add mas2[9], 1  
    inc si
    jmp count_numbers 
     
;error 
end_loop:
    lea dx, error 
    call output
	jmp finish  
	
next:
	mov si,0
	mov cx,10
	mov di,0  
	
output_gisto: 
cmp si, 9
jg finish
    mov di,0
    mov ah,02h
    mov dx,si
    add dx, 30h
    int 21h
    lea dx, space
    call output
	mov bl, [mas2+si]         
stars:
cmp bx, 0
je zero
    mov ah,02h
    mov dx,01h
    int 21h
    inc di
    cmp di, bx
    jnge stars    
next4:   
    lea dx, new_string 
	call output
    inc si
    jmp output_gisto 

zero:
    mov ah,02h
    mov dx,'0'
    int 21h
    jmp next4

;end of programm 
finish:
	mov ax,4c00h
	int 21h
end start