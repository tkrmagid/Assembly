# Programming Exercises

### **Q1.** **mReadkey Macro** — Create a macro that waits for a keystroke and returns the key that was pressed. The macro should include parameters for the ASCII code and keyboard scan code. Hint: call ReadChar from the book's link library. Write a program that tests your macro. Sample call:

```asm
.data
ascii BYTE ?
scan BYTE ?
.code
mReadkey ascii, scan
```

**정답:**
```asm
INCLUDE Irvine32.inc

mReadkey MACRO asciiCode, scanCode
    push eax
    call ReadChar                   ; AL = ASCII code, AH = scan code
    mov  asciiCode,al
    mov  scanCode,ah
    pop  eax
ENDM

.data
ascii BYTE ?
scan  BYTE ?
.code
main PROC
    mReadkey ascii, scan
    movzx eax,ascii
    call WriteHex
    call Crlf
    movzx eax,scan
    call WriteHex
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> ReadChar는 두 값을 한 번에 반환한다. ASCII 코드는 AL, 스캔 코드는 AH에 있으므로 매크로는 이를 호출자의 변수로 복사만 하면 된다. EAX를 저장하고 복원하면 주변 코드를 놀라게 하지 않고 어디서든 이 매크로를 쓸 수 있다. 인수는 변수 이름이고 매크로가 이를 텍스트로 치환하므로 목적지는 BYTE 변수여야 한다.

---

### **Q2.** **mWritestringAttr Macro** — (Requires reading ahead to Section 11.1.11.) Create a macro that writes a null-terminated string to the console with a given text color. The macro parameters should include the string name and the color. Hint: call SetTextColor from the book's link library. Write a program that tests your macro with several strings in different colors.

```asm
.data
myString db "Here is my string",0
.code
mWritestring myString, white
```

**정답:**
```asm
INCLUDE Irvine32.inc

mWritestringAttr MACRO stringName, color
    push eax
    push edx
    mov  eax,color
    call SetTextColor
    mov  edx,OFFSET stringName
    call WriteString
    pop  edx
    pop  eax
ENDM

.data
str1 BYTE "This line is white",0dh,0ah,0
str2 BYTE "This line is yellow",0dh,0ah,0
str3 BYTE "This line is green on blue",0dh,0ah,0

.code
main PROC
    mWritestringAttr str1, white
    mWritestringAttr str2, yellow
    mWritestringAttr str3, (blue * 16) + green
    mov eax,lightGray
    call SetTextColor
    exit
main ENDP
END main
```

> **해설:**
> SetTextColor는 EAX로 (배경색 × 16) + 전경색 속성을 받으므로, 색 상수 하나만 넘기면 전경색만 설정되고 (blue * 16) + green 같은 식을 넘기면 둘 다 설정된다. 어셈블러가 어셈블 시점에 그 식을 계산한다. 두 라이브러리 호출을 매크로 하나로 감싸면 호출 지점마다 네 줄이 줄어드는데, 매크로의 용도가 바로 이것이다.

---

### **Q3.** **mMove32 Macro** — Write a macro named mMove32 that receives two 32-bit memory operands. The macro should move the source operand to the destination operand. Write a program that tests your macro.

**정답:**
```asm
INCLUDE Irvine32.inc

mMove32 MACRO destination, source
    push eax
    mov  eax,source                 ; memory → register
    mov  destination,eax            ; register → memory
    pop  eax
ENDM

.data
val1 DWORD 12345678h
val2 DWORD ?

.code
main PROC
    mMove32 val2, val1
    mov eax,val2
    call WriteHex                   ; 12345678
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> x86에는 메모리 대 메모리 MOV가 없기 때문에 이 매크로가 존재한다. 값은 레지스터를 거쳐야 하고, 매크로가 그 세부를 숨겨 호출 지점이 이동 한 번처럼 읽히게 한다. 빌려 쓰는 레지스터는 저장하고 복원해야 한다. 그러지 않으면 매크로가 사용자의 EAX를 조용히 망친다.

---

### **Q4.** **mMult32 Macro** — Create a macro named mMult32 that multiplies two 32-bit memory operands and produces a 32-bit product. Write a program that tests your macro.

**정답:**
```asm
INCLUDE Irvine32.inc

mMult32 MACRO product, op1, op2
    push eax
    push edx
    mov  eax,op1
    imul DWORD PTR op2              ; EDX:EAX = op1 * op2
    mov  product,eax                ; keep the low 32 bits only
    pop  edx
    pop  eax
ENDM

.data
x   DWORD 5000
y   DWORD 300
res DWORD ?

.code
main PROC
    mMult32 res, x, y
    mov eax,res
    call WriteDec                   ; 1500000
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> 32비트 × 32비트 곱은 항상 EDX:EAX에 64비트 결과를 만들므로, "32비트 곱을 만든다"는 것은 EAX를 남기고 EDX를 버린다는 뜻이다. 실제 곱이 들어가기만 하면 괜찮고, JO나 EDX 검사로 확인할 수 있다. IMUL은 부호 있는 형태이며 부호 없는 피연산자에는 MUL을 쓴다. 호출자는 매크로가 EDX를 망칠 이유가 없다고 여기므로 EAX와 EDX 모두 보존해야 한다.

---

### **Q5.** **mReadInt Macro** — Create a macro named mReadInt that reads a 16- or 32-bit signed integer from standard input and returns the value in an argument. Use conditional operators to allow the macro to adapt to the size of the desired result. Write a program that tests the macro, passing it operands of various sizes.

**정답:**
```asm
INCLUDE Irvine32.inc

mReadInt MACRO intVar
    push eax
    call ReadInt                    ; EAX = signed integer
    IF (TYPE intVar) EQ 2           ; assembly-time test of the argument
        mov intVar,ax               ; 16-bit destination
    ELSEIF (TYPE intVar) EQ 4
        mov intVar,eax              ; 32-bit destination
    ELSE
        ECHO mReadInt: argument must be a word or a doubleword
        .ERR
    ENDIF
    pop eax
ENDM

.data
wordVal  SWORD ?
dwordVal SDWORD ?

.code
main PROC
    mReadInt wordVal
    mReadInt dwordVal
    movsx eax,wordVal
    call WriteInt
    call Crlf
    mov eax,dwordVal
    call WriteInt
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> TYPE 연산자는 어셈블 시점에 인수의 크기를 반환하므로, 매크로 안의 IF/ELSEIF 연쇄가 크기마다 다른 MOV를 생성할 수 있다. 선택된 줄만 어셈블되므로 이 검사는 실행 시간 비용이 없다. ECHO와 .ERR를 쓴 ELSE 분기를 더하면 잘못된 인수 크기가 조용히 틀린 코드가 되는 대신 어셈블 시점 오류 메시지가 되며, 이것이 10.3절이 권하는 방식이다.

---

### **Q6.** **mWriteInt Macro** — Create a macro named mWriteInt that writes a signed integer to standard output by calling the WriteInt library procedure. The argument passed to the macro can be a byte, word, or doubleword. Use conditional operators in the macro so it adapts to the size of the argument. Write a program that tests the macro, passing it arguments of different sizes.

**정답:**
```asm
INCLUDE Irvine32.inc

mWriteInt MACRO intVar
    push eax
    IF (TYPE intVar) EQ 1
        movsx eax,BYTE PTR intVar   ; sign-extend a byte
    ELSEIF (TYPE intVar) EQ 2
        movsx eax,WORD PTR intVar   ; sign-extend a word
    ELSEIF (TYPE intVar) EQ 4
        mov eax,intVar              ; already 32 bits
    ELSE
        ECHO mWriteInt: argument must be a byte, word, or doubleword
        .ERR
    ENDIF
    call WriteInt
    pop eax
ENDM

.data
b1 SBYTE  -42
w1 SWORD  -1234
d1 SDWORD -123456

.code
main PROC
    mWriteInt b1
    call Crlf
    mWriteInt w1
    call Crlf
    mWriteInt d1
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> WriteInt는 항상 EAX의 부호 있는 값을 표시하므로, 매크로의 일은 더 작은 피연산자를 EAX에 올바르게 넣는 것이다. 부호 있는 데이터에는 MOVZX나 부분 MOV가 아니라 MOVSX를 써야 한다. MOV AL,b1을 쓰면 EAX의 상위 24비트에 있던 값이 남아 −42가 큰 양수로 출력될 수 있다. 여기서도 인수의 TYPE에 맞는 분기만 어셈블된다.

---

### **Q7.** **The Professor's Lost Phone** — When the professor took the drunkard's walk around campus in Section 10.1.6, he lost his cell phone somewhere along the path. When you simulate the drunken walk, your program must drop the phone wherever the professor is standing at some random time interval. Each time you run the program, the cell phone will be lost at a different time interval (and location).

**정답:**
```asm
INCLUDE Irvine32.inc
WalkMax = 50
DrunkardWalk STRUCT
    path COORD WalkMax DUP(<0,0>)
    pathsUsed WORD 0
DrunkardWalk ENDS

.data
aWalk DrunkardWalk <>
phoneStep WORD ?                    ; which step the phone was dropped on
phoneLoc  COORD <>                  ; where it landed
msg BYTE "Phone lost at step ",0

.code
main PROC
    call Randomize
    mov eax,WalkMax                 ; pick the step in advance
    call RandomRange
    mov phoneStep,ax
    INVOKE TakeDrunkenWalk, ADDR aWalk
    exit
main ENDP

TakeDrunkenWalk PROC USES ecx edx esi, pWalk:PTR DrunkardWalk
    LOCAL currX:WORD, currY:WORD
    mov ecx,WalkMax
    mov esi,pWalk
    mov currX,25
    mov currY,25
L1: mov ax,currX                    ; record the current position
    mov (COORD PTR [esi]).X,ax
    mov ax,currY
    mov (COORD PTR [esi]).Y,ax

    mov ax,WalkMax                  ; is this the step where it drops?
    sub ax,cx                       ; step number = WalkMax - ECX
    .IF ax == phoneStep
        mov ax,currX
        mov phoneLoc.X,ax
        mov ax,currY
        mov phoneLoc.Y,ax
    .ENDIF

    mov eax,4                       ; choose a direction
    call RandomRange
    .IF eax == 0
        inc currY
    .ELSEIF eax == 1
        dec currY
    .ELSEIF eax == 2
        inc currX
    .ELSE
        dec currX
    .ENDIF
    add esi,TYPE COORD
    inc (DrunkardWalk PTR [pWalk]).pathsUsed
    loop L1
    ret
TakeDrunkenWalk ENDP
END main
```

> **해설:**
> 걸음을 시작하기 전에 떨어뜨릴 단계를 한 번 고르는 것이 매 걸음마다 확률을 굴리는 것보다 간단하고 균등하며, 전화가 정확히 한 번 떨어지는 것을 보장한다. 걸음이 이미 각 위치를 path 배열에 저장하므로 전화 위치는 현재 좌표의 사본일 뿐이다. 단계 번호만 기록하고 나중에 path[step]을 읽어도 똑같다. 구조체 필드 접근은 두 형태를 보여 준다. 직접(phoneLoc.X)과 포인터를 통한 간접((COORD PTR [esi]).X).

---

### **Q8.** **Drunkard's Walk with Probabilities** — When testing the DrunkardWalk program, you may have noticed that the professor doesn't seem to wander very far from the starting point, caused by an equal probability of moving in any direction. Modify the program so there is a 50% probability the professor will continue to walk in the same direction as the previous step, a 10% probability of reversing direction, and a 20% probability of turning either right or left. Assign a default starting direction before the loop begins.

**정답:**
```asm
; directions are numbered clockwise so that turning is arithmetic:
;   0 = north, 1 = east, 2 = south, 3 = west
;   right turn  = (dir + 1) MOD 4
;   left turn   = (dir + 3) MOD 4
;   reverse     = (dir + 2) MOD 4

.data
direction DWORD 0                   ; default starting direction: north

.code
ChooseDirection PROC USES ebx
    mov eax,10                      ; 10 equally likely outcomes
    call RandomRange
    .IF eax <= 4                    ; 0-4  → 50%  keep going
        mov ebx,0
    .ELSEIF eax == 5                ; 5    → 10%  reverse
        mov ebx,2
    .ELSEIF eax <= 7                ; 6,7  → 20%  turn right
        mov ebx,1
    .ELSE                           ; 8,9  → 20%  turn left
        mov ebx,3
    .ENDIF
    mov eax,direction
    add eax,ebx
    and eax,3                       ; MOD 4 (4 is a power of two)
    mov direction,eax
    ret
ChooseDirection ENDP

; inside the walk loop, replace the uniform choice with:
;   call ChooseDirection
;   .IF direction == 0
;       dec currY                   ; north
;   .ELSEIF direction == 1
;       inc currX                   ; east
;   .ELSEIF direction == 2
;       inc currY                   ; south
;   .ELSE
;       dec currX                   ; west
;   .ENDIF
```

> **해설:**
> 방향을 시계 방향으로 번호 붙이면 "우회전", "좌회전", "반대로"가 4로 나눈 나머지에서 +1, +3, +2가 되므로, 확률 규칙 전체가 덧셈 한 번과 AND 3으로 끝나고 경우 테이블이 필요 없다. 백분율은 똑같이 나올 수 있는 10가지 결과를 5, 1, 2, 2로 나눈 것이다. 눈에 보이는 효과는 걸음에 방향성이 생기는 것이다. 관성 덕분에 교수가 출발점에서 훨씬 멀리 가는데, 균등한 걸음의 기대 거리는 걸음 수의 제곱근으로만 늘어난다.

---

### **Q9.** **Shifting Multiple Doublewords** — Create a macro that shifts an array of 32-bit integers a variable number of bits in either direction, using the SHRD and SHLD instructions. Write a test program that tests your macro by shifting the same array in both directions and displaying the resulting values. You can assume that the array is in little-endian order. Sample declaration:

```asm
mShiftDoublewords MACRO arrayName, direction, numberOfBits
Parameters:
  arrayName      Name of the array
  direction      Right (R) or Left (L)
  numberOfBits   Number of bit positions to shift
```

**정답:**
```asm
INCLUDE Irvine32.inc

mShiftDoublewords MACRO arrayName, direction, numberOfBits
    LOCAL L1, L2
    push eax
    push ebx
    push ecx
    push esi
    IFIDNI <direction>,<R>                  ;; shift right
        mov esi,0                           ;; start at the low doubleword
        mov ecx,LENGTHOF arrayName - 1
    L1: mov eax,arrayName[esi + TYPE arrayName]   ;; the next-higher unit
        shrd arrayName[esi],eax,numberOfBits      ;; bits come in from it
        add esi,TYPE arrayName
        loop L1
        shr arrayName[esi],numberOfBits           ;; highest unit: fill with 0
    ELSEIFIDNI <direction>,<L>              ;; shift left
        mov esi,SIZEOF arrayName - TYPE arrayName ;; start at the high unit
        mov ecx,LENGTHOF arrayName - 1
    L2: mov eax,arrayName[esi - TYPE arrayName]   ;; the next-lower unit
        shld arrayName[esi],eax,numberOfBits
        sub esi,TYPE arrayName
        loop L2
        shl arrayName[esi],numberOfBits           ;; lowest unit: fill with 0
    ELSE
        ECHO mShiftDoublewords: direction must be R or L
        .ERR
    ENDIF
    pop esi
    pop ecx
    pop ebx
    pop eax
ENDM

.data
array DWORD 1,2,3,4

.code
main PROC
    mShiftDoublewords array, R, 4
    mShiftDoublewords array, L, 4
    exit
main ENDP
END main
```

> **해설:**
> SHRD dest,src,count가 바로 필요한 명령이다. dest를 오른쪽으로 밀면서 src의 하위 비트를 넣어 주는데, 여러 단위 시프트가 각 경계에서 요구하는 것이 그것이다. 오른쪽 시프트는 낮은 단위부터 위로(각 단위가 위 단위에서 비트를 빌린다), 왼쪽 시프트는 높은 단위부터 아래로 처리해야 한다. 방향을 반대로 하면 비트를 쓰기 전에 단위를 덮어쓴다. 가장 높은(또는 낮은) 단위는 이웃이 없으므로 평범한 SHR이나 SHL을 쓴다. IFIDNI는 어셈블 시점에 방향 인수를 대소문자 구분 없이 텍스트로 비교한다.

---

### **Q10.** **Three-Operand Instructions** — Some instruction sets permit arithmetic instructions with three operands. Assume EAX is reserved for macro operations and is not preserved; other registers modified by the macro must be preserved, and all parameters are signed memory doublewords. Write macros that simulate: a. add3 destination, source1, source2; b. sub3 destination, source1, source2 (destination = source1 − source2); c. mul3 destination, source1, source2; d. div3 destination, source1, source2 (destination = source1 / source2). Then write a program that tests your macros by implementing four arithmetic expressions, each involving multiple operations.

```asm
.data
temp DWORD ?
.code
add3 temp, w, y   ; temp = w + y
mul3 x, temp, z   ; x = temp * z
```

**정답:**
```asm
INCLUDE Irvine32.inc

add3 MACRO destination, source1, source2
    mov  eax,source1
    add  eax,source2
    mov  destination,eax
ENDM

sub3 MACRO destination, source1, source2
    mov  eax,source1
    sub  eax,source2
    mov  destination,eax
ENDM

mul3 MACRO destination, source1, source2
    push edx                        ;; IMUL writes EDX:EAX
    mov  eax,source1
    imul DWORD PTR source2
    mov  destination,eax            ;; keep the low 32 bits
    pop  edx
ENDM

div3 MACRO destination, source1, source2
    push ebx
    push edx
    mov  eax,source1
    cdq                             ;; sign-extend EAX into EDX:EAX
    mov  ebx,source2
    idiv ebx                        ;; signed division
    mov  destination,eax            ;; quotient (remainder is in EDX)
    pop  edx
    pop  ebx
ENDM

.data
w DWORD 10
x DWORD ?
y DWORD 20
z DWORD 3
temp DWORD ?

.code
main PROC
    add3 temp, w, y                 ; temp = 30
    mul3 x, temp, z                 ; x    = 90
    sub3 temp, x, w                 ; temp = 80
    div3 x, temp, z                 ; x    = 26
    exit
main ENDP
END main
```

> **해설:**
> 각 매크로는 같은 형태를 따른다. EAX로 읽고, 연산을 적용하고, 목적지에 저장한다. EAX가 "예약되어 보존되지 않는다"는 조건 덕분에 이렇게 짧아진다. 산술 쪽은 주의가 더 필요하다. IMUL은 EDX를 망치고, IDIV는 피연산자가 부호 있으므로 단순히 0으로 지우는 것이 아니라 CDQ로 준비한 EDX와 레지스터나 메모리 제수가 필요하며 즉시값은 안 된다. 매크로는 인라인으로 확장되므로 안에서 짝이 맞지 않는 push는 호출자의 스택을 망친다. 모든 push에 pop을 짝지어야 하며, div3처럼 역순으로 팝한다.

---
