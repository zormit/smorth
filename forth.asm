section     .text
extern      printf
global      _start      ;must be declared for linker (ld)

_start:                 ;tell linker entry point
    mov     [RS0], esp  ;bottom of return stack
    mov     ebp, esp    ;top    of return stack
    add     esp, 1024   ;return stack 1kb (totally oversized, but whatevs)
    mov     [SP0], esp  ;bottom of (data) stack
    mov     esi, code   ;initialize forth instruction pointer (program counter)
    jmp     next        ;run!

next:
    mov     eax, [esi]  ;get address of next instruction
    add     esi, 0x4    ;advance forth instruction pointer
    jmp     eax         ;execute next instruction

docolon:
    mov [ebp], esi      ;push forth instruction pointer
    sub ebp, 4
    mov eax, [esi - 4]  ;get caller of docolon
    add eax, 8          ;skip docolon + nops
    mov esi, eax
    jmp next            ; execute

exit:
    add ebp, 4
    mov esi, [ebp]      ;pop forth instruction pointer
    jmp next

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

    sub     ebx, 4      ;next value starting from base of stack
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

three:
    push    3
    jmp     next

square:
    jmp     docolon
    nop
    nop
    nop
    dd      dup
    dd      star
    dd      exit

quadruplethree:
    jmp     docolon
    nop
    nop
    nop
    dd      three
    dd      square
    dd      square
    dd      exit

code:
    dd      three
    dd      dup
    dd      square
    dd      square
    dd      dot
    dd      quadruplethree
    dd      dot
    dd      bye

section     .data

SP0             dd 0x0
RS0             dd 0x0

fmt_stacksize   db  '<%d>',0x0
fmt_int         db  '%d',0x0
fmt_space       db  ' ',0x0
fmt_newline     db  0xa,0x0
