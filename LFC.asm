%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
 
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000

    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif
;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall 
    
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
; rsi : zero terminated string start 
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx

    pop     rax
    pop     rcx
    pop     rbx
    ret
;-------------------------------------------

section .data
        newline db 10

section .bss
        num1: resb 4
        num2: resb 4
section .text
        global _start

_start:
        
        call readNum
        ; The first number is stored in rax
        mov [num1], rax
        ; storing the first number in r9
        mov r9,[num1]
        ;call writeNum
        call readNum
        mov [num2], rax
        ; The first number is stored in rax
        mov rbx, [num2]
        ; storing the first number in r10
        mov r10, [num2]
        ;storing the first number in rax
        mov rax, r9
        ; the first number is also stored in r12
        ; since it's the first number that we want to increase until reaching
        ; a number that is divisible by both numbers
        ; therefore we increase the first number by increasing r12
        ; without changing r9
        mov r12, r9
        ; First we want to check if any number is equal to zero
        xor r11, r11
        cmp r9, r11
        ; if the first number is equal to 0 --> jump to 'ex'
        je ex
        cmp r10, r11
        ; if the second number is equal to 0 --> jump to 'ex'
        je ex
        ;call writeNum
        ;cmp rax,rbx
        ;xor r8, r8
        jmp loop
        jmp Exit

        
loop:
        ; the first number was stored in r12
        mov rax,r12
        xor rdx, rdx
        ; dividing the first number+counter by the second number
        div r10
        xor r11, r11
        ; checking if the remainder is zero 
        cmp rdx, r11
        ; if it is then the number (stored in r12) is divisible by the second 
        ; number so we jump to 'check'
        je check
        ; increasing the first number one by one
        inc r12
        jmp loop
check:
        ; if we are here it means that we reach a number (r12) that is divisible 
        ; by the second number now we have to check if it is also divisible
        ; by the first number
        mov rax,r12
        xor rdx, rdx 
        div r9
        xor r11, r11
        cmp rdx, r11
        ; if it is also divisible by the first number we jumo to 'printLCM'
        ; to print the number
        je printLCM
        ; if not we increase the number and jump to 'loop' to find the next 
        ; number that is divisible by the second number and jump back here to
        ; check if it is also divisible by the first number or not
        inc r12
        jmp loop
        
printLCM:

        ;storing the answer (LCM) in rdx
        mov rdx, r12
        mov rax, r12
        call writeNum
        ;print newline character
    mov eax, 4 
    mov ebx, 1
    mov ecx, newline ;address of newline character
    mov edx, 1 ;#bytes to write
    int 0x80 
    jmp Exit
        jmp Exit
ex:
        ;storing the answer (LCM) in rdx
        xor rdx, rdx
        xor rax, rax
        call writeNum
        ;print newline character
    mov eax, 4 
    mov ebx, 1
    mov ecx, newline ;address of newline character
    mov edx, 1 ;#bytes to write
    int 0x80 
    jmp Exit
Exit:
        mov rax, 1
        mov rbx, 0
        int 0x80
