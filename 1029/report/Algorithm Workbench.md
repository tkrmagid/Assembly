# Algorithm Workbench

### **Q1.** Write a sequence of shift instructions that cause AX to be sign-extended into EAX. In other words, the sign bit of AX is copied into the upper 16 bits of EAX. Do not use the CWD instruction.

**정답:**
```asm
shl eax,16      ; move AX into the upper half of EAX
sar eax,16      ; arithmetic shift back: the sign bit fills bits 16-31
```

> **해설:**
> SHL 후 원래 AX가 16–31비트에 놓이고 부호 비트는 bit 31에 온다. SAR은 bit 31을 빈 상위 비트에 복제하며 다시 내려보내므로 정확히 부호 확장이 된다.

---

### **Q2.** Suppose the instruction set contained no rotate instructions. Show how you would use SHR and a conditional jump instruction to rotate the contents of the AL register 1 bit to the right.

**정답:**
```asm
shr al,1          ; bit 0 goes into the Carry flag
jnc L1            ; if it was 0, nothing more to do
or  al,80h        ; it was 1: set bit 7
L1:
```

> **해설:**
> SHR은 하위 비트를 CF로 밀어내고 bit 7을 0으로 만든다. 회전이었다면 그 비트가 bit 7로 갔을 것이므로, CF = 1일 때 bit 7을 직접 설정한다.

---

### **Q3.** Write a logical shift instruction that multiplies the contents of EAX by 16.

**정답:**
shl eax,4

> **해설:**
> 16 = 2^4이며 왼쪽으로 n비트 시프트는 2^n을 곱한다.

---

### **Q4.** Write a logical shift instruction that divides EBX by 4.

**정답:**
shr ebx,2

> **해설:**
> 4 = 2^2; 오른쪽 논리 시프트 2는 부호 없는 값을 4로 나눈다(부호 있는 값에는 SAR을 쓴다).

---

### **Q5.** Write a single rotate instruction that exchanges the high and low halves of the DL register.

**정답:**
ror dl,4 (or rol dl,4)

> **해설:**
> DL은 8비트이므로 어느 방향이든 4비트 회전하면 두 니블이 교환된다.

---

### **Q6.** Write a single SHLD instruction that shifts the highest bit of the AX register into the lowest bit position of DX and shifts DX one bit to the left.

**정답:**
shld dx,ax,1

> **해설:**
> SHLD dest,src,count는 dest를 count만큼 왼쪽으로 밀고 빈 하위 비트를 src의 상위 비트로 채운다. src 자체는 변하지 않는다.

---

### **Q7.** Write a sequence of instructions that shift three memory bytes to the right by 1 bit position. Use the following test data:

```asm
byteArray BYTE 81h,20h,33h
```

**정답:**
```asm
; treat byteArray+2 as the highest-order byte
shr byteArray+2,1     ; high byte: bit 0 → CF
rcr byteArray+1,1     ; middle byte: CF → bit 7, bit 0 → CF
rcr byteArray,1       ; low byte: CF → bit 7
```

> **해설:**
> 최상위 단위를 SHR로 먼저 시프트하고, 그 아래 단위들은 RCR을 써서 한 바이트에서 떨어진 비트가 Carry 플래그를 통해 다음 바이트의 맨 위로 들어가게 한다.

---

### **Q8.** Write a sequence of instructions that shift three memory words to the left by 1 bit position. Use the following test data:

```asm
wordArray WORD 810Dh, 0C064h,93ABh
```

**정답:**
```asm
; treat wordArray as the lowest-order word
shl wordArray,1       ; low word: bit 15 → CF
rcl wordArray+2,1     ; middle word: CF → bit 0, bit 15 → CF
rcl wordArray+4,1     ; high word: CF → bit 0
```

> **해설:**
> 왼쪽 시프트는 최하위 단위(SHL)부터 시작해서 더 높은 단위마다 RCL로 캐리를 위로 전파한다.

---

### **Q9.** Write instructions that multiply −5 by 3 and store the result in a 16-bit variable val1.

**정답:**
```asm
.data
val1 SWORD ?
.code
mov ax,-5
mov bx,3
imul bx           ; DX:AX = -15 (signed multiply)
mov val1,ax
; or the two-operand form: mov ax,-5 / imul ax,3 / mov val1,ax
```

> **해설:**
> IMUL은 부호 있는 곱셈이다. MUL은 −5를 부호 없는 FFFBh로 취급한다. 16비트 곱은 AX에 들어간다(DX는 부호 확장 FFFFh).

---

### **Q10.** Write instructions that divide −276 by 10 and store the result in a 16-bit variable val1.

**정답:**
```asm
.data
val1 SWORD ?
.code
mov ax,-276
cwd               ; sign-extend AX into DX:AX
mov bx,10
idiv bx           ; AX = -27 (quotient), DX = -6 (remainder)
mov val1,ax
```

> **해설:**
> IDIV는 부호 있는 피제수 DX:AX를 나누므로 먼저 CWD로 DX를 AX의 부호로 채워야 한다. 몫 −27은 AX, 나머지 −6은 DX에 들어간다(나머지는 피제수의 부호를 따른다).

---

### **Q11.** Implement the following C++ expression in assembly language, using 32-bit unsigned operands:

```asm
val1 = (val2 * val3) / (val4 - 3)
```

**정답:**
```asm
mov eax,val2
mul val3          ; EDX:EAX = val2 * val3
mov ebx,val4
sub ebx,3
div ebx           ; EAX = (val2*val3) / (val4-3)
mov val1,eax
```

> **해설:**
> MUL은 64비트 곱을 EDX:EAX에 남기며, 이는 DIV가 기대하는 피제수 형태이므로 나눗셈 전에 EDX를 따로 지울 필요가 없다. 부호 없는 피연산자에는 IMUL/IDIV 대신 MUL/DIV를 쓴다.

---

### **Q12.** Implement the following C++ expression in assembly language, using 32-bit signed operands:

```asm
val1 = (val2 / val3) * (val1 + val2)
```

**정답:**
```asm
mov eax,val2
cdq               ; sign-extend EAX into EDX:EAX
idiv val3         ; EAX = val2 / val3
mov ebx,val1
add ebx,val2      ; EBX = val1 + val2
imul ebx          ; EDX:EAX = (val2/val3) * (val1+val2)
mov val1,eax
```

> **해설:**
> 부호 있는 나눗셈은 CDQ로 EDX:EAX를 준비해야 하고, IDIV/IMUL이 부호를 올바르게 유지한다. 곱은 EAX(하위 더블워드)에서 가져온다.

---

### **Q13.** Write a procedure that displays an unsigned 8-bit binary value in decimal format. Pass the binary value in AL. The input range is limited to 0 to 99, decimal. The only procedure you can call from the book's link library is WriteChar. The procedure should contain approximately eight instructions. Here is a sample call:

```asm
mov al,65         ; range limit: 0 to 99
call showDecimal8
```

**정답:**
```asm
showDecimal8 PROC
    mov ah,0
    mov bl,10
    div bl            ; AL = tens digit, AH = ones digit
    mov bx,ax         ; save both digits (BL = tens, BH = ones)
    add al,'0'        ; convert tens to ASCII
    call WriteChar
    mov al,bh
    add al,'0'        ; convert ones to ASCII
    call WriteChar
    ret
showDecimal8 ENDP
```

> **해설:**
> 10으로 나누면 값이 십의 자리(몫, AL)와 일의 자리(나머지, AH)로 나뉜다. 각 자릿수에 30h를 더하면 ASCII 문자가 되고 WriteChar가 출력한다. WriteChar가 AH를 보존하지 않을 수 있으므로 나머지를 저장해 둔다.

---

### **Q14.** Challenge: Suppose AX contains 0072h and the Auxiliary Carry flag is set as a result of adding two unknown ASCII decimal digits. Use the Intel 64 and IA-32 Instruction Set Reference to determine what output the AAA instruction would produce. Explain your answer.

**정답:**
AX = 0108h

> **해설:**
> AAA: (AL AND 0Fh) > 9이거나 AF = 1이면 AL = AL + 6, AH = AH + 1, AF = CF = 1; 마지막으로 AL = AL AND 0Fh. 여기서는 AF = 1이므로 AL = 72h + 6 = 78h → AND 0Fh = 08h, AH = 00h + 1 = 01h. AX = 0108h, 즉 언팩 숫자 1과 8(합은 18).

---

### **Q15.** Challenge: Using only SUB, MOV, and AND instructions, show how to calculate x = n mod y, assuming that you are given the values of n and y. You can assume that n is any 32-bit unsigned integer, and y is a power of 2.

**정답:**
```asm
mov eax,y
sub eax,1        ; y - 1 = mask of all 1s below the power-of-2 bit
and eax,n        ; keep only the low bits of n
mov x,eax        ; x = n mod y
```

> **해설:**
> y = 2^k이면 n mod y는 n의 하위 k비트다. y − 1은 정확히 그 k비트가 1이므로 AND하면 나눗셈 없이 나머지를 얻는다.

---

### **Q16.** Challenge: Using only SAR, ADD, and XOR instructions (but no conditional jumps), write code that calculates the absolute value of the signed integer in the EAX register. Hints: A number can be negated by adding −1 to it and then forming its one's complement. Also, if you XOR an integer with all 1s, its 1s are reversed. On the other hand, if you XOR an integer with all zeros, the integer is unchanged.

**정답:**
```asm
xor edx,edx
add edx,eax        ; EDX = copy of EAX
sar edx,31         ; EDX = 0 if EAX >= 0, FFFFFFFFh (-1) if EAX < 0
add eax,edx        ; negative: EAX - 1 ; positive: unchanged
xor eax,edx        ; negative: one's complement → -EAX ; positive: unchanged
```

> **해설:**
> SAR 31은 부호 비트를 모두 0 또는 모두 1인 마스크로 만든다. 음수는 −1을 더한 뒤 보수(모두 1과 XOR)를 취하면 부호가 바뀌고, 양수는 마스크가 0이라 ADD 0과 XOR 0으로 변하지 않는다. 분기가 필요 없다.

---
