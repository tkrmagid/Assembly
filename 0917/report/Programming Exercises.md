# Programming Exercises

### **Q1.** **Integer Expression Calculation** — Using the AddTwo program from Section 3.2 as a reference, write a program that calculates the following expression, using registers: A = (A + B) − (C + D). Assign integer values to the EAX, EBX, ECX, and EDX registers.

**정답:**
```asm
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.code
main PROC
    mov eax,20          ; A
    mov ebx,10          ; B
    mov ecx,3           ; C
    mov edx,2           ; D

    add eax,ebx         ; EAX = A + B      = 30
    add ecx,edx         ; ECX = C + D      = 5
    sub eax,ecx         ; EAX = 30 - 5     = 25

    INVOKE ExitProcess,0
main ENDP
END main
```

> **해설:**
> 괄호 안의 두 합을 각각 별도 레지스터에 먼저 계산한 뒤 뺀다. 최종 결과는 EAX(변수 A)에 남는다. 콘솔 출력이 없으므로 디버거로 EAX 값을 확인하면 된다.

---

### **Q2.** **Symbolic Integer Constants** — Write a program that defines symbolic constants for all seven days of the week. Create an array variable that uses the symbols as initializers.

**정답:**
```asm
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

SUNDAY    = 1           ; = directive (redefinable)
MONDAY    = 2
TUESDAY   = 3
WEDNESDAY = 4
THURSDAY  = 5
FRIDAY    = 6
SATURDAY  = 7           ; EQU also works: SATURDAY EQU 7

.data
week DWORD SUNDAY, MONDAY, TUESDAY, WEDNESDAY,
           THURSDAY, FRIDAY, SATURDAY

.code
main PROC
    mov eax,week            ; 1
    mov ebx,week+4*6        ; 7
    INVOKE ExitProcess,0
main ENDP
END main
```

> **해설:**
> 기호 상수는 =나 EQU로 만들며 어셈블러가 처리하므로 메모리를 차지하지 않는다. 배열 초기값으로 쓰면 각 원소의 의미가 드러난다. 데이터 줄을 이어 쓸 때는 끝에 쉼표만 있으면 된다.

---

### **Q3.** **Data Definitions** — Write a program that contains a definition of each data type listed in Table 3-2 in Section 3.4. Initialize each variable to a value that is consistent with its data type.

**정답:**
```asm
.data
val1  BYTE   255                    ; 8-bit unsigned   (0 .. 255)
val2  SBYTE  -128                   ; 8-bit signed     (-128 .. +127)
val3  WORD   65535                  ; 16-bit unsigned
val4  SWORD  -32768                 ; 16-bit signed
val5  DWORD  4294967295             ; 32-bit unsigned
val6  SDWORD -2147483648            ; 32-bit signed
val7  FWORD  0                      ; 48-bit far pointer
val8  QWORD  1234567890123456789    ; 64-bit
val9  TBYTE  1000000000000000000h   ; 80-bit (packed BCD)
val10 REAL4  -1.5                   ; IEEE single precision
val11 REAL8  3.141592653589793      ; IEEE double precision
val12 REAL10 1.0E+400               ; IEEE extended precision

; DB/DW/DD/DQ/DT are the older equivalents of BYTE/WORD/DWORD/QWORD/TBYTE
```

> **해설:**
> 각 초기값은 선언한 크기와 부호 유무에 맞아야 한다. 255는 BYTE에는 되지만 SBYTE에는 안 되고, −128은 SBYTE에는 되지만 BYTE에는 안 된다. 값이 맞지 않으면 어셈블러가 "initializer magnitude too large" 오류를 낸다.

---

### **Q4.** **Symbolic Text Constants** — Write a program that defines symbolic names for several string literals (characters between quotes). Use each symbolic name in a variable definition.

**정답:**
```asm
PROMPT_NAME TEXTEQU <"Enter your name: ">
PROMPT_AGE  TEXTEQU <"Enter your age: ">
GREETING    TEXTEQU <"Hello, and welcome!">
COUNT       TEXTEQU %10                 ; % evaluates a constant expression

.data
msg1 BYTE PROMPT_NAME,0
msg2 BYTE PROMPT_AGE,0
msg3 BYTE GREETING,0dh,0ah,0
list BYTE COUNT DUP(0)

; EQU with angle brackets does the same thing:
;   PROMPT_NAME EQU <"Enter your name: ">
```

> **해설:**
> TEXTEQU(또는 `< >`를 쓴 EQU)는 텍스트 매크로를 정의한다. 이름이 나오는 곳마다 어셈블러가 텍스트를 치환하므로 한 번만 고치면 모든 사용처가 바뀐다. =와 달리 숫자가 아닌 문자를 담는다.

---

### **Q5.** **Listing File for AddTwoSum** — Generate a listing file for the AddTwoSum program and write a description of the machine code bytes generated for each instruction. You might have to guess at some of the meanings of the byte values.

**정답:**
```asm
; How to generate the listing: Project Properties > Microsoft Macro Assembler >
; Listing File > Assembled Code Listing File = $(ProjectName).lst
; (command line: ml /c /Fl /Sc AddTwoSum.asm)

; Excerpt of AddTwoSum.lst  —  offset, machine code, source
00000000                  .code
00000000                  main PROC
00000000  A1 00000000 R       mov  eax,val1    ; A1 = MOV EAX,moffs32 (direct, EAX only)
                                               ;      4-byte address of val1, filled in by the linker (R)
00000005  03 05 00000004 R    add  eax,val2    ; 03 = ADD r32,r/m32
                                               ;      05 = ModRM: mod 00, reg 000 (EAX), r/m 101 (direct)
0000000B  A3 00000008 R       mov  finalSum,eax; A3 = MOV moffs32,EAX
00000010  6A 00               push 0           ; 6A = PUSH imm8
00000012  E8 00000000 E       call ExitProcess ; E8 = CALL rel32 (E = external fixup)
00000017                  main ENDP
                          END main
```

> **해설:**
> 리스팅 파일은 각 명령의 오프셋, 기계어, 원본 줄을 함께 보여 주므로 MASM이 코드를 어떻게 인코딩하는지 확인하기에 가장 좋다. 설명할 만한 점: EAX와 직접 주소를 쓰는 MOV는 ModRM 없이 전용 축약 opcode(A1 / A3)를 쓰고, 다른 형태는 ModRM 바이트가 필요하며, 주소와 CALL 목적지는 링커가 채울 재배치 항목(R, E 표시)으로 남는다. 이 인코딩은 12장에서 자세히 다룬다.

---

### **Q6.** **AddVariables Program** — Modify the AddVariables program so it uses 64-bit variables. Describe the syntax errors generated by the assembler and what steps you took to resolve the errors.

**정답:**
```asm
; 64-bit version — must be built with ML64 (x64 project), not ML
ExitProcess PROTO

.data
val1     QWORD 10000000000        ; was DWORD
val2     QWORD 20000000000
val3     QWORD 30000000000
finalVal QWORD ?

.code
main PROC
    mov rax,val1                  ; 64-bit register with a QWORD operand
    add rax,val2
    add rax,val3
    mov finalVal,rax
    mov ecx,0
    call ExitProcess
main ENDP
END
```

> **해설:**
> 변수만 QWORD로 바꾸고 "mov eax,val1"을 그대로 두면 EAX는 32비트인데 변수는 64비트가 되어 A2022 "instruction operands must be the same size" 오류가 난다. 해결책은 64비트 레지스터(RAX)를 쓰는 것이다. 추가로 두 가지가 더 필요하다: x64 프로젝트에서 ML64로 어셈블해야 하고, 64비트 MASM에는 .386/.model/.stack 지시어와 INVOKE가 없으므로 파일을 END로만 끝내고 ExitProcess는 x64 호출 규약에 따라 인수를 ECX에 넣어 직접 호출한다.

---
