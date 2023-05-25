; Usermode 32-bit functions with some confusion :)
; I only implemented confusion for 32-bit operands, without checking
; Be aware that rep prefixes should precede the size override
; ml /c cmelib.asm

.model flat, stdcall

IDX_32CS    equ 4   ; index of the 32-bit cs descriptor
IDX_32CSND  equ 16  ; index of our special thing

GDTR struc
    Limit   dw ?
    Base    dq ?
GDTR ends

NS = 0

EnterSpecial macro
    NS = NS + 1
    EnterSpecial$ %NS
endm

EnterSpecial$ macro x
    push IDX_32CSND shl 3 + 3   ; usermode cs 32-bit confusion
    push special&x
    retf
special&x:
endm

S macro x
    db 066h                     ; operator size override
    x
endm

ExitSpecial macro
    NS = NS + 1
    ExitSpecial$ %NS
endm

ExitSpecial$ macro x
    S push IDX_32CS shl 3 + 3   ; usermode cs 32-bit normal
    S push special&x
    S retf
special&x:
endm

.code
CheckDriver proc
    sub esp, 10
    sgdt [esp]
    mov cx, [esp].GDTR.Limit
    sub cx, 0FFFFh
    setz al                     ; assume loaded if gdtr limit is 0xFFFF
    and eax, 1
    add esp, 10
    ret
CheckDriver endp
CalculateKey proc, n : dword
    mov eax, [ebp+8]            ; eax = key
    EnterSpecial
    S <mov edx, eax>            ; just playing a bit
    S push eax                  ; without doing
    S <xor edx, 09090C69Ah>     ; any special
    ExitSpecial
    pop ecx                     ; kind of
    add edx, ecx                ; calculation
    EnterSpecial
    mov ecx, 090900007h         ; }:-> you get
    S <rol edx, cl>             ; the idea
    ExitSpecial
    ror edx, 2                  ; :-)
    xor eax, edx
    ret
CalculateKey endp
end