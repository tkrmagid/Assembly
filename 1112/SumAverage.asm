INCLUDE Irvine32.inc

SetConsoleOutputCP PROTO, wCodePageID:DWORD

COUNT = 5

.data
titleMsg  BYTE "정수 5개의 합계와 평균 구하기",0
promptMsg BYTE "번째 정수 입력: ",0
sumMsg    BYTE "합계: ",0
avgMsg    BYTE "평균: ",0
numbers   SDWORD COUNT DUP(?)
sum       SDWORD 0

.code
main PROC
    INVOKE SetConsoleOutputCP, 65001    ; 콘솔 출력을 UTF-8로 설정 (한글 깨짐 방지, 이 파일은 UTF-8로 저장)

    mov  edx, OFFSET titleMsg
    call WriteString
    call Crlf
    call Crlf

    mov  esi, OFFSET numbers
    mov  ecx, COUNT
    mov  ebx, 1
L1:
    mov  eax, ebx
    call WriteDec
    mov  edx, OFFSET promptMsg
    call WriteString
    call ReadInt
    mov  [esi], eax
    add  esi, TYPE numbers
    inc  ebx
    loop L1

    mov  esi, OFFSET numbers
    mov  ecx, COUNT
    mov  eax, 0
L2:
    add  eax, [esi]
    add  esi, TYPE numbers
    loop L2
    mov  sum, eax

    call Crlf
    mov  edx, OFFSET sumMsg
    call WriteString
    mov  eax, sum
    call WriteInt
    call Crlf

    mov  edx, OFFSET avgMsg
    call WriteString
    mov  ebx, sum
    mov  al, '+'
    cmp  ebx, 0
    jge  L3
    neg  ebx                            ; 음수면 부호만 따로 출력하고 절댓값으로 나눈다
    mov  al, '-'
L3:
    call WriteChar
    mov  eax, ebx
    mov  edx, 0
    mov  ecx, COUNT
    div  ecx                            ; EAX = 몫(정수부), EDX = 나머지
    call WriteDec
    mov  al, '.'
    call WriteChar
    mov  eax, edx
    shl  eax, 1                         ; 나머지/5 = (나머지*2)/10 → 소수 첫째 자리
    call WriteDec
    call Crlf

    exit
main ENDP
END main
