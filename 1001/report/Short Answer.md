# Short Answer

### **Q1.** What will be the value in EDX after each of the lines marked (a) and (b) execute?

```asm
.data
one WORD 8002h
two WORD 4321h
.code
mov edx,21348041h
movsx edx,one     ; (a)
movsx edx,two     ; (b)
```

**정답:**
a. FFFF8002h
b. 00004321h

> **해설:**
> MOVSX는 16비트 소스의 부호 비트를 상위 16비트에 복사한다. 8002h는 MSB가 1이므로 EDX = FFFF8002h, 4321h는 MSB가 0이므로 EDX = 00004321h. 이전 EDX 내용은 완전히 대체된다.

---

### **Q2.** What will be the value in EAX after the following lines execute?

```asm
mov eax,1002FFFFh
inc ax
```

**정답:**
10020000h

> **해설:**
> INC AX는 하위 16비트만 바꾼다: FFFFh + 1은 0000h로 순환하고 상위 절반 1002h는 그대로다.

---

### **Q3.** What will be the value in EAX after the following lines execute?

```asm
mov eax,30020000h
dec ax
```

**정답:**
3002FFFFh

> **해설:**
> DEC AX: 0000h − 1은 FFFFh로 순환하고 상위 16비트는 3002h 그대로다.

---

### **Q4.** What will be the value in EAX after the following lines execute?

```asm
mov eax,1002FFFFh
neg ax
```

**정답:**
10020001h

> **해설:**
> NEG는 AX의 2의 보수를 취한다: FFFFh는 −1이고 −(−1) = +1 = 0001h. 상위 절반은 그대로다.

---

### **Q5.** What will be the value of the Parity flag after the following lines execute?

```asm
mov al,1
add al,3
```

**정답:**
PF = 0

> **해설:**
> 1 + 3 = 4 = 00000100b이며 1 비트가 하나(홀수)이므로 Parity 플래그는 0이다. PF는 하위 바이트의 1 비트 수가 짝수일 때만 1이다.

---

### **Q6.** What will be the value of EAX and the Sign flag after the following lines execute?

```asm
mov eax,5
sub eax,6
```

**정답:**
EAX. FFFFFFFFh
SF. 1

> **해설:**
> 5 − 6 = −1이며 FFFFFFFFh로 저장된다. 결과의 MSB가 1이므로 Sign 플래그가 설정된다(빌림 때문에 CF도 설정된다).

---

### **Q7.** In the following code, the value in AL is intended to be a signed byte. Explain how the Overflow flag helps, or does not help you, to determine whether the final value in AL falls within a valid signed range.

```asm
mov al,-1
add al,130
```

**정답:**
It does not help: 130 is already out of the signed byte range, so it is encoded as 82h (−126). The CPU computes −1 + (−126) = −127 = 81h without signed overflow, so OF = 0 even though the intended result 129 is invalid

> **해설:**
> Overflow 플래그는 실제로 더해진 비트 패턴만 반영한다. 130은 부호 있는 바이트에 들어가지 않아 어셈블러가 82h로 저장하고, FFh + 82h = 181h → AL = 81h, CF = 1이지만 OF = 0이다(음수 + 음수가 음수로 유지). 따라서 플래그로는 의도한 값이 범위를 벗어났는지 알 수 없다.

---

### **Q8.** What value will RAX contain after the following instruction executes?

```asm
mov rax,44445555h
```

**정답:**
0000000044445555h

> **해설:**
> 32비트 즉시값을 64비트 레지스터로 옮기면 0 확장된다: 상위 32비트가 0이 된다.

---

### **Q9.** What value will RAX contain after the following instructions execute?

```asm
.data
dwordVal DWORD 84326732h
.code
mov rax,0FFFFFFFF00000000h
mov rax,dwordVal
```

**정답:**
The assembler reports an error: the 32-bit memory operand does not match the 64-bit register (if it were mov eax,dwordVal, RAX would be 0000000084326732h)

> **해설:**
> MOV는 두 피연산자의 크기가 같아야 하므로 DWORD 변수를 RAX로 직접 옮길 수 없다. 합법적인 형태(mov eax,dwordVal)에 대한 교재의 규칙은 32비트 메모리 피연산자를 EAX로 읽으면 RAX의 32–63비트가 0이 된다는 것이며, 그러면 0000000084326732h가 된다.

---

### **Q10.** What value will EAX contain after the following instructions execute?

```asm
.data
dVal DWORD 12345678h
.code
mov ax,3
mov WORD PTR dVal+2,ax
mov eax,dVal
```

**정답:**
00035678h

> **해설:**
> dVal은 리틀 엔디언으로 78 56 34 12로 저장된다. WORD PTR dVal+2는 상위 워드(1234h)이며 0003h로 덮어써진다. 더블워드를 다시 읽으면 00035678h다.

---

### **Q11.** What will EAX contain after the following instructions execute?

```asm
.data
dVal DWORD ?
.code
mov dVal,12345678h
mov ax,WORD PTR dVal+2
add ax,3
mov WORD PTR dVal,ax
mov eax,dVal
```

**정답:**
12341237h

> **해설:**
> WORD PTR dVal+2는 상위 워드 1234h이며 3을 더하면 1237h가 되고, 이 값이 dVal의 하위 워드에 저장된다. dVal은 12341237h가 된다.

---

### **Q12.** (Yes/No): Is it possible to set the Overflow flag if you add a positive integer to a negative integer?

**정답:**
No

> **해설:**
> 아니오. 양수와 음수의 합은 절댓값이 항상 더 큰 피연산자보다 작으므로 항상 들어간다. 부호 오버플로는 같은 부호의 두 피연산자가 필요하다.

---

### **Q13.** (Yes/No): Will the Overflow flag be set if you add a negative integer to a negative integer and produce a positive result?

**정답:**
Yes

> **해설:**
> 예. 음수 + 음수는 음수여야 한다. 양수가 나왔다면 실제 합이 표현 가능한 최솟값보다 작았다는 뜻이며 이것이 곧 부호 오버플로다(예: −128 + −1 → +127, OF = 1).

---

### **Q14.** (Yes/No): Is it possible for the NEG instruction to set the Overflow flag?

**정답:**
Yes

> **해설:**
> 예. 가장 작은 음수(바이트에서 −128, 80h)의 부호를 바꾸면 +128이 되어야 하는데 표현할 수 없으므로 결과는 80h 그대로이고 OF가 설정된다.

---

### **Q15.** (Yes/No): Is it possible for both the Sign and Zero flags to be set at the same time?

**정답:**
No

> **해설:**
> 아니오. Zero는 결과가 0일 때만 설정되고, 0의 최상위 비트는 0이므로 Sign은 0이다.

---

### **Q16.** Use the following variable definitions for Questions 16–19:

```asm
.data
var1 SBYTE -4,-2,3,1
var2 WORD 1000h,2000h,3000h,4000h
var3 SWORD -16,-42
var4 DWORD 1,2,3,4,5
```

For each of the following statements, state whether or not the instruction is valid:

**정답:**
a. `mov ax,var1` → invalid
b. `mov ax,var2` → valid
c. `mov eax,var3` → invalid
d. `mov var2,var3` → invalid
e. `movzx ax,var2` → invalid
f. `movzx var2,al` → invalid
g. `mov ds,ax` → valid
h. `mov ds,1000h` → invalid

> **해설:**
> a. 크기 불일치(바이트 → 16비트 레지스터). b. 워드 → AX, 크기 일치. c. 16비트 SWORD → 32비트 EAX 불일치. d. 메모리→메모리는 항상 불가. e. MOVZX는 소스가 목적지보다 작아야 하는데 워드 → AX는 같은 크기. f. MOVZX의 목적지는 레지스터여야 함. g. 16비트 레지스터를 세그먼트 레지스터로 옮기는 것은 문법상 허용(보호 모드 프로그램에서는 쓰지 않지만). h. 즉시값은 세그먼트 레지스터로 옮길 수 없다.

---

### **Q17.** (Using the definitions from Question 16) What will be the hexadecimal value of the destination operand after each of the following instructions execute in sequence?

```asm
mov al,var1        ; a.
mov ah,[var1+3]    ; b.
```

**정답:**
a. FCh
b. 01h

> **해설:**
> var1의 첫 원소는 −4 = FCh(바이트). [var1+3]은 네 번째 원소인 1 = 01h.

---

### **Q18.** (Using the definitions from Question 16) What will be the value of the destination operand after each of the following instructions execute in sequence?

```asm
mov ax,var2        ; a.
mov ax,[var2+4]    ; b.
mov ax,var3        ; c.
mov ax,[var3-2]    ; d.
```

**정답:**
a. 1000h
b. 3000h
c. FFF0h (−16)
d. 4000h

> **해설:**
> a. var2의 첫 워드. b. +4바이트 = 세 번째 워드(3000h). c. −16의 16비트 2의 보수 = FFF0h. d. var3 앞 2바이트는 var2의 마지막 워드 4000h.

---

### **Q19.** (Using the definitions from Question 16) What will be the value of the destination operand after each of the following instructions execute in sequence?

```asm
mov edx,var4       ; a.
movzx edx,var2     ; b.
mov edx,[var4+4]   ; c.
movsx edx,var1     ; d.
```

**정답:**
a. 00000001h
b. 00001000h
c. 00000002h
d. FFFFFFFCh (−4)

> **해설:**
> a. var4의 첫 더블워드 = 1. b. 1000h를 32비트로 0 확장. c. +4바이트 = 두 번째 원소 = 2. d. −4(FCh)를 32비트로 부호 확장 = FFFFFFFCh.

---
