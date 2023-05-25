; Crappy 64-bit driver to play a bit with descriptors :)
; ml64 cme64drv.asm
;   /link /subsystem:native /entry:DriverEntry /out:cme64drv.sys

includelib ntoskrnl.lib

extern KeSetSystemAffinityThread : proc
extern KeRevertToUserAffinityThreadEx : proc

IDX_32CS    equ 4   ; index of the 32-bit cs descriptor
IDX_32CSND  equ 16  ; create a 32-bit cs with DB=0 at this index

DRIVER_OBJECT struc
                    dq 13 dup(?)    ; won't use these fields
    DriverUnload    dq ?
DRIVER_OBJECT ends

GDTR struc
    Limit   dw ?
    Base    dq ?
GDTR ends

.data
old_entry   dq ?    ; if it was being used, we fucked up, but just
old_limit   dw ?    ; save them anyway, also use this as loaded flag :)

.code
SetupDescriptor proc
    sub rsp, 40
    mov rcx, 1
    call KeSetSystemAffinityThread              ; touch only 1st cpu
    sgdt [rsp+48]
    mov rdx, [rsp+48].GDTR.Base
    mov cx, [rsp+48].GDTR.Limit
    mov old_limit, cx
    add rdx, 8 * IDX_32CS
    mov r8, [rdx]                               ; copy current cs 32-bit
    add rdx, 8 * (IDX_32CSND - IDX_32CS)        ; to new index
    mov r9, [rdx]
    mov old_entry, r9
    mov r10, 0FFBFFFFFFFFFFFFFh                 ; but with DB bit down
    and r8, r10
    mov [rdx], r8
    mov word ptr [rsp+48].GDTR.Limit, 0FFFFh    ; and change gdtr limit
    lgdt fword ptr [rsp+48]
    mov rcx, rax
    call KeRevertToUserAffinityThreadEx
    add rsp, 40
    ret
SetupDescriptor endp
RestoreDescriptor proc
    sub rsp, 40
    mov rcx, 1
    call KeSetSystemAffinityThread              ; touch only 1st cpu
    sgdt [rsp+48]
    mov cx, old_limit
    mov rdx, [rsp+48].GDTR.Base
    mov [rsp+48].GDTR.Limit, cx                 ; restore limit
    add rdx, 8 * IDX_32CSND
    mov r8, old_entry
    mov [rdx], r8                               ; and old "entry"
    lgdt fword ptr [rsp+48]
    mov rcx, rax
    call KeRevertToUserAffinityThreadEx
    add rsp, 40
    ret
RestoreDescriptor endp
DriverEntry proc
    sub rsp, 40
    lea r10, DriverUnload
    mov [rcx].DRIVER_OBJECT.DriverUnload, r10
    call SetupDescriptor
    xor eax, eax
    add rsp, 40
    ret
DriverEntry endp
DriverUnload proc
    sub rsp, 40
    call RestoreDescriptor
    xor eax, eax
    add rsp, 40
    ret
DriverUnload endp
end