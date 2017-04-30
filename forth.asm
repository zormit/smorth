section     .text
    extern  printf
    global  _start      ;must be declared for linker (ld)

_start:                 ;tell linker entry point
    mov     [RS0], esp  ;bottom of return stack
    mov     ebp, esp    ;top    of return stack
    add     esp, 1024   ;return stack 1kb (totally oversized, but whatevs)
    mov     [SP0], esp  ;bottom of (data) stack
    mov     esi, code   ;initialize forth instruction pointer (program counter)
    jmp     next        ;run!

next:
    lodsd               ;fetch [esi] into eax and increment esi.
    jmp     eax         ;execute next instruction

doliteral:
    lodsd               ;fetch [esi] into eax and increment esi.
    push     eax        ;push literal value to stack
    jmp     next

docolon:
    mov [ebp], esi      ;push forth instruction pointer
    sub ebp, 4
    mov eax, [esi - 4]  ;get caller of docolon
    add eax, 5          ;skip jmp docolon instruction (5 bytes)
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

dots:
;prints stacksize and stack values like gforth:
;<<stacksize>> <val 1> <val 2> ... <val n>
    mov     eax, [SP0]
    sub     eax, esp
    sar     eax, 2

    ;print stacksize
    push    eax
    push    fmt_stacksize
    call    printf
    add     esp, 8

    mov     ebx, [SP0]

.loop:
    cmp     ebx, esp    ;are we at top of stack?
    je      .end

    ;print space
    push    fmt_space
    call    printf
    add     esp, 4

    sub     ebx, 4      ;next value starting from base of stack
    mov     eax, [ebx]

    ;print value
    push    eax
    push    fmt_int
    call    printf
    add     esp, 8

    jmp     .loop

.end:
    ;print newline
    push    fmt_newline
    call    printf
    add     esp, 4

    jmp     next

;;;;;;;;;;;;;; NATIVE STACK OPERATORS ;;;;;;;;;;;

dup: ;( a -- a a)
    pop     eax
    push    eax
    push    eax
    jmp     next

swap: ;( a b -- b a)
    pop     ebx
    pop     eax
    push    ebx
    push    eax
    jmp     next

drop: ;( a -- )
    pop     eax
    jmp     next

over: ;( a b -- a b a)
    pop     ebx
    pop     eax
    push    eax
    push    ebx
    push    eax
    jmp     next

rot: ;( a b c -- b c a)
    pop     ecx
    pop     ebx
    pop     eax
    push    ebx
    push    ecx
    push    eax
    jmp     next

nip: ;( a b -- b)
    pop     ebx
    pop     eax
    push    ebx
    jmp     next

tuck: ;( a b -- b a b)
    pop     ebx
    pop     eax
    push    ebx
    push    eax
    push    ebx
    jmp     next

;;;;;;;;;;;;;; NATIVE MATH OPERATORS ;;;;;;;;;;;

star:
    pop     eax
    pop     ebx
    imul    eax, ebx
    push    eax         ; ignore edx.
    jmp     next

;;;;;;;;;;;;;; COMPOSITE WORDS ;;;;;;;;;;;;;;;;;

blank: ;( -- 32)        ; bl is reserved: it's a register
    jmp     docolon
    dd      doliteral
    dd      32
    dd      exit

square:
    jmp     docolon
    dd      dup
    dd      star
    dd      exit

teststackops:
    jmp     docolon
    dd      doliteral
    dd      1
    dd      doliteral
    dd      2
    dd      swap
    ;dd      dots    ; <2> 2 1
    dd      over
    ;dd      dots    ; <3> 2 1 2
    dd      drop
    ;dd      dots    ; <2> 2 1
    dd      doliteral
    dd      3
    dd      rot
    ;dd      dots    ; <3> 1 3 2
    dd      nip
    ;dd      dots    ; <2> 1 2
    dd      tuck
    dd      dots    ; final result: <3> 2 1 2
    dd      drop    ; clean up stack
    dd      drop
    dd      drop
    dd      exit


;;;;;;;;;;;;;; COMPILED FORTH CODE ;;;;;;;;;;;;;;;;;

code:
    dd      blank
    dd      dot
    dd      bye

section     .data

SP0             dd 0x0
RS0             dd 0x0

fmt_stacksize   db  '<%d>',0x0
fmt_int         db  '%d',0x0
fmt_space       db  ' ',0x0
fmt_newline     db  0xa,0x0
