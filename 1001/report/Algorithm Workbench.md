# Algorithm Workbench

### **Q1.** Write a sequence of MOV instructions that will exchange the upper and lower words in a doubleword variable named three.

**정답:**
```asm
mov ax,WORD PTR three        ; low word
mov dx,WORD PTR three+2      ; high word
mov WORD PTR three,dx
mov WORD PTR three+2,ax
```

> **해설:**
> 리틀 엔디언 저장 방식 때문에 하위 워드는 오프셋 0, 상위 워드는 오프셋 2에 있다. WORD PTR로 각 절반을 두 레지스터를 거쳐 따로 읽고 쓴다.

---

### **Q2.** Using the XCHG instruction no more than three times, reorder the values in four 8-bit registers from the order A,B,C,D to B,C,D,A.

**정답:**
```asm
; AL=A, BL=B, CL=C, DL=D
xchg al,bl      ; AL=B, BL=A
xchg bl,cl      ; BL=C, CL=A
xchg cl,dl      ; CL=D, DL=A
; result: AL=B, BL=C, CL=D, DL=A
```

> **해설:**
> XCHG를 할 때마다 값 A가 한 레지스터씩 오른쪽으로 밀리고 다음 값이 제자리로 오므로, 세 번 교환하면 네 값이 회전한다.

---

### **Q3.** Transmitted messages often include a parity bit whose value is combined with a data byte to produce an even number of 1 bits. Suppose a message byte in the AL register contains 01110101. Show how you could use the Parity flag combined with an arithmetic instruction to determine if this message byte has even or odd parity.

**정답:**
```asm
mov al,01110101b
add al,0          ; (or: or al,0) sets PF according to AL
jp  evenParity    ; PF=1 → even number of 1 bits
; otherwise odd parity (01110101 has five 1 bits → PF = 0)
```

> **해설:**
> 산술/논리 명령은 결과 하위 바이트의 1 비트 수가 짝수일 때 PF = 1로 설정한다. 0을 더하면 AL은 그대로지만 플래그가 갱신되므로 JP/JNP로 패리티에 따라 분기할 수 있다.

---

### **Q4.** Write code using byte operands that adds two negative integers and causes the Overflow flag to be set.

**정답:**
```asm
mov al,-128     ; 80h
add al,-1       ; -129 does not fit → AL = 7Fh (+127), OF = 1
```

> **해설:**
> 실제 합이 −128보다 작은 두 음수를 더하면 부호 있는 바이트 범위를 벗어난다: 비트 패턴이 양수로 순환하고 OF가 설정된다.

---

### **Q5.** Write a sequence of two instructions that use addition to set the Zero and Carry flags at the same time.

**정답:**
```asm
mov al,0FFh
add al,1        ; AL = 00h (ZF=1), carry out of bit 7 (CF=1)
```

> **해설:**
> FFh + 1 = 100h: 결과 바이트가 0이고(ZF = 1) MSB에서 나간 올림이 CF를 설정한다.

---

### **Q6.** Write a sequence of two instructions that set the Carry flag using subtraction.

**정답:**
```asm
mov al,1
sub al,2        ; borrow required → CF = 1 (AL = FFh)
```

> **해설:**
> 작은 부호 없는 값에서 큰 값을 빼면 빌림이 필요하고, CPU는 이를 Carry 플래그 설정으로 알린다.

---

### **Q7.** Implement the following arithmetic expression in assembly language: EAX = –val2 + 7 – val3 + val1. Assume that val1, val2, and val3 are 32-bit integer variables.

**정답:**
```asm
mov eax,val2
neg eax          ; -val2
add eax,7        ; -val2 + 7
sub eax,val3     ; -val2 + 7 - val3
add eax,val1     ; -val2 + 7 - val3 + val1
```

> **해설:**
> 왼쪽부터 차례로 계산하며 중간 결과를 EAX에 유지한다. NEG로 −val2를 만든 뒤 ADD/SUB로 나머지 항을 적용한다.

---

### **Q8.** Write a loop that iterates through a doubleword array and calculates the sum of its elements using a scale factor with indexed addressing.

**정답:**
```asm
.data
intArray DWORD 10,20,30,40,50
.code
    mov esi,0                    ; element index
    mov eax,0                    ; sum
    mov ecx,LENGTHOF intArray
L1: add eax,intArray[esi*4]      ; scale factor 4 = TYPE DWORD
    inc esi
    loop L1
```

> **해설:**
> 스케일 팩터를 쓰면 인덱스 레지스터가 바이트가 아니라 원소를 센다: intArray[esi*4]는 esi번째 원소다. INC ESI로 다음 원소로 가고 LOOP가 ECX번 반복한다.

---

### **Q9.** Implement the following expression in assembly language: AX = (val2 + BX) – val4. Assume that val2 and val4 are 16-bit integer variables.

**정답:**
```asm
mov ax,val2
add ax,bx
sub ax,val4
```

> **해설:**
> 모든 피연산자가 16비트이므로 AX, BX와 WORD 변수를 ADD, SUB로 바로 결합할 수 있다.

---

### **Q10.** Write a sequence of two instructions that set both the Carry and Overflow flags at the same time.

**정답:**
```asm
mov al,80h
add al,80h      ; 80h+80h = 100h → CF=1; -128 + -128 = -256 → OF=1 (AL = 00h)
```

> **해설:**
> 부호 없이 보면 128 + 128 = 256이 바이트를 넘고(CF = 1), 부호 있게 보면 −128 + −128 = −256도 넘친다(OF = 1). 두 플래그는 같은 덧셈을 두 관점에서 설명한다.

---

### **Q11.** Write a sequence of instructions showing how the Zero flag could be used to indicate unsigned overflow after executing INC and DEC instructions.

**정답:**
```asm
mov al,0FFh
inc al           ; FFh + 1 wraps to 00h → ZF = 1 signals unsigned overflow
jz  incOverflow

mov al,0
dec al           ; 00h - 1 wraps to FFh: ZF = 0, and CF is NOT changed by DEC
; so test the operand for zero BEFORE decrementing:
mov al,0
cmp al,0         ; ZF = 1 → the DEC that follows would underflow
jz  decOverflow
dec al
```

> **해설:**
> INC와 DEC는 Carry 플래그를 바꾸지 않으므로 평소의 부호 없는 오버플로 지표를 쓸 수 없다. INC 후 결과가 0이면 최댓값에서 0으로 순환한 것이다. DEC는 0에서 최댓값으로 순환하므로 감소하기 전에 0인지(ZF) 확인한다.

---

### **Q12.** Use the following data definitions for Questions 12–18:

```asm
.data
myBytes BYTE 10h,20h,30h,40h
myWords WORD 3 DUP(?),2000h
myString BYTE "ABCDE"
```

Insert a directive in the given data that aligns myBytes to an even-numbered address.

**정답:**
```asm
.data
ALIGN 2
myBytes BYTE 10h,20h,30h,40h
```

> **해설:**
> ALIGN 2는 필요하면 사용하지 않는 바이트로 채워서 다음 데이터 항목이 짝수 주소에서 시작하게 한다.

---

### **Q13.** (Using the definitions from Question 12) What will be the value of EAX after each of the following instructions execute?

```asm
mov eax,TYPE myBytes      ; a.
mov eax,LENGTHOF myBytes  ; b.
mov eax,SIZEOF myBytes    ; c.
mov eax,TYPE myWords      ; d.
mov eax,LENGTHOF myWords  ; e.
mov eax,SIZEOF myWords    ; f.
mov eax,SIZEOF myString   ; g.
```

**정답:**
a. 1
b. 4
c. 4
d. 2
e. 4
f. 8
g. 5

> **해설:**
> TYPE은 원소 크기(BYTE 1, WORD 2). LENGTHOF는 원소 수: myBytes는 4, myWords는 3(DUP) + 1 = 4. SIZEOF = TYPE × LENGTHOF: 4, 8. myString은 5글자 → SIZEOF 5.

---

### **Q14.** (Using the definitions from Question 12) Write a single instruction that moves the first two bytes in myBytes to the DX register. The resulting value will be 2010h.

**정답:**
mov dx,WORD PTR myBytes

> **해설:**
> WORD PTR가 BYTE 타입을 덮어써서 두 바이트를 한 워드로 읽는다. 리틀 엔디언이므로 10h가 하위 바이트, 20h가 상위 바이트: 2010h.

---

### **Q15.** (Using the definitions from Question 12) Write an instruction that moves the second byte in myWords to the AL register.

**정답:**
mov al,BYTE PTR [myWords+1]

> **해설:**
> BYTE PTR로 WORD 배열을 바이트 단위로 접근할 수 있고, +1이 두 번째 바이트를 고른다.

---

### **Q16.** (Using the definitions from Question 12) Write an instruction that moves all four bytes in myBytes to the EAX register.

**정답:**
mov eax,DWORD PTR myBytes

> **해설:**
> DWORD PTR는 연속된 네 바이트를 하나의 더블워드로 읽는다(리틀 엔디언이므로 EAX = 40302010h).

---

### **Q17.** (Using the definitions from Question 12) Insert a LABEL directive in the given data that permits myWords to be moved directly to a 32-bit register.

**정답:**
```asm
.data
myBytes BYTE 10h,20h,30h,40h
myWordsD LABEL DWORD          ; alias, no storage
myWords WORD 3 DUP(?),2000h
myString BYTE "ABCDE"
.code
mov eax,myWordsD              ; loads the first 4 bytes of myWords
```

> **해설:**
> LABEL은 메모리를 할당하지 않고 같은 주소에 다른 타입의 두 번째 이름을 붙여 주므로 WORD 배열을 DWORD로 볼 수 있다.

---

### **Q18.** (Using the definitions from Question 12) Insert a LABEL directive in the given data that permits myBytes to be moved directly to a 16-bit register.

**정답:**
```asm
.data
myBytesW LABEL WORD
myBytes BYTE 10h,20h,30h,40h
.code
mov ax,myBytesW               ; AX = 2010h
```

> **해설:**
> myBytes 바로 앞에 둔 WORD 별칭은 같은 주소를 가지므로 16비트 이동으로 처음 두 바이트를 읽는다.

---
