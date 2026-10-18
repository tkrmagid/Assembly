# Programming Exercises

### **Q1.** **Filling an Array** — Create a procedure that fills an array of doublewords with N random integers, making sure the values fall within the range j...k, inclusive. When calling the procedure, pass a pointer to the array that will hold the data, pass N, and pass the values of j and k. Preserve all register values between calls to the procedure. Write a test program that calls the procedure twice, using different values for j and k. Verify your results using a debugger.

**정답:**
```asm
INCLUDE Irvine32.inc
COUNT = 20
.data
array1 DWORD COUNT DUP(?)
array2 DWORD COUNT DUP(?)

.code
main PROC
    call Randomize
    mov esi,OFFSET array1
    mov ecx,COUNT                   ; N
    mov ebx,10                      ; j
    mov edx,50                      ; k
    call FillArray
    mov esi,OFFSET array2
    mov ecx,COUNT
    mov ebx,-100                    ; j
    mov edx,-50                     ; k
    call FillArray
    exit
main ENDP

; FillArray: fills ECX doublewords with random values in EBX..EDX
;   Receives: ESI = array pointer, ECX = N, EBX = j, EDX = k
FillArray PROC
    pushad
    mov edi,edx
    sub edi,ebx
    inc edi                         ; span = k - j + 1 (inclusive)
L1: mov eax,edi
    call RandomRange                ; EAX = 0 .. span-1
    add eax,ebx                     ; shift into j .. k
    mov [esi],eax
    add esi,TYPE DWORD
    loop L1
    popad
    ret
FillArray ENDP
END main
```

> **해설:**
> RandomRange는 0 … n−1을 반환하므로 양끝을 모두 포함하려면 범위가 k − j + 1이어야 한다. +1을 빼먹으면 k가 조용히 제외된다. j를 더해 구간을 옮기며, −100 … −50 같은 음수 범위에도 그대로 동작한다. PUSHAD/POPAD로 모든 레지스터 보존 요구를 만족시킨다.

---

### **Q2.** **Summing Array Elements in a Range** — Create a procedure that returns the sum of all array elements falling within the range j...k (inclusive). Write a test program that calls the procedure twice, passing a pointer to a signed doubleword array, the size of the array, and the values of j and k. Return the sum in the EAX register, and preserve all other register values between calls.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
array SDWORD -30,15,60,-5,42,8,100,-70

.code
main PROC
    mov esi,OFFSET array
    mov ecx,LENGTHOF array
    mov ebx,0                       ; j
    mov edx,50                      ; k
    call SumInRange                 ; EAX = 15+42+8 = 65
    call WriteInt
    call Crlf

    mov esi,OFFSET array
    mov ecx,LENGTHOF array
    mov ebx,-100
    mov edx,0
    call SumInRange                 ; EAX = -30-5-70 = -105
    call WriteInt
    call Crlf
    exit
main ENDP

; SumInRange: adds the elements that fall in EBX..EDX
;   Receives: ESI = array, ECX = count, EBX = j, EDX = k
;   Returns:  EAX = sum
SumInRange PROC
    push esi
    push ecx
    push edi
    mov eax,0                       ; running sum
L1: mov edi,[esi]
    cmp edi,ebx                     ; edi < j ?
    jl  L2                          ; signed comparison
    cmp edi,edx                     ; edi > k ?
    jg  L2
    add eax,edi                     ; in range: accumulate
L2: add esi,TYPE SDWORD
    loop L1
    pop edi
    pop ecx
    pop esi
    ret
SumInRange ENDP
END main
```

> **해설:**
> 부호 있는 데이터에는 부호 있는 점프 JL과 JG를 써야 한다. JB와 JA를 쓰면 −30이 거대한 부호 없는 값으로 취급되어 잘못 포함된다. 두 검사는 단락 AND를 이룬다. 첫 검사가 실패하면 바로 루프 증가로 건너뛴다. EAX는 반환 레지스터이므로 프로시저가 복원하지 않아야 하는 유일한 레지스터다.

---

### **Q3.** **Test Score Evaluation** — Create a procedure named CalcGrade that receives an integer value between 0 and 100 and returns a single capital letter in the AL register (A: 90–100, B: 80–89, C: 70–79, D: 60–69, F: 0–59). Preserve all other register values between calls. Write a test program that generates 10 random integers between 50 and 100, inclusive, passing each one to CalcGrade and displaying the integer with its letter grade.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
space BYTE "  ",0

.code
main PROC
    call Randomize
    mov ecx,10
L1: push ecx
    mov eax,51                      ; 50..100 inclusive → span 51
    call RandomRange
    add eax,50
    mov ebx,eax                     ; keep the score
    call WriteDec
    mov edx,OFFSET space
    call WriteString
    mov eax,ebx
    call CalcGrade                  ; AL = letter
    call WriteChar
    call Crlf
    pop ecx
    loop L1
    exit
main ENDP

; CalcGrade: converts a score to a letter grade
;   Receives: EAX = score (0..100)
;   Returns:  AL  = 'A'..'F'
CalcGrade PROC
    cmp eax,90
    jae A_               ; unsigned is fine: the score is never negative
    cmp eax,80
    jae B_
    cmp eax,70
    jae C_
    cmp eax,60
    jae D_
    mov al,'F'
    ret
A_: mov al,'A'
    ret
B_: mov al,'B'
    ret
C_: mov al,'C'
    ret
D_: mov al,'D'
    ret
CalcGrade ENDP
END main
```

> **해설:**
> 위에서 아래로 경계를 검사하면 비교마다 검사 하나로 충분하다. 90이 아니라고 판정된 뒤에는 "80 이상"만으로 80–89를 뜻한다. AL의 반환값이 EAX에 있던 점수의 하위 바이트를 덮어쓰므로, 호출자는 호출 전에 EBX에 사본을 둔다.

---

### **Q4.** **College Registration** — Using the College Registration example from Section 6.7.3 as a starting point: recode the logic using CMP and conditional jump instructions instead of the .IF and .ELSEIF directives; perform range checking on the credits value (it cannot be less than 1 or greater than 30) and display an error message for an invalid entry; prompt the user for the grade average and credits values; and display a message showing the outcome, such as "The student can register" or "The student cannot register".

**정답:**
```asm
INCLUDE Irvine32.inc
.data
askAvg  BYTE "Enter grade average (0-400): ",0
askCred BYTE "Enter credits (1-30): ",0
errCred BYTE "Error: credits must be between 1 and 30.",0
canReg  BYTE "The student can register.",0
noReg   BYTE "The student cannot register.",0
gradeAverage WORD ?
credits      WORD ?

.code
main PROC
    mov edx,OFFSET askAvg
    call WriteString
    call ReadInt
    mov gradeAverage,ax
    mov edx,OFFSET askCred
    call WriteString
    call ReadInt
    mov credits,ax

    cmp ax,1                        ; range check first
    jl  BadCredits
    cmp ax,30
    jg  BadCredits

    mov ax,gradeAverage             ; rules from Section 6.7.3
    cmp ax,350                      ; average > 350 ?
    jle Rule2
    cmp credits,16                  ; and credits <= 16
    jle Yes
    jmp No
Rule2:
    cmp ax,250                      ; average > 250 ?
    jle Rule3
    cmp credits,12                  ; and credits <= 12
    jle Yes
    jmp No
Rule3:
    cmp credits,10                  ; otherwise credits <= 10
    jle Yes
No: mov edx,OFFSET noReg
    jmp Display
Yes: mov edx,OFFSET canReg
Display:
    call WriteString
    call Crlf
    exit
BadCredits:
    mov edx,OFFSET errCred
    call WriteString
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> 각 .IF/.ELSEIF 분기는 CMP와 다음 규칙으로 가는 조건 점프가 되고, 각 규칙은 두 검사의 AND이므로 어느 한쪽이 실패하면 다음 규칙으로 내려간다. 결정 논리 앞에서 범위를 검사하면 잘못된 입력이 규칙에 도달하지 않는다. ReadInt가 부호 있는 값을 반환하므로 부호 있는 점프(JL, JG, JLE)가 맞다.

---

### **Q5.** **Boolean Calculator (1)** — Create a program that functions as a simple boolean calculator for 32-bit integers. It should display a menu asking the user to choose from: 1. x AND y, 2. x OR y, 3. NOT x, 4. x XOR y, 5. Exit program. When the user makes a choice, call a procedure that displays the name of the operation about to be performed. You must implement this procedure using the Table-Driven Selection technique shown in Section 6.5.4.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
menu BYTE "Boolean Calculator",0dh,0ah
     BYTE "  1. x AND y",0dh,0ah
     BYTE "  2. x OR y",0dh,0ah
     BYTE "  3. NOT x",0dh,0ah
     BYTE "  4. x XOR y",0dh,0ah
     BYTE "  5. Exit program",0dh,0ah
     BYTE "Choice: ",0

name1 BYTE "AND operation",0
name2 BYTE "OR operation",0
name3 BYTE "NOT operation",0
name4 BYTE "XOR operation",0

; lookup table: key byte followed by the address of the name
CaseTable BYTE '1'
          DWORD name1
          BYTE '2'
          DWORD name2
          BYTE '3'
          DWORD name3
          BYTE '4'
          DWORD name4
NumberOfEntries = 4
EntrySize = ($ - CaseTable) / NumberOfEntries

.code
main PROC
MenuLoop:
    call Clrscr
    mov edx,OFFSET menu
    call WriteString
    call ReadChar                   ; AL = the key that was pressed
    call Crlf
    cmp al,'5'
    je  Quit
    call ShowOperation
    call WaitMsg
    jmp MenuLoop
Quit:
    exit
main ENDP

; ShowOperation: table-driven selection (Section 6.5.4)
;   Receives: AL = menu choice
ShowOperation PROC
    mov ebx,OFFSET CaseTable
    mov ecx,NumberOfEntries
L1: cmp al,[ebx]                    ; does the key match this entry?
    jne L2
    mov edx,[ebx+1]                 ; yes: load the string address
    call WriteString
    call Crlf
    jmp L3                          ; done
L2: add ebx,EntrySize               ; next table entry
    loop L1
L3: ret
ShowOperation ENDP
END main
```

> **해설:**
> 테이블 기반 선택은 CMP/JE 쌍의 연쇄를 (키, 주소) 쌍 테이블을 도는 루프로 대체하므로, 메뉴 항목을 추가할 때 코드를 고치는 대신 테이블 행만 추가하면 된다. EntrySize는 현재 위치 카운터($)로 어셈블러가 계산하므로 항목 구성이 바뀌어도 값이 맞는다. 여기 저장된 주소는 문자열을 가리키며, 같은 기법에 CALL EBX를 쓰면 프로시저로 분기할 수 있다.

---

### **Q6.** **Boolean Calculator (2)** — Continue the solution program from Exercise 5 by implementing the following procedures: AND_op (prompt for two hexadecimal integers, AND them and display the result in hexadecimal), OR_op, NOT_op (one integer), and XOR_op.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
askX  BYTE "Enter hexadecimal x: ",0
askY  BYTE "Enter hexadecimal y: ",0
shown BYTE "Result: ",0

.code
; each operation procedure follows the same shape
AND_op PROC
    call GetTwo                     ; EAX = x, EBX = y
    and eax,ebx
    call ShowResult
    ret
AND_op ENDP

OR_op PROC
    call GetTwo
    or  eax,ebx
    call ShowResult
    ret
OR_op ENDP

XOR_op PROC
    call GetTwo
    xor eax,ebx
    call ShowResult
    ret
XOR_op ENDP

NOT_op PROC
    mov edx,OFFSET askX
    call WriteString
    call ReadHex                    ; EAX = x
    not eax
    call ShowResult
    ret
NOT_op ENDP

; GetTwo: reads two hex integers into EAX and EBX
GetTwo PROC
    mov edx,OFFSET askX
    call WriteString
    call ReadHex
    push eax
    mov edx,OFFSET askY
    call WriteString
    call ReadHex
    mov ebx,eax
    pop eax
    ret
GetTwo ENDP

; ShowResult: displays EAX in hexadecimal
ShowResult PROC
    push eax
    mov edx,OFFSET shown
    call WriteString
    pop eax
    call WriteHex
    call Crlf
    ret
ShowResult ENDP
```

> **해설:**
> ReadHex는 16진 정수를 EAX로 읽고 WriteHex는 EAX를 16진수로 표시하며, 이는 비트 연산에 자연스러운 형식이다. 각 연산의 효과가 자릿수별로 보인다. 입력과 출력을 GetTwo와 ShowResult로 분리하면 네 개의 연산 프로시저가 각각 명령 하나로 줄어든다. 두 번째 ReadHex가 EAX를 덮어쓰므로 첫 값은 푸시해 두어야 한다.

---

### **Q7.** **Probabilities and Colors** — Write a program that randomly chooses among three different colors for displaying text on the screen. Use a loop to display 20 lines of text, each with a randomly chosen color. The probabilities are to be: white = 30%, blue = 10%, green = 60%. Suggestion: generate a random integer between 0 and 9 — 0 to 2 chooses white, 3 chooses blue, 4 to 9 chooses green.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
msg BYTE "This line has a randomly chosen color",0

.code
main PROC
    call Randomize
    mov ecx,20
L1: push ecx
    mov eax,10                      ; 0..9
    call RandomRange
    cmp eax,2                       ; 0,1,2 → 30%
    jbe UseWhite
    cmp eax,3                       ; 3     → 10%
    je  UseBlue
    mov eax,green                   ; 4..9  → 60%
    jmp SetIt
UseWhite:
    mov eax,white
    jmp SetIt
UseBlue:
    mov eax,blue
SetIt:
    call SetTextColor
    mov edx,OFFSET msg
    call WriteString
    call Crlf
    pop ecx
    loop L1

    mov eax,lightGray
    call SetTextColor
    exit
main ENDP
END main
```

> **해설:**
> 확률을 범위로 바꾼다. 똑같이 나올 수 있는 10가지 결과를 3, 1, 6개 그룹으로 나누면 각 그룹의 크기가 곧 확률이다. 범위가 겹치지 않도록 비교 순서를 정한다. "≤ 2"를 "= 3"보다 먼저 검사하면 각 결과가 정확히 한 분기에 들어간다. 프로그램을 여러 번 실행해 줄 수를 세어 분포가 대략 맞는지 확인하자.

---

### **Q8.** **Message Encryption** — Revise the encryption program in Section 6.3.4: create an encryption key consisting of multiple characters, and use it to encrypt and decrypt the plaintext by XORing each character of the key against a corresponding byte in the message. Repeat the key as many times as necessary until all plaintext bytes are translated (for example, with the key "ABXmv#7").

**정답:**
```asm
INCLUDE Irvine32.inc
KEY_LEN = 7
.data
key      BYTE "ABXmv#7"
buffer   BYTE "This is the plain text message",0
BUF_SIZE = ($ - buffer) - 1

.code
main PROC
    call Translate                  ; encrypt
    mov edx,OFFSET buffer
    call WriteString
    call Crlf
    call Translate                  ; XOR again → decrypt
    mov edx,OFFSET buffer
    call WriteString
    call Crlf
    exit
main ENDP

; Translate: XORs the buffer with a repeating key
Translate PROC
    mov ecx,BUF_SIZE
    mov esi,0                       ; index into the buffer
    mov edi,0                       ; index into the key
L1: mov al,key[edi]
    xor buffer[esi],al
    inc esi
    inc edi
    cmp edi,KEY_LEN                 ; past the end of the key?
    jb  L2
    mov edi,0                       ; wrap back to its start
L2: loop L1
    ret
Translate ENDP
END main
```

> **해설:**
> 두 번째 인덱스가 키를 훑고 키 길이에 도달하면 0으로 되돌아가는데, 이것이 "키를 반복한다"는 뜻이다. 나눗셈을 쓰면 edi = esi MOD KEY_LEN으로도 같다. XOR는 자기 자신이 역연산이므로 같은 프로시저를 두 번 호출하면 원문이 돌아온다. 또한 이 때문에 여러 문자 키가 한 문자보다 강하다. 같은 평문 바이트가 더 이상 같은 암호문이 되지 않는다.

---

### **Q9.** **Validating a PIN** — Each digit of a 5-digit PIN has an acceptable range (digit 1: 5–9, digit 2: 2–5, digit 3: 4–8, digit 4: 1–4, digit 5: 3–6), so 52413 is valid but 43534 and 64535 are not. Create a procedure named Validate_PIN that receives a pointer to an array of bytes containing a 5-digit PIN. Declare two arrays holding the minimum and maximum range values and use them to validate each digit. If any digit is outside its range, immediately return the digit's position (1 to 5) in EAX; if the entire PIN is valid, return 0. Preserve all other registers. Write a test program that calls Validate_PIN at least four times with both valid and invalid arrays.

**정답:**
```asm
INCLUDE Irvine32.inc
PIN_LEN = 5
.data
minimum BYTE 5,2,4,1,3
maximum BYTE 9,5,8,4,6
pin1 BYTE 5,2,4,1,3                 ; valid   → 0
pin2 BYTE 4,3,5,3,4                 ; digit 1 → 1
pin3 BYTE 6,4,5,3,5                 ; digit 5 → 5
pin4 BYTE 9,5,8,4,6                 ; valid   → 0
msg  BYTE "Result: ",0

.code
main PROC
    mov esi,OFFSET pin1
    call Report
    mov esi,OFFSET pin2
    call Report
    mov esi,OFFSET pin3
    call Report
    mov esi,OFFSET pin4
    call Report
    exit
main ENDP

Report PROC
    call Validate_PIN
    mov ebx,eax
    mov edx,OFFSET msg
    call WriteString
    mov eax,ebx
    call WriteDec
    call Crlf
    ret
Report ENDP

; Validate_PIN: checks each digit against its own range
;   Receives: ESI = pointer to 5 bytes
;   Returns:  EAX = position (1..5) of the first bad digit, or 0 if valid
Validate_PIN PROC
    push ebx
    push ecx
    push edi
    mov edi,0                       ; digit index
    mov ecx,PIN_LEN
L1: mov al,[esi+edi]
    cmp al,minimum[edi]             ; below the minimum?
    jb  Bad
    cmp al,maximum[edi]             ; above the maximum?
    ja  Bad
    inc edi
    loop L1
    mov eax,0                       ; every digit is in range
    jmp Done
Bad:
    mov eax,edi
    inc eax                         ; positions are 1-based
Done:
    pop edi
    pop ecx
    pop ebx
    ret
Validate_PIN ENDP
END main
```

> **해설:**
> 경계를 평행한 두 배열에 저장하면 서로 다른 다섯 규칙이 하나의 루프가 된다. 같은 인덱스로 자릿수와 그 최소·최대를 함께 고른다. 자릿수는 부호 없는 값이므로 JB와 JA가 맞다. 위치를 인덱스+1로 반환하면 요구대로 1부터 시작하고, 첫 실패에서 바로 반환하는 것이 "즉시 반환"에 해당한다. 두 종료 경로 모두에서 모든 push에 정확히 하나의 pop이 대응해야 한다. 그러지 않으면 RET가 잘못된 주소로 점프한다.

---

### **Q10.** **Parity Checking** — Create a procedure that returns True in EAX if the bytes in an array contain even parity, or False if the parity is odd (in other words, count all the bits in the entire array and report whether the count is even or odd). Preserve all other registers. Write a test program that calls your procedure twice, each time passing a pointer to an array and its length, using one array with even parity and one with odd parity (at least 10 bytes each). Tip: repeatedly applying XOR to the byte values determines their parity, but be careful — some instructions affect the Parity flag and others do not.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
evenArray BYTE 1,2,3,4,5,6,7,8,9,10,1     ; 17 + 1 = 18 one-bits → even
oddArray  BYTE 1,2,3,4,5,6,7,8,9,10       ; 17 one-bits → odd
msg       BYTE "Even parity (1 = yes): ",0

.code
main PROC
    mov esi,OFFSET evenArray
    mov ecx,LENGTHOF evenArray
    call CheckParity
    call Report
    mov esi,OFFSET oddArray
    mov ecx,LENGTHOF oddArray
    call CheckParity
    call Report
    exit
main ENDP

Report PROC
    mov ebx,eax
    mov edx,OFFSET msg
    call WriteString
    mov eax,ebx
    call WriteDec
    call Crlf
    ret
Report ENDP

; CheckParity: reports whether the array has an even number of 1 bits
;   Receives: ESI = array pointer, ECX = length
;   Returns:  EAX = 1 (even parity) or 0 (odd parity)
CheckParity PROC
    push esi
    push ecx
    push ebx
    mov bl,0                        ; accumulator
L1: mov al,[esi]
    xor bl,al                       ; fold this byte into the accumulator
    inc esi                         ; INC does not affect the Parity flag,
    loop L1                         ; and neither does LOOP
    or  bl,bl                       ; set PF from the final accumulator
    jp  EvenParity                  ; PF = 1 → even number of 1 bits
    mov eax,0
    jmp Done
EvenParity:
    mov eax,1
Done:
    pop ebx
    pop ecx
    pop esi
    ret
CheckParity ENDP
END main
```

> **해설:**
> XOR는 모든 바이트를 하나의 누산기로 접는데, 각 1 비트가 자기 열을 홀수 또는 짝수 번 반전시키므로 그 누산기의 패리티가 배열 전체의 패리티와 같다. Parity 플래그는 마지막 결과의 하위 바이트만 반영하므로 루프가 끝난 뒤에 플래그를 만들어야 한다. OR BL,BL은 값을 바꾸지 않고 플래그를 설정한다. INC와 LOOP를 고른 것은 의도적이다. 이 명령들은 PF를 건드리지 않지만, 루프 안의 ADD나 SUB는 PF를 덮어쓴다.

---
