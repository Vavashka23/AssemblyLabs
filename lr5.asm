.model small        
.stack 100h
.data      
    LENGTH equ 6
    BUFFER db 10 dup(?)
    ARRAY_SYMBOLS db 8 dup(?) 
    PATH db 126 dup(0)
    PATH_OUT db 'output.txt', 0 
    LEN_STR dw 0
    HANDLE dw 0  
    IO_ERROR db "Unable to open the file.$"           
    COMMAND_ERROR db "Empty command line.$"    
    TEMP_STR db ? 
    buff db ?   
.code  

OUTPUT MACRO outLine
    mov ah, 09h  
    lea dx, outLine
    int 21h     
endm 

INPUT MACRO line 
    mov line[0], LENGTH 
    lea dx, line
    mov ah, 0Ah
    int 21h
    
    push bx
    xor bx, bx 
    mov bl, line[1]
    add bl, 2
    mov line[bx], '$'  
    pop bx 
endm 

start:  
 
    mov ax, @data
    mov ds, ax      
    lea di, ARRAY_SYMBOLS        
    call PARSE_PATH2       
    mov ARRAY_SYMBOLS[0], LENGTH 
    push bx
    xor bx, bx   
    mov ARRAY_SYMBOLS[1], 2 
    mov bl, ARRAY_SYMBOLS[1]
    add bl, 2              
    
    mov ARRAY_SYMBOLS[bx], '$'  
    add bl, 1
    mov ARRAY_SYMBOLS[bx], 0  
    pop bx  
    ;OUTPUT ARRAY_SYMBOLS 
    mov dl, ARRAY_SYMBOLS[1]      
    xor dx, dx
    xor si, si                
    lea di, PATH         
    call PARSE_PATH                   
    lea dx, PATH                  
    mov ah, 3Dh                
    mov al, 00h                     
    int 21h 
    
    jc file_Undefined                  
     
    pusha
    mov ah, 3Dh                
    lea dx, PATH_OUT
    mov al, 02h 
    int 21h 
    mov [HANDLE], ax
    popa   
    
    mov bx,ax 
    lea di,TEMP_STR
    xor di, di
read:
    xor ax, ax     
    mov ah, 3Fh            
    mov cx, 1                     
    lea dx, BUFFER          
    int 21h 
    cmp ax, cx                       
    jnz exit
        
    mov cx, ax    
    dec cx
    
    cmp BUFFER[0], 0Dh
    je read
    cmp BUFFER[0], 0Ah
    je calc_Str
    
    mov dl, BUFFER[0]
    mov TEMP_STR[di], dl
    inc di   
    inc LEN_STR 
    mov dl, 00h   
     
jmp read     
    mov ah,3Eh               
    int 21h      
    
    jmp exit
    
file_Undefined:                            
    OUTPUT [IO_ERROR]
    jmp exit  
    
command_Undefined:
    OUTPUT [COMMAND_ERROR]              
    jmp exit    

exit:  
    mov ah, 4ch
    int 21h 

calc_Str:
    cmp LEN_STR, 0
    je exit
    call CHECK_STRING
    xor di, di 
    mov LEN_STR, 0
    jmp read        

PARSE_PATH2 PROC               
    xor cx,cx          
    mov si, 80h
    mov cl, es:[si]             
    
    cmp cx, 0
    je command_Undefined
    
    inc si
    inc di
    mov al, es:[si] 
    cmp al, ' '
    je next_step2
cycle2:
    mov al, es:[si]        
    cmp al, 13
    je next_step2 
    cmp al, ' '
    jne next_step2    
    jmp cycle5
next_step2:
    inc si 
    loop cycle2
    ret  
cycle5:
    mov al, es:[si]        
    cmp al, 13
    je next_step3 
    mov [di], al   
    inc di 
next_step3:
    inc si 
    loop cycle5
    ret
endp

PARSE_PATH PROC               
    xor cx,cx          
    mov si, 80h
    mov cl, es:[si]             
    
    cmp cx, 0
    je command_Undefined
    
    inc si
    mov al, es:[si] 
    cmp al, ' '
    je next_step
cycle:
    mov al, es:[si]        
    cmp al, 13
    je next_step 
    cmp al, ' '
    je returne    
    mov [di], al   
    inc di
next_step:
    inc si 
    loop cycle
returne:
    ret
endp

inc_score:
    inc al
    inc si
    cmp si, LEN_STR
    je check_cycle  
    jne inner_cycle

inc_symbol_score:
    inc ah
    mov al, 0
    jmp check_cycle 
    
CHECK_STRING PROC
    pusha
    xor di, di
    xor dx, dx
    xor bx, bx 
    xor ax, ax
    lea si, TEMP_STR
    lea di, ARRAY_SYMBOLS
    xor si, si
    xor di, di
    add di, 1
    mov bl, ARRAY_SYMBOLS[1]
    add bl,2
    push ax
check_cycle:
    cmp al, 0
    jne inc_symbol_score
    inc di
    cmp bx, di
    je checking
    mov dl, ARRAY_SYMBOLS[di]
    xor si, si
    inner_cycle:
        cmp TEMP_STR[si], dl
        je inc_score
        inc si
        cmp si, LEN_STR
        je check_cycle  
        jne inner_cycle
        
checking:
    sub bl, 2 
    cmp bl, ah
    je ex
write_or_not:    
    call WRITE_TO_FILE
    inc si
    cmp si, LEN_STR
ex: 
    pop ax   
    popa
    ret
endp      

WRITE_TO_FILE PROC
    pusha
    mov ax, [HANDLE]    
    mov bx, ax 
    
    mov ah, 42h
    mov al, 2
    mov cx, 0
    mov dx, 0
    int 21h
      
    mov ah, 40h  
    mov dx, offset TEMP_STR
    mov cx, LEN_STR      
    int 21h
    
    mov dx, 0Dh
    mov buff, dl
    
    mov ah, 40h  
    mov dx, offset buff
    mov cx, 1      
    int 21h
    
    mov dx, 0Ah
    mov buff, dl
    
    mov ah, 40h  
    mov dx, offset buff
    mov cx, 1      
    int 21h
    
    mov ah,3Eh           
    mov bx,ax      
    int 21h
    popa   
    ret    
endp
end start