# Algorithm Workbench

### **Q1.** Write a single instruction that converts an ASCII digit in AL to its corresponding binary value. If AL already contains a binary value (00h to 09h), leave it unchanged.

**정답:**
and al,0Fh

> **해설:**
> ASCII 숫자는 30h–39h이며 AND 0Fh로 상위 니블을 지우면 0–9가 남는다. 이미 00h–09h인 값은 상위 니블이 0이므로 그대로다. (SUB 30h는 두 번째 조건을 어긴다.)

---

### **Q2.** Write instructions that calculate the parity of a 32-bit memory operand. Hint: Use the formula presented earlier in this section: B0 XOR B1 XOR B2 XOR B3.

**정답:**
```asm
.data
dwordVal DWORD 12345678h
.code
mov eax,dwordVal
mov ebx,eax
shr ebx,16          ; BL = B2, BH = B3
xor al,ah           ; B0 XOR B1
xor bl,bh           ; B2 XOR B3
xor al,bl           ; (B0^B1) ^ (B2^B3) → PF reflects parity of all 32 bits
jp  evenParity      ; PF = 1 → even
; otherwise odd parity
```

> **해설:**
> XOR는 1 비트 개수를 합친다: 더블워드 전체의 패리티는 B0 XOR B1 XOR B2 XOR B3의 패리티와 같다. 마지막 XOR가 그 한 바이트에 대해 PF를 설정하므로 JP/JNP로 분기할 수 있다.

---

### **Q3.** Given two bit-mapped sets named SetX and SetY, write a sequence of instructions that generate a bit string in EAX that represents members in SetX that are not members of SetY.

**정답:**
```asm
mov eax,SetY
not eax            ; complement of SetY
and eax,SetX       ; SetX AND (NOT SetY) = set difference
```

> **해설:**
> 차집합 X − Y는 X에 있고 Y에 없는 원소다: X의 비트와 Y 비트의 보수를 AND한다.

---

### **Q4.** Write instructions that jump to label L1 when the unsigned integer in DX is less than or equal to the integer in CX.

**정답:**
```asm
cmp dx,cx
jbe L1           ; jump if below or equal (unsigned)
```

> **해설:**
> 부호 없는 비교에는 "above/below" 계열을 쓴다: JBE는 CF = 1이거나 ZF = 1이면 점프한다.

---

### **Q5.** Write instructions that jump to label L2 when the signed integer in AX is greater than the integer in CX.

**정답:**
```asm
cmp ax,cx
jg L2            ; jump if greater (signed)
```

> **해설:**
> 부호 있는 비교에는 "greater/less" 계열을 쓴다: JG는 ZF = 0이고 SF = OF일 때 점프한다.

---

### **Q6.** Write instructions that first clear bits 0 and 1 in AL. Then, if the destination operand is equal to zero, the code should jump to label L3. Otherwise, it should jump to label L4.

**정답:**
```asm
and al,11111100b    ; clear bits 0 and 1 (sets ZF from the result)
jz  L3              ; result was zero
jmp L4              ; otherwise
```

> **해설:**
> 대상 위치가 0인 마스크와 AND하면 그 비트가 지워지고, AND는 결과에 따라 Zero 플래그를 설정하므로 별도의 CMP 없이 JZ로 바로 검사할 수 있다.

---

### **Q7.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that val1 and X are 32-bit variables.

```asm
if( val1 > ecx ) AND ( ecx > edx )
    X = 1
else
    X = 2;
```

**정답:**
```asm
    cmp val1,ecx
    jng ELSE_        ; val1 <= ecx → false
    cmp ecx,edx
    jng ELSE_        ; ecx <= edx → false
    mov X,1
    jmp DONE
ELSE_:
    mov X,2
DONE:
```

> **해설:**
> AND에서는 한 조건이 거짓이면 전체가 거짓이므로, 각 검사가 실패하면 바로 else로 점프하고 두 번째 비교는 건너뛴다.

---

### **Q8.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.

```asm
if( ebx > ecx ) OR ( ebx > val1 )
    X = 1
else
    X = 2
```

**정답:**
```asm
    cmp ebx,ecx
    jg  THEN_        ; first condition true → done testing
    cmp ebx,val1
    jng ELSE_        ; both false
THEN_:
    mov X,1
    jmp DONE
ELSE_:
    mov X,2
DONE:
```

> **해설:**
> OR에서는 첫 참 조건이 전체를 참으로 만들므로 바로 then으로 점프하고, 첫 조건이 실패했을 때만 두 번째 조건을 검사한다.

---

### **Q9.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.

```asm
if( ebx > ecx AND ebx > edx ) OR ( edx > eax )
    X = 1
else
    X = 2
```

**정답:**
```asm
    cmp ebx,ecx
    jng L1           ; AND part fails → test the OR alternative
    cmp ebx,edx
    jg  THEN_        ; both AND conditions true
L1: cmp edx,eax
    jng ELSE_        ; alternative also false
THEN_:
    mov X,1
    jmp DONE
ELSE_:
    mov X,2
DONE:
```

> **해설:**
> AND 묶음을 먼저 평가한다: 어느 검사든 실패하면 OR의 대안(edx > eax)으로 넘어간다. AND 묶음이 성공하면 대안을 검사하지 않고 바로 then으로 점프한다.

---

### **Q10.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that A, B, and N are 32-bit signed integers.

```asm
while N > 0
    if N != 3 AND (N < A OR N > B)
        N = N - 2
    else
        N = N - 1
end while
```

**정답:**
```asm
WHILE_:
    cmp N,0
    jle DONE          ; exit while N <= 0
    cmp N,3
    je  ELSE_         ; N == 3 → condition false
    mov eax,N
    cmp eax,A
    jl  THEN_         ; N < A → true
    cmp eax,B
    jng ELSE_         ; N <= B → false
THEN_:
    sub N,2
    jmp WHILE_
ELSE_:
    dec N
    jmp WHILE_
DONE:
```

> **해설:**
> 루프 검사는 맨 위에 있다(N > 0은 부호 있는 JLE로 탈출). 안에서는 먼저 N != 3이어야 하고, OR 묶음은 N < A면 참, 아니면 N > B를 검사한다. 두 분기 모두 루프 검사로 되돌아간다.

---
