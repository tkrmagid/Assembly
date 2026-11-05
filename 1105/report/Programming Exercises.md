# Programming Exercises

### **Q1.** **FindLargest Procedure** — Create a procedure named FindLargest that receives two parameters: a pointer to a signed doubleword array, and a count of the array's length. The procedure must return the value of the largest array member in EAX. Use the PROC directive with a parameter list when declaring the procedure. Preserve all registers (except EAX) that are modified by the procedure. Write a test program that calls FindLargest and passes three different arrays of different lengths, including negative values. Create a PROTO declaration for FindLargest.

**정답:**
```asm
INCLUDE Irvine32.inc
FindLargest PROTO, pArray:PTR SDWORD, count:DWORD

.data
array1 SDWORD -3,5,-22,7
array2 SDWORD 100,-4000,50,90,-1
array3 SDWORD -9,-8,-7

.code
main PROC
    INVOKE FindLargest, ADDR array1, LENGTHOF array1   ;  7
    call WriteInt
    call Crlf
    INVOKE FindLargest, ADDR array2, LENGTHOF array2   ;  100
    call WriteInt
    call Crlf
    INVOKE FindLargest, ADDR array3, LENGTHOF array3   ; -7
    call WriteInt
    call Crlf
    exit
main ENDP

FindLargest PROC USES esi ecx,
    pArray:PTR SDWORD, count:DWORD
    mov esi,pArray
    mov ecx,count
    mov eax,[esi]                   ; start with the first element,
                                    ; never with 0 — the array may be all negative
L1: cmp eax,[esi]
    jge L2                          ; signed comparison
    mov eax,[esi]
L2: add esi,TYPE SDWORD
    loop L1
    ret
FindLargest ENDP
END main
```

> **해설:**
> 이 프로시저의 정확성은 두 가지로 갈린다. 최댓값은 0이 아니라 첫 원소로 초기화해야 한다. 그러지 않으면 모두 음수인 배열에서 0이 반환된다. 그리고 비교는 부호 있는 점프(JGE)여야 한다. JAE를 쓰면 FFFFFFEAh가 거대한 부호 없는 값이어서 −22가 7보다 크게 보인다. USES를 쓰면 어셈블러가 ESI와 ECX의 push/pop을 생성하고 EAX는 반환값으로 남는다.

---

### **Q2.** **Chess Board** — Write a program that draws an 8 × 8 chess board, with alternating gray and white squares. You can use the SetTextColor and Gotoxy procedures from the Irvine32 library. Avoid the use of global variables, and use declared parameters in all procedures. Use short procedures that are focused on a single task.

**정답:**
```asm
INCLUDE Irvine32.inc
DrawBoard  PROTO, colorOne:DWORD, colorTwo:DWORD
DrawSquare PROTO, xPos:DWORD, yPos:DWORD, squareColor:DWORD

SQ_WIDTH  = 4
SQ_HEIGHT = 2

.code
main PROC
    call Clrscr
    INVOKE DrawBoard, gray, white
    mov eax,lightGray
    call SetTextColor
    exit
main ENDP

DrawBoard PROC USES eax ebx ecx edx,
    colorOne:DWORD, colorTwo:DWORD
    LOCAL row:DWORD, col:DWORD
    mov row,0
RowLoop:
    mov col,0
ColLoop:
    mov eax,row                     ; (row + col) even → first color
    add eax,col
    and eax,1
    .IF eax == 0
        mov ebx,colorOne
    .ELSE
        mov ebx,colorTwo
    .ENDIF
    mov eax,col
    imul eax,SQ_WIDTH               ; screen column
    mov edx,row
    imul edx,SQ_HEIGHT              ; screen row
    INVOKE DrawSquare, eax, edx, ebx
    inc col
    .IF col < 8
        jmp ColLoop
    .ENDIF
    inc row
    .IF row < 8
        jmp RowLoop
    .ENDIF
    ret
DrawBoard ENDP

DrawSquare PROC USES eax ecx edx,
    xPos:DWORD, yPos:DWORD, squareColor:DWORD
    LOCAL lineCount:DWORD
    mov eax,squareColor
    shl eax,4                       ; use the color as the background
    call SetTextColor
    mov lineCount,0
L1: mov edx,yPos
    add edx,lineCount
    mov dh,dl                       ; DH = row
    mov eax,xPos
    mov dl,al                       ; DL = column
    call Gotoxy
    mov ecx,SQ_WIDTH
    mov al,' '
L2: call WriteChar                  ; a run of colored spaces
    loop L2
    inc lineCount
    .IF lineCount < SQ_HEIGHT
        jmp L1
    .ENDIF
    ret
DrawSquare ENDP
END main
```

> **해설:**
> 칸의 색은 row + col의 짝·홀에만 달려 있으므로 1과 AND 한 번으로 번갈아 칠하는 관리를 대체할 수 있다. 위치와 색을 결정하는 DrawBoard와 한 칸을 칠하는 DrawSquare로 나눈 것이 문제에서 말하는 한 가지 일에 집중한 프로시저이며, 덕분에 다음 문제인 색상 애니메이션이 작은 변경으로 끝난다. 선언된 매개변수와 LOCAL 변수로 두 프로시저 모두 전역 변수 없이 동작한다.

---

### **Q3.** **Chess Board with Alternating Colors** — This exercise extends Exercise 2. Every 500 milliseconds, change the color of the colored squares and redisplay the board. Continue until you have shown the board 16 times, using all possible 4-bit background colors. (The white squares remain white throughout.)

**정답:**
```asm
INCLUDE Irvine32.inc
DrawBoard PROTO, colorOne:DWORD, colorTwo:DWORD   ; from Exercise 2

.code
main PROC
    call Clrscr
    mov ebx,0                       ; first background color
    mov ecx,16                      ; 16 possible 4-bit colors
L1: push ecx
    INVOKE DrawBoard, ebx, white    ; only the first color changes
    mov eax,500
    call Delay                      ; 500 ms between frames
    inc ebx
    pop ecx
    loop L1

    mov eax,lightGray
    call SetTextColor
    exit
main ENDP
END main
```

> **해설:**
> 2번 문제가 이미 두 색을 매개변수로 받으므로, 애니메이션은 기존 호출을 감싸는 루프만으로 끝나고 DrawBoard 내부는 전혀 바뀌지 않는다. 전역 변수 대신 매개변수를 쓴 실질적 이득이 이것이다. Delay는 EAX로 밀리초를 받고, 호출 전후로 ECX를 저장하면 프레임 카운터가 안전하다. 16색 중 하나는 흰색이라 한 프레임에서는 판이 비어 보인다.

---

### **Q4.** **FindThrees Procedure** — Create a procedure named FindThrees that returns 1 if an array has three consecutive values of 3 somewhere in the array; otherwise return 0. The procedure's input parameter list contains a pointer to the array and the array's size. Use the PROC directive with a parameter list, and preserve all registers (except EAX) that are modified. Write a test program that calls FindThrees several times with different arrays.

**정답:**
```asm
INCLUDE Irvine32.inc
FindThrees PROTO, pArray:PTR DWORD, arraySize:DWORD

.data
arr1 DWORD 1,2,3,3,3,4,5            ; → 1
arr2 DWORD 3,3,1,3,3,9,3            ; → 0
arr3 DWORD 1,2,3,3,3                ; → 1 (at the very end)
arr4 DWORD 3,3                      ; → 0 (too short)

.code
main PROC
    INVOKE FindThrees, ADDR arr1, LENGTHOF arr1
    call WriteDec
    call Crlf
    INVOKE FindThrees, ADDR arr2, LENGTHOF arr2
    call WriteDec
    call Crlf
    INVOKE FindThrees, ADDR arr3, LENGTHOF arr3
    call WriteDec
    call Crlf
    INVOKE FindThrees, ADDR arr4, LENGTHOF arr4
    call WriteDec
    call Crlf
    exit
main ENDP

FindThrees PROC USES esi ecx edx,
    pArray:PTR DWORD, arraySize:DWORD
    mov eax,0                       ; assume "not found"
    mov ecx,arraySize
    cmp ecx,3                       ; fewer than 3 elements: impossible
    jb  Done
    sub ecx,2                       ; only this many starting positions
    mov esi,pArray
L1: mov edx,3
    cmp [esi],edx
    jne Next
    cmp [esi+4],edx
    jne Next
    cmp [esi+8],edx
    jne Next
    mov eax,1                       ; three in a row
    jmp Done
Next:
    add esi,TYPE DWORD
    loop L1
Done:
    ret
FindThrees ENDP
END main
```

> **해설:**
> 미묘한 부분은 루프 범위다. 원소가 n개면 연속 3개의 시작 위치는 n−2개뿐이므로, n번 돌면 배열 끝을 두 칸 넘어 읽는다. 원소가 3개보다 적은 배열은 SUB ECX,2가 음수로 넘치기 전에 걸러야 한다. 세 위치를 단락 AND로 검사하면 불일치 시 바로 다음으로 넘어가고, 찾는 즉시 반환하면 나머지를 훑지 않는다.

---

### **Q5.** **DifferentInputs Procedure** — Write a procedure named DifferentInputs that returns EAX = 1 if the values of its three input parameters are all different; otherwise return EAX = 0. Use the PROC directive with a parameter list, create a PROTO declaration, and call it five times from a test program that passes different inputs.

**정답:**
```asm
INCLUDE Irvine32.inc
DifferentInputs PROTO, x:DWORD, y:DWORD, z:DWORD

.code
main PROC
    INVOKE DifferentInputs, 1, 2, 3     ; 1
    call ShowResult
    INVOKE DifferentInputs, 5, 5, 9     ; 0 (x = y)
    call ShowResult
    INVOKE DifferentInputs, 4, 7, 4     ; 0 (x = z)
    call ShowResult
    INVOKE DifferentInputs, 8, 3, 3     ; 0 (y = z)
    call ShowResult
    INVOKE DifferentInputs, 0, -1, 1    ; 1
    call ShowResult
    exit
main ENDP

ShowResult PROC
    call WriteDec
    call Crlf
    ret
ShowResult ENDP

DifferentInputs PROC USES ebx,
    x:DWORD, y:DWORD, z:DWORD
    mov eax,0                       ; assume at least two are equal
    mov ebx,x
    cmp ebx,y
    je  Done
    cmp ebx,z
    je  Done
    mov ebx,y
    cmp ebx,z
    je  Done
    mov eax,1                       ; all three pairs differ
Done:
    ret
DifferentInputs ENDP
END main
```

> **해설:**
> 값이 세 개면 쌍별 비교가 세 번 필요하다. x/y, x/z, y/z. 인접한 쌍만 비교하면 첫 값과 셋째 값이 같은 경우를 놓친다. 메모리 대 메모리 CMP는 허용되지 않으므로 한쪽을 먼저 레지스터로 읽어야 한다. EAX = 0으로 시작해 마지막에만 1로 설정하면 모든 실패 경로가 점프 하나로 끝난다.

---

### **Q6.** **Exchanging Integers** — Create an array of randomly ordered integers. Using the Swap procedure from Section 8.4.6 as a tool, write a loop that exchanges each consecutive pair of integers in the array.

**정답:**
```asm
INCLUDE Irvine32.inc
Swap PROTO, pValX:PTR DWORD, pValY:PTR DWORD
COUNT = 10
.data
array DWORD COUNT DUP(?)

.code
main PROC
    call Randomize
    mov esi,OFFSET array            ; fill with random values
    mov ecx,COUNT
L1: mov eax,100
    call RandomRange
    mov [esi],eax
    add esi,TYPE DWORD
    loop L1

    mov esi,OFFSET array            ; exchange each consecutive pair
    mov ecx,COUNT / 2
L2: INVOKE Swap, esi, esi + TYPE DWORD
    add esi,2 * TYPE DWORD
    loop L2
    exit
main ENDP

Swap PROC USES eax ecx esi edi,
    pValX:PTR DWORD, pValY:PTR DWORD
    mov esi,pValX                   ; the parameters are addresses…
    mov edi,pValY
    mov eax,[esi]                   ; …so they must be dereferenced
    xchg eax,[edi]
    mov [esi],eax
    ret
Swap ENDP
END main
```

> **해설:**
> Swap은 참조 매개변수를 받으므로 호출자는 주소를 전달하고 프로시저가 이를 역참조한다. 값 자체를 전달하면 스택의 사본 두 개만 교환되어 배열은 그대로 남는다. 루프는 COUNT/2번 돌며 두 원소씩 전진한다. 한 원소씩 가면 겹치는 쌍을 교환해 앞선 작업을 되돌린다. 개수가 홀수면 마지막 원소는 짝이 없을 뿐이다.

---

### **Q7.** **Greatest Common Divisor** — Write a recursive implementation of Euclid's algorithm for finding the greatest common divisor (GCD) of two integers. Write a test program that calls your GCD procedure five times, using the following pairs of integers: (5,20), (24,18), (11,7), (432,226), (26,13). After each procedure call, display the GCD.

**정답:**
```asm
INCLUDE Irvine32.inc
GCD PROTO, x:DWORD, y:DWORD

.data
pairs DWORD 5,20, 24,18, 11,7, 432,226, 26,13

.code
main PROC
    mov esi,0
    mov ecx,LENGTHOF pairs / 2
L1: push ecx
    INVOKE GCD, pairs[esi*4], pairs[esi*4+4]
    call WriteDec                   ; 5, 6, 1, 2, 13
    call Crlf
    add esi,2
    pop ecx
    loop L1
    exit
main ENDP

; GCD(x,y) = x            if y = 0
;          = GCD(y, x MOD y) otherwise
GCD PROC USES ebx edx,
    x:DWORD, y:DWORD
    mov eax,x
    mov ebx,y
    cmp ebx,0                       ; base case
    je  Done                        ; EAX already holds x
    mov edx,0                       ; clear the high dividend half
    div ebx                         ; EDX = x MOD y
    INVOKE GCD, ebx, edx            ; recurse: GCD(y, x MOD y)
Done:
    ret
GCD ENDP
END main
```

> **해설:**
> 재귀에는 기저 사례와 문제를 줄이는 호출이 필요하다. y = 0이 종료 조건이고 나머지는 항상 y보다 작으므로 깊이가 제한된다. 재귀 결과는 EAX로 도착하고 그대로 두기만 하므로 중첩 호출 뒤에 추가 작업이 없다. 각 단계는 자신만의 x, y 사본을 가진 스택 프레임을 얻으므로 USES에 적은 레지스터 외에는 직접 저장할 것이 없다. 그리고 EAX는 거기 들어가면 안 된다.

---

### **Q8.** **Counting Matching Elements** — Write a procedure named CountMatches that receives pointers to two arrays of signed doublewords and a third parameter indicating the length of the two arrays. For each element x(i) in the first array, if the corresponding y(i) in the second array is equal, increment a count; return the count in EAX. Write a test program that passes pointers to two different pairs of arrays. Use INVOKE to call your procedure with stack parameters, create a PROTO declaration, and save and restore any registers (other than EAX) that your procedure changes.

**정답:**
```asm
INCLUDE Irvine32.inc
CountMatches PROTO, pArr1:PTR SDWORD, pArr2:PTR SDWORD, count:DWORD

.data
a1 SDWORD  1, 2, 3, 4, 5
b1 SDWORD  1,-2, 3,-4, 5            ; 3 matches
a2 SDWORD -10,-20,-30
b2 SDWORD -10, 20,-30               ; 2 matches

.code
main PROC
    INVOKE CountMatches, ADDR a1, ADDR b1, LENGTHOF a1
    call WriteDec
    call Crlf
    INVOKE CountMatches, ADDR a2, ADDR b2, LENGTHOF a2
    call WriteDec
    call Crlf
    exit
main ENDP

CountMatches PROC USES esi edi ecx edx,
    pArr1:PTR SDWORD, pArr2:PTR SDWORD, count:DWORD
    mov eax,0                       ; the running count
    mov esi,pArr1
    mov edi,pArr2
    mov ecx,count
L1: mov edx,[esi]                   ; one operand must be in a register
    cmp edx,[edi]
    jne L2
    inc eax
L2: add esi,TYPE SDWORD
    add edi,TYPE SDWORD
    loop L1
    ret
CountMatches ENDP
END main
```

> **해설:**
> 포인터 두 개가 배열마다 하나씩 나란히 전진하고 카운트는 EAX에 누적된다. CMP는 메모리 피연산자 두 개를 받을 수 없으므로 원소 하나를 먼저 레지스터로 읽어야 한다. 같은지 여부는 부호 유무와 무관하므로 JE가 어느 쪽이든 동작한다. 차이를 한계와 비교해야 하는 다음 문제보다 이것이 간단한 이유다.

---

### **Q9.** **Counting Nearly Matching Elements** — Write a procedure named CountNearMatches that receives pointers to two arrays of signed doublewords, a parameter indicating the length of the two arrays, and a parameter indicating the maximum allowed difference (called diff) between any two matching elements. For each element x(i), if the difference between it and the corresponding y(i) is less than or equal to diff, increment a count; return the count in EAX. Write a test program that passes pointers to two different pairs of arrays, using INVOKE and a PROTO declaration, and save and restore any registers (other than EAX) that your procedure changes.

**정답:**
```asm
INCLUDE Irvine32.inc
CountNearMatches PROTO, pArr1:PTR SDWORD, pArr2:PTR SDWORD,
                        count:DWORD, diff:DWORD

.data
a1 SDWORD 10, 20, 30, 40
b1 SDWORD 11, 25, 29, 40            ; diff 2 → 3 near matches
a2 SDWORD -5, 0, 5
b2 SDWORD -7, 3, 5                  ; diff 2 → 2 near matches

.code
main PROC
    INVOKE CountNearMatches, ADDR a1, ADDR b1, LENGTHOF a1, 2
    call WriteDec
    call Crlf
    INVOKE CountNearMatches, ADDR a2, ADDR b2, LENGTHOF a2, 2
    call WriteDec
    call Crlf
    exit
main ENDP

CountNearMatches PROC USES esi edi ecx edx,
    pArr1:PTR SDWORD, pArr2:PTR SDWORD, count:DWORD, diff:DWORD
    mov eax,0
    mov esi,pArr1
    mov edi,pArr2
    mov ecx,count
L1: mov edx,[esi]
    sub edx,[edi]                   ; difference, possibly negative
    jns L2
    neg edx                         ; take the absolute value
L2: cmp edx,diff
    jg  L3                          ; difference too large
    inc eax
L3: add esi,TYPE SDWORD
    add edi,TYPE SDWORD
    loop L1
    ret
CountNearMatches ENDP
END main
```

> **해설:**
> 여기서 "차이"는 거리를 뜻하므로 비교 전에 부호를 없애야 한다. 그러지 않으면 10과 40의 차이가 −30이 되어 어떤 양수 diff보다도 작아 근사 일치로 세어진다. JNS 뒤에 NEG가 가장 저렴한 절댓값이다. 나머지는 매개변수 하나가 추가된 앞 문제와 같다.

---

### **Q10.** **Show Procedure Parameters** — Write a procedure named ShowParams that displays the address and hexadecimal value of the 32-bit parameters on the runtime stack of the procedure that called it, in order from the lowest address to the highest. Input to the procedure is a single integer indicating the number of parameters to display. For example, if main calls INVOKE MySample, 1234h, 5000h, 6543h, then inside MySample calling ShowParams with paramCount = 3 should display:

```asm
Stack parameters:
---------------------------
Address 0012FF80 = 00001234
Address 0012FF84 = 00005000
Address 0012FF88 = 00006543
```

**정답:**
```asm
INCLUDE Irvine32.inc
.data
header BYTE "Stack parameters:",0dh,0ah
       BYTE "---------------------------",0dh,0ah,0
label1 BYTE "Address ",0
label2 BYTE " = ",0

.code
main PROC
    INVOKE MySample, 1234h, 5000h, 6543h
    exit
main ENDP

MySample PROC first:DWORD, second:DWORD, third:DWORD
    push 3                          ; paramCount
    call ShowParams
    ret
MySample ENDP

; ShowParams: displays the caller's stack parameters
;   Receives: one stack parameter = the number of parameters to display
ShowParams PROC
    push ebp
    mov  ebp,esp
    pushad
    ; [ebp]    = ShowParams' saved EBP
    ; [ebp+4]  = return address into MySample
    ; [ebp+8]  = paramCount
    ; [ebp]    also points to MySample's saved EBP, so:
    mov esi,[ebp]                   ; ESI = MySample's EBP
    add esi,8                       ; first parameter of the caller
    mov ecx,[ebp+8]                 ; how many to show

    mov edx,OFFSET header
    call WriteString
L1: mov edx,OFFSET label1
    call WriteString
    mov eax,esi                     ; the address itself
    call WriteHex
    mov edx,OFFSET label2
    call WriteString
    mov eax,[esi]                   ; the value stored there
    call WriteHex
    call Crlf
    add esi,4                       ; next parameter, higher address
    loop L1

    popad
    pop ebp
    ret 4                           ; discard paramCount
ShowParams ENDP
END main
```

> **해설:**
> 이 문제는 사실 스택 프레임 구조를 이해했는지 확인하는 것이다. 자신의 프롤로그가 끝난 뒤 ShowParams는 [ebp]에서 호출자의 EBP를 찾는다. 호출자가 EBP를 푸시했고 ShowParams가 그 값을 다시 푸시했기 때문이다. 호출자의 첫 매개변수는 저장된 EBP와 반환 주소를 지나 그보다 8바이트 위에 있다. 4씩 위로 이동하면 매개변수가 낮은 주소에서 높은 주소 순으로 나열되는데, 이는 인수가 푸시된 순서의 역순이다. RET 4는 paramCount를 제거하며, INVOKE가 사용하는 STDCALL 규약과 일치한다.

---
