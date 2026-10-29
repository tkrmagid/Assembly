# Short Answer

### **Q1.** In the following code sequence, show the value of AL after each shift or rotate instruction has executed:

```asm
mov al,0D4h
shr al,1     ; a.
mov al,0D4h
sar al,1     ; b.
mov al,0D4h
sar al,4     ; c.
mov al,0D4h
rol al,1     ; d.
```

**정답:**
a. 6Ah
b. EAh
c. FDh
d. A9h

> **해설:**
> D4h = 1101 0100. a. SHR은 0으로 채움: 0110 1010 = 6Ah. b. SAR은 부호 비트 복사: 1110 1010 = EAh. c. SAR 4는 1을 네 개 복사: 1111 1101 = FDh. d. ROL은 MSB를 bit 0으로: 1010 1001 = A9h.

---

### **Q2.** In the following code sequence, show the value of AL after each shift or rotate instruction has executed:

```asm
mov al,0D4h
ror al,3     ; a.
mov al,0D4h
rol al,7     ; b.
stc
mov al,0D4h
rcl al,1     ; c.
stc
mov al,0D4h
rcr al,3     ; d.
```

**정답:**
a. 9Ah
b. 6Ah
c. A9h
d. 3Ah

> **해설:**
> D4h = 1101 0100. a. ROR 3은 하위 세 비트(100)를 맨 위로: 1001 1010 = 9Ah. b. 바이트에서 ROL 7은 ROR 1과 같다: 0110 1010 = 6Ah. c. CF = 1인 RCL 1은 왼쪽으로 밀며 캐리를 bit 0으로 넣는다: 1010 1001 = A9h(CF = 1). d. CF = 1인 RCR 3은 9비트 회전: 1·11010100 → 0·11101010 → 0·01110101 → 1·00111010, 따라서 AL = 3Ah(CF = 1).

---

### **Q3.** What will be the contents of AX and DX after the following operation?

```asm
mov dx,0
mov ax,222h
mov cx,100h
mul cx
```

**정답:**
AX = 2200h, DX = 0002h

> **해설:**
> 16비트 MUL은 32비트 곱을 DX:AX에 넣는다. 222h × 100h = 22200h이므로 DX(상위 워드) = 0002h, AX(하위 워드) = 2200h.

---

### **Q4.** What will be the contents of AX after the following operation?

```asm
mov ax,63h
mov bl,10h
div bl
```

**정답:**
AX = 0306h (AH = 03h remainder, AL = 06h quotient)

> **해설:**
> 8비트 DIV는 AX를 BL로 나눈다: 63h(99) ÷ 10h(16) = 몫 6, 나머지 3. 몫은 AL(06h), 나머지는 AH(03h): AX = 0306h.

---

### **Q5.** What will be the contents of EAX and EDX after the following operation?

```asm
mov eax,123400h
mov edx,0
mov ebx,10h
div ebx
```

**정답:**
EAX = 00012340h, EDX = 0

> **해설:**
> 32비트 DIV는 EDX:EAX를 EBX로 나눈다. 123400h ÷ 10h = 12340h, 나머지 0: EAX = 00012340h(몫), EDX = 0(나머지).

---

### **Q6.** What will be the contents of AX and DX after the following operation?

```asm
mov ax,4000h
mov dx,500h
mov bx,10h
div bx
```

**정답:**
A divide overflow exception occurs (the program halts): the quotient 500400h does not fit in AX

> **해설:**
> 피제수는 DX:AX = 05004000h. 10h로 나누면 500400h이고 FFFFh보다 크므로 몫이 AX에 들어가지 않는다. DX(500h) ≥ 제수(10h)이므로 CPU는 결과를 내는 대신 나눗셈 오버플로 예외를 발생시킨다.

---

### **Q7.** What will be the contents of BX after the following instructions execute?

```asm
mov bx,5
stc
mov ax,60h
adc bx,ax
```

**정답:**
0066h

> **해설:**
> STC가 Carry 플래그를 설정하고 MOV는 이를 바꾸지 않는다. ADC는 소스와 캐리를 더한다: 5 + 60h + 1 = 66h.

---

### **Q8.** Describe the output when the following code executes in 64-bit mode:

```asm
.data
dividend_hi QWORD 00000108h
dividend_lo QWORD 33300020h
divisor QWORD 00000100h
.code
mov rdx,dividend_hi
mov rax,dividend_lo
div divisor
```

**정답:**
A divide overflow exception: RDX (108h) is not smaller than the divisor (100h), so the quotient would need more than 64 bits

> **해설:**
> 128비트 피제수 RDX:RAX = 108h × 2^64 + 33300020h. 100h로 나누면 108h × 2^56 + …가 되어 RAX에 들어가지 않는다. 피제수의 상위 부분이 제수 이상이면 DIV는 나눗셈 오버플로 예외를 발생시키고 프로그램이 멈춘다.

---

### **Q9.** The following program is supposed to subtract val2 from val1. Find and correct all logic errors (CLC clears the Carry flag):

```asm
.data
val1 QWORD 20403004362047A1h
val2 QWORD 055210304A2630B2h
result QWORD 0
.code
mov cx,8              ; loop counter
mov esi,val1          ; set index to start
mov edi,val2
clc                   ; clear Carry flag
top:
mov al,BYTE PTR[esi]  ; get first number
sbb al,BYTE PTR[edi]  ; subtract second
mov BYTE PTR[esi],al  ; store the result
dec esi
dec edi
loop top
```

**정답:**
```asm
mov ecx,8               ; use the full ECX (LOOP uses ECX in 32-bit mode)
mov esi,OFFSET val1     ; OFFSET, not the value
mov edi,OFFSET val2
mov ebx,OFFSET result   ; store into result, not into val1
clc
top:
mov al,BYTE PTR [esi]
sbb al,BYTE PTR [edi]
mov BYTE PTR [ebx],al
inc esi                 ; move UP through memory: LSB is at the lowest address
inc edi
inc ebx
loop top
```

Errors: (1) `mov esi,val1`/`mov edi,val2` load the values instead of their addresses (and are size mismatches) — use OFFSET. (2) DEC moves toward lower addresses, but subtraction must start at the least significant byte, which is at the *lowest* address (little-endian) — use INC. (3) The result overwrites val1 instead of going to result. (4) Only CX is loaded while LOOP uses ECX. (INC/DEC do not alter CF, so the borrow chain is preserved.)

> **해설:**
> SBB를 이용한 확장 뺄셈은 빌림이 올바르게 전파되도록 최하위 단위부터 위로 진행해야 하며, 리틀 엔디언 머신에서는 가장 낮은 주소에서 높은 주소로 이동하는 것을 뜻한다. 포인터 레지스터는 주소(OFFSET)를 담아야 하고 결과는 별도 변수에 써야 한다.

---

### **Q10.** What will be the hexadecimal contents of RAX after the following instructions execute in 64-bit mode?

```asm
.data
multiplicand QWORD 0001020304050000h
.code
imul rax,multiplicand, 4
```

**정답:**
0004080C10140000h

> **해설:**
> 3 피연산자 IMUL은 RAX = multiplicand × 4를 계산한다. 4를 곱하는 것은 왼쪽 2비트 시프트: 0001020304050000h × 4 = 0004080C10140000h(각 바이트가 두 번 두 배: 01→04, 02→08, 03→0C, 04→10, 05→14).

---
