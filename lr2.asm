.model small ; for EXE
.stack 200h ; stack segment

.data ;data segment   

string_enter db "Enter string:",0Dh,0Ah,'$'
word_from_string_enter db "Enter the word from string:",0Dh,0Ah,'$'
word_enter db "Enter the word:",0Dh,0Ah,'$' 
error db "Invalid input!",0Dh,0Ah,'$' 
string db 200 dup('$')
word_from_string db 200 dup('$')
word db 200 dup('$')  
new_string db 0Dh, 0Ah, '$'

.code
output macro str
    lea dx, str
    mov ah, 9
    int 21h
endm

start:
mov ax, @data
mov ds, ax    
jmp string_input

error_input:  
output error
jmp end_of_programm

string_input:
output string_enter

mov ah, 0Ah
mov dx, offset string
int 21h   
 
output new_string

word_from_string_input:
output word_from_string_enter

mov ah, 0Ah
mov dx, offset word_from_string
int 21h       

output new_string
 
word_input:
output word_enter
 
mov ah, 0Ah
mov dx, offset word
int 21h

output new_string

start_main_programm:
mov di, 2
mov si, 2
push di

start_main:
pop bx
push bx
mov di, bx

finding_symbols:
cmp string[di], '$'
je end_of_programm 
cmp string[di], 0dh
je end_of_programm
cmp string[di], ' '
jne remember
inc di
jmp finding_symbols

remember:
push di

loop1: 
mov si, 2
mov bl, string[di]
cmp bl, word_from_string[si]
je equal_symbols
inc di
jmp finding_symbols

equal_symbols:
inc di 
inc si  
cmp word_from_string[si], ' '
je error_input
cmp word_from_string[si], 0dh
je next_loop
mov bl, string[di]
cmp bl, word_from_string[si] 
je equal_symbols
jmp finding_symbols

next_loop:  
cmp string[di], '$'
jne loop3
cmp string[di], ' '
je loop3
inc di
jmp finding_symbols

loop3:
xor si, si
mov di, 2
jmp f

counter:
inc di
inc si

f:
mov bx, word[di]
cmp bh, 0dh
jne counter 

end_counter:
mov di, 2
jmp g

last_position_search:
inc di

g:
cmp string[di], '$'
jne last_position_search

add si, di      
inc si       ; it's length of the inserted word + the remaining line
dec di

moving:
mov bl, string[di]
mov string[si], bl
dec di
dec si
pop bx
push bx
cmp di, bx
jne moving  ; until we get to the beginning of the inserted word
mov bl, string[di]
mov string[si], bl

insert:
mov di, 2
jmp qq

q:
inc di

qq:
mov dl,offset word[di]
pop bx
push bx
mov string[bx], dl
inc di
pop bx
inc bx
push bx
cmp word[di], 0dh
je insert_space 
pop bx
push bx
cmp bx, si
je insert_space
jmp qq

insert_space:
dec si
mov string[si], ' '      

pop bx   
inc bx
push bx
cmp string[bx], 0dh
jne start_main

end_of_programm:
output new_string    
mov dx, offset string 
add dx, 2h
mov ah, 9
int 21h  
end start