section     .text
extern      printf
global      _start      ;must be declared for linker (ld)

_start:                 ;tell linker entry point
    mov     [SP0], esp  ;store bottom of the stack
    mov     esi, code   ;initialize forth instruction pointer (program counter)
    jmp     next        ;run!

next:
    mov     eax, [esi]  ;get address of next instruction
    add     esi, 0x4    ;advance forth instruction pointer
    jmp     eax         ;execute next instruction

bye:
    mov     ebx,0       ;error_code
    mov     eax,1       ;system call number (sys_exit)
    int     0x80        ;call kernel

dot:
    push    fmt_int
    call    printf
    add     esp, 8
    push    fmt_newline
    call    printf
    add     esp, 4
    jmp     next

dots:                   ;prints stacksize and stack values
    mov     eax, [SP0]
    sub     eax, esp
    sar     eax, 2

    push    eax
    push    fmt_stacksize
    call    printf
    add     esp, 8

    mov     ebx, [SP0]

.loop:
    cmp     ebx, esp
    je      .end

    push    fmt_space
    call    printf
    add     esp, 4

    sub     ebx, 4 ; bottom of stack below first value
    mov     eax, [ebx]
    push    eax
    push    fmt_int
    call    printf
    add     esp, 8
    jmp     .loop

.end:
    push    fmt_newline
    call    printf
    add     esp, 4

    jmp     next

dup:
    pop     eax
    push    eax
    push    eax
    jmp     next

star:
    pop     eax
    pop     ebx
    imul    eax, ebx
    push    eax         ; ignore edx.
    jmp     next

fortythree:
    push    43
    jmp     next

three:
    push    3
    jmp     next

code:
    dd      fortythree
    dd      three
    dd      dup
    dd      star
    dd      dots
    dd      dots
    dd      dot
    dd      bye

section     .data

SP0             dd 0x0

fmt_stacksize   db  '<%d>',0x0
fmt_int         db  '%d',0x0
fmt_space       db  ' ',0x0
fmt_newline     db  0xa,0x0
