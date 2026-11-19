INCLUDE Irvine32.inc

SetConsoleOutputCP PROTO, wCodePageID:DWORD

.data
titleMsg  BYTE "두 정수의 사칙연산과 AX, BX, CX, DX 레지스터 출력",0
rangeMsg  BYTE "(입력 범위: -32768 ~ 32767)",0
prompt1   BYTE "첫 번째 정수 입력: ",0
prompt2   BYTE "두 번째 정수 입력: ",0
errMsg    BYTE "범위를 벗어났습니다. 다시 입력하세요.",0
addMsg    BYTE "[덧셈]   A + B = ",0
subMsg    BYTE "[뺄셈]   A - B = ",0
mulMsg    BYTE "[곱셈]   A * B = ",0
divMsg    BYTE "[나눗셈] A / B = ",0
remMsg    BYTE ",  나머지 = ",0
zeroMsg   BYTE "0으로 나눌 수 없습니다.",0
divOvMsg  BYTE "몫이 16비트 범위를 벗어나 나눌 수 없습니다.",0
ovMsg     BYTE "  (16비트 오버플로 발생, OF=1)",0
axMsg     BYTE "   AX = ",0
bxMsg     BYTE "   BX = ",0
cxMsg     BYTE "   CX = ",0
dxMsg     BYTE "   DX = ",0
hMsg      BYTE "h",0

numA      SWORD ?
numB      SWORD ?
savAX     WORD ?
savBX     WORD ?
savCX     WORD ?
savDX     WORD ?
savFlags  DWORD ?

.code
main PROC
    INVOKE SetConsoleOutputCP, 65001    ; 콘솔 출력을 UTF-8로 설정 (한글 깨짐 방지, 이 파일은 UTF-8로 저장)

    mov  edx, OFFSET titleMsg
    call WriteString
    call Crlf
    mov  edx, OFFSET rangeMsg
    call WriteString
    call Crlf
    call Crlf

    mov  edx, OFFSET prompt1
    call ReadWordInt
    mov  numA, ax
    mov  edx, OFFSET prompt2
    call ReadWordInt
    mov  numB, ax
    call Crlf

    call LoadOperands
    add  ax, bx
    call SaveRegs
    mov  edx, OFFSET addMsg
    call WriteString
    movsx eax, savAX
    call WriteInt
    call ShowOverflow
    call Crlf
    call ShowRegs

    call LoadOperands
    sub  ax, bx
    call SaveRegs
    mov  edx, OFFSET subMsg
    call WriteString
    movsx eax, savAX
    call WriteInt
    call ShowOverflow
    call Crlf
    call ShowRegs

    call LoadOperands
    imul bx                             ; DX:AX = AX * BX (32비트 곱)
    call SaveRegs
    mov  edx, OFFSET mulMsg
    call WriteString
    mov  ax, savDX
    shl  eax, 16
    mov  ax, savAX
    call WriteInt
    call Crlf
    call ShowRegs

    mov  edx, OFFSET divMsg
    call WriteString
    cmp  numB, 0
    je   DivZero
    cmp  numA, -32768
    jne  DoDiv
    cmp  numB, -1
    je   DivOver                        ; -32768 / -1 은 몫이 +32768이라 #DE 예외 발생
DoDiv:
    call LoadOperands
    cwd                                 ; AX의 부호를 DX로 확장 → DX:AX
    idiv bx                             ; AX = 몫, DX = 나머지
    call SaveRegs
    movsx eax, savAX
    call WriteInt
    mov  edx, OFFSET remMsg
    call WriteString
    movsx eax, savDX
    call WriteInt
    call Crlf
    call ShowRegs
    jmp  Done
DivZero:
    mov  edx, OFFSET zeroMsg
    call WriteString
    call Crlf
    jmp  Done
DivOver:
    mov  edx, OFFSET divOvMsg
    call WriteString
    call Crlf
Done:
    exit
main ENDP

ReadWordInt PROC
L1:
    push edx
    call WriteString
    call ReadInt
    pop  edx
    cmp  eax, -32768
    jl   Bad
    cmp  eax, 32767
    jg   Bad
    ret
Bad:
    push edx
    mov  edx, OFFSET errMsg
    call WriteString
    call Crlf
    pop  edx
    jmp  L1
ReadWordInt ENDP

LoadOperands PROC
    mov  ax, numA
    mov  bx, numB
    mov  cx, ax
    mov  dx, 0
    ret
LoadOperands ENDP

SaveRegs PROC
    pushfd                              ; 연산 직후의 플래그를 먼저 보관
    pop  savFlags
    mov  savAX, ax
    mov  savBX, bx
    mov  savCX, cx
    mov  savDX, dx
    ret
SaveRegs ENDP

ShowOverflow PROC
    test savFlags, 0800h                ; EFLAGS bit 11 = OF
    jz   L1
    push edx
    mov  edx, OFFSET ovMsg
    call WriteString
    pop  edx
L1:
    ret
ShowOverflow ENDP

ShowRegs PROC USES eax ebx edx
    mov  edx, OFFSET axMsg
    movzx eax, savAX
    call ShowOneReg
    mov  edx, OFFSET bxMsg
    movzx eax, savBX
    call ShowOneReg
    mov  edx, OFFSET cxMsg
    movzx eax, savCX
    call ShowOneReg
    mov  edx, OFFSET dxMsg
    movzx eax, savDX
    call ShowOneReg
    call Crlf
    call Crlf
    ret
ShowRegs ENDP

ShowOneReg PROC USES ebx
    call WriteString
    mov  ebx, TYPE WORD
    call WriteHexB
    mov  edx, OFFSET hMsg
    call WriteString
    ret
ShowOneReg ENDP

END main
