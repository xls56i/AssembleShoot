EXTRN SUBPROG1:FAR
CLEARSCR MACRO
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV AX,0600H
	MOV BH,07
	MOV CX,0
	MOV DX,184FH
	INT 10H
	POP DX
	POP CX
	POP BX
	POP AX
	ENDM
DISPLAY MACRO STRING
	PUSH AX
	PUSH DX
	MOV AH,09
	MOV DX,OFFSET STRING
	INT 21H
	POP DX
	POP AX
	ENDM

CURSOR MACRO ROW,COLUMN
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV AH,02
	MOV BH,00
	MOV DH,ROW
	MOV DL,COLUMN
	INT 10H
	POP DX
	POP CX
	POP BX
	POP AX
	ENDM
	
REMOVE MACRO NUM,ROW,COL,ADDR
	LOCAL LOOP1
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	MOV CX,NUM
    MOV DI,ADDR
    MOV DH,ROW
    MOV DL,COL
LOOP1:
	ADD DH,[DI+2]
    ADD DL,[DI+3]
    MOV AH,02
    INT 10H
    MOV AL,[DI]
    MOV BL,0
    PUSH CX
    MOV AH,09
    MOV CX,01
    INT 10H
    POP CX
    ADD DI,4
    LOOP LOOP1
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
	ENDM
	
DATAS SEGMENT
    ;姝ゅ杈撳叆鏁版嵁娈典唬鐮?
    ;Menu
    message1 db 'Shoot the SuperMan$'
    message2 db 'Use left and right to move$'
    message3 db 'Shoot:Space$'
    message4 db 'Start: Enter$'
    message5 db 'Exit: Esc$'
    people 	db 6
           	db 01,14,0,0 
           	db 10,12,1,0
           	db 27,2,0,-1
          	db 26,2,0,2
           	db 92,2,1,0
           	db 47,2,0,-2
                 
    superman db 3
         	db 16,12,0,0
         	db 45,12,0,1
         	db 02,12,0,1
                
     
     num1 dw 00
     row1 db 00
     col1 db 00 
     add1 dw 00
     
     num2 dw 00
     row2 db 00
     col2 db 00
     add2 dw 00
     
     
     score db 'Score:$'
     score1 db 2 dup('0'),'$';鍒嗘暟鐨凙SCII鐮侊紝鐢ㄤ簬鏄剧ず
     score2 db 0;鍒嗘暟鐨勪簩杩涘埗鐮侊紝鐢ㄤ簬杩愮畻
     

DATAS ENDS

STACKS SEGMENT
    ;姝ゅ杈撳叆鍫嗘爤娈典唬鐮?
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
    
START:
    MOV AX,DATAS
    MOV DS,AX
    ;姝ゅ杈撳叆浠ｇ爜娈典唬鐮?
	mov ah,00 ;閫夋嫨80*25鏂囨湰妯″紡
    mov al,03
    int 10h
    call howtoplay
    call init
    call showscore  
again:
    call delay
    call move
  	
    mov ah,01
    int 16h
    jz again
    mov ah,00
    int 16h
    cmp ah,4bh
    je left
    cmp ah,4dh
    je right
    cmp ah,39h
    je shoot
    cmp ah,01h
    je exit
    jmp again
    
left:
    mov dl,col1;杈圭晫妫€娴?
    cmp dl,01
    jna again
    
    REMOVE num1,row1,col1,add1
    mov dh,row1
    mov dl,col1
    sub dl,1
    mov di,offset people
    mov bh,00
    call display1
    jmp again
right:
    mov dl,col1
    cmp dl,78
    jnb again
    REMOVE num1,row1,col1,add1
    mov dh,row1
    mov dl,col1
    add dl,1
    mov di,offset people
    mov bh,00
    call display1
    jmp again    
shoot:
    mov dh,row1    
    mov dl,col1
    call kill
    ;call judge
    jmp again
exit:
    MOV AH,4CH
    INT 21H
    
;Menu        
howtoplay proc
	CLEARSCR
	CURSOR 10,20
	DISPLAY message1
	CURSOR 11,20
	DISPLAY message2
	CURSOR 12,20
	DISPLAY message3
	CURSOR 13,20
	DISPLAY message4
	CURSOR 14,20
	DISPLAY message5
	 ;妫€鏌ユ槸鍚︽湁閿鎸変笅
button:
	mov ah,01
	int 16h
	jz button
	mov ah,0
	int 16h
	cmp ah,1ch
	je startgame
	cmp ah,01h
	je exit
	jmp button
startgame:
    CLEARSCR
	ret
howtoplay endp

;鍒濆鍖?
init proc
    mov dh,22;
    mov dl,40
    mov di,offset people
    mov bh,00
    call display1
    mov dh,04
    mov dl,00
    mov di,offset superman
    call display2
    ret
init endp

showscore proc
   	CURSOR 0,33
    mov ah,09
    mov dx,offset score
    int 21h
    
    CURSOR 0,41 
    mov ah,09
    mov dx,offset score1
    int 21h
	ret
showscore endp

display1 proc
      push ax
      push bx
      push cx
      push dx
      push di
      
      mov ch,0
      mov cl,[di]
      mov num1,cx
      mov row1,dh
      mov col1,dl
      inc di
      mov add1,di
      
 next:
      add dh,[di+2]       
      add dl,[di+3]
      mov ah,02
      int 10h
      
      push cx
      mov ah,09;鐢诲浘
      mov al,[di]
      mov cx,01
      mov bl,[di+1]
      int 10h
      pop cx
      add di,4
      loop next
      pop di
      pop dx
      pop cx
      pop bx
      pop ax
      ret
display1 endp

display2 proc
      push ax
      push bx
      push cx
      push dx
      push di
      
      mov ch,0
      mov cl,[di]
      mov num2,cx
      mov row2,dh
      mov col2,dl
      inc di
      mov add2,di
      
 next:
      add dh,[di+2]
      add dl,[di+3]
      mov ah,02
      int 10h
      push cx
      mov ah,09
      mov al,[di]
      mov cx,01
      mov bl,[di+1]
      int 10h
      pop cx
      add di,4
      loop next
      pop di
      pop dx
      pop cx
      pop bx
      pop ax
      ret
display2 endp

move proc
    push ax
    push bx
    push cx
    push dx
    push di
       
    REMOVE num2,row2,col2,add2
    mov dl,col2
    cmp dl,77
    jb loop1
    mov dl,-1
loop1:
    inc dl
    mov dh,row2
    mov di,add2
    mov cx,num2
    mov col2,dl
loop2:
	add dh,[di+2]
    add dl,[di+3]
    mov ah,02
    mov bh,00
    int 10h
    
    push cx
    mov ah,09
    mov bh,00
    mov al,[di]
    mov cx,01
    mov bl,[di+1]
    int 10h
    pop cx
    add di,04
    loop  loop2
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
move endp


kill proc 
	push ax
	push bx
	push cx
	push dx
	push di
loop1:
	call move
    sub dh,01
    mov ah,02
    mov bh,00
    int 10h
    mov ah,09
    mov al,30;绗﹀彿
    mov bl,14;棰滆壊
    mov cx,01;閲嶅娆℃暟
    int 10h
    
    
    call delay
    
    mov ah,09
    mov al,18h
    mov bl,00h
    mov cx,01
    int 10h
    
    cmp dh,4
    je loop2
    
    cmp dh,1
    jne loop1
    jmp loop3
    
loop2:
	call judge
	cmp col2,77
	je loop3	
    jmp loop1
loop3:  
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
kill endp


delay proc
	push cx
	push ax
	mov cx,16578
wait1:
	in al,61h
	and al,10h
	cmp al,ah
	je wait1
	mov ah,al
	loop wait1
	pop ax
	pop cx
	ret
delay endp

judge proc      
	push ax
    push bx
    push si
    mov al,col1  
    mov bl,col2
    cmp al,bl    
    je getscore
    inc bl
    cmp bl,al
    je getscore
    inc bl
    cmp bl,al
    je getscore    
    jmp notkill
    
getscore:
	add score2,1
    sub ah,ah
    mov al,score2
    mov si,offset score1
    call b2as
    
    CURSOR 0,41
    mov ah,09
    mov dx,offset score1
    int 21h
   	
   	REMOVE num2,row2,col2,add2
    mov col2,77 
   
    
notkill:
    pop si
    pop bx
    pop ax
    ret
judge endp

b2as proc
	pushf
  	push bx
  	push dx
  	mov bx,10
  	add si,1
loop1:
	sub dx,dx
    div bx
    or dl,30h
    mov [si],dl
    dec si
    cmp ax,0
    ja loop1
    pop dx
    pop bx
    popf
    ret
b2as endp

CODES ENDS
    END START

