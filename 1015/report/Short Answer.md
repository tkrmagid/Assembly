# Short Answer

### **Q1.** What will be the value of BX after the following instructions execute?

```asm
mov bx,0FFFFh
and bx,6Bh
```

**정답:**
006Bh

> **해설:**
> 모두 1인 값과 AND하면 다른 피연산자가 그대로 남으므로 BX = 006Bh(상위 바이트는 00h와 AND).

---

### **Q2.** What will be the value of BX after the following instructions execute?

```asm
mov bx,91BAh
and bx,92h
```

**정답:**
0092h

> **해설:**
> 91BAh = 1001 0001 1011 1010, 0092h = 0000 0000 1001 0010. AND는 둘 다 1인 곳만 남긴다: 하위 바이트 BAh AND 92h = 1011 1010 AND 1001 0010 = 1001 0010 = 92h, 상위 바이트는 00. 결과 0092h.

---

### **Q3.** What will be the value of BX after the following instructions execute?

```asm
mov bx,0649Bh
or bx,3Ah
```

**정답:**
64BBh

> **해설:**
> 하위 바이트만 영향을 받는다: 9Bh OR 3Ah = 1001 1011 OR 0011 1010 = 1011 1011 = BBh. 상위 바이트 64h는 00h와 OR되어 그대로다. 결과 64BBh.

---

### **Q4.** What will be the value of BX after the following instructions execute?

```asm
mov bx,029D6h
xor bx,8181h
```

**정답:**
A857h

> **해설:**
> 29D6h = 0010 1001 1101 0110, 8181h = 1000 0001 1000 0001. XOR는 비트가 다른 곳에 1: 1010 1000 0101 0111 = A857h.

---

### **Q5.** What will be the value of EBX after the following instructions execute?

```asm
mov ebx,0AFAF649Bh
or ebx,3A219604h
```

**정답:**
BFAFF69Fh

> **해설:**
> 바이트별로 OR: AF|3A = 1010 1111 | 0011 1010 = BF; AF|21 = AF; 64|96 = 0110 0100 | 1001 0110 = F6; 9B|04 = 9F. 결과 BFAFF69Fh.

---

### **Q6.** What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0AFAF649Bh
xor rbx,0FFFFFFFFh
```

**정답:**
0000000050509B64h

> **해설:**
> 32비트 즉시값은 RBX로 0 확장되므로 두 피연산자 모두 상위 32비트는 0이다. FFFFFFFFh와 XOR하면 하위 32비트가 반전된다: AFAF649Bh → 50509B64h. RBX = 0000000050509B64h.

---

### **Q7.** In the following instruction sequence, show the resulting value of AL where indicated, in binary:

```asm
mov al,01101111b
and al,00101101b   ; a.
mov al,6Dh
and al,4Ah         ; b.
mov al,00001111b
or al,61h          ; c.
mov al,94h
xor al,37h         ; d.
```

**정답:**
a. 00101101
b. 01001000
c. 01101111
d. 10100011

> **해설:**
> a. 01101111 AND 00101101 = 00101101. b. 6Dh = 0110 1101, 4Ah = 0100 1010 → AND = 0100 1000. c. 0000 1111 OR 61h(0110 0001) = 0110 1111. d. 94h = 1001 0100 XOR 37h(0011 0111) = 1010 0011.

---

### **Q8.** In the following instruction sequence, show the resulting value of AL where indicated, in hexadecimal:

```asm
mov al,7Ah
not al             ; a.
mov al,3Dh
and al,74h         ; b.
mov al,9Bh
or al,35h          ; c.
mov al,72h
xor al,0DCh        ; d.
```

**정답:**
a. 85h
b. 34h
c. BFh
d. AEh

> **해설:**
> a. NOT 0111 1010 = 1000 0101 = 85h. b. 3Dh(0011 1101) AND 74h(0111 0100) = 0011 0100 = 34h. c. 9Bh(1001 1011) OR 35h(0011 0101) = 1011 1111 = BFh. d. 72h(0111 0010) XOR DCh(1101 1100) = 1010 1110 = AEh.

---

### **Q9.** In the following instruction sequence, show the values of the Carry, Zero, and Sign flags where indicated:

```asm
mov al,00001111b
test al,00000010b  ; a. CF= ZF= SF=
mov al,00000110b
cmp al,00000101b   ; b. CF= ZF= SF=
mov al,00000101b
cmp al,00000111b   ; c. CF= ZF= SF=
```

**정답:**
a. CF = 0, ZF = 0, SF = 0
b. CF = 0, ZF = 0, SF = 0
c. CF = 1, ZF = 0, SF = 1

> **해설:**
> a. TEST는 00001111 AND 00000010 → 00000010, 0이 아니고 양수이며 TEST는 항상 CF를 0으로: CF 0, ZF 0, SF 0. b. 6 − 5 = 1: 빌림 없음, 0 아님, 양수 → 0, 0, 0. c. 5 − 7 = −2(FEh): 빌림 → CF 1, ZF 0, SF 1.

---

### **Q10.** Which conditional jump instruction executes a branch based on the contents of ECX?

**정답:**
JECXZ

> **해설:**
> JECXZ는 ECX가 0이면 점프한다(JCXZ는 CX, JRCXZ는 RCX 검사). 플래그가 아니라 레지스터를 직접 검사한다.

---

### **Q11.** How are JA and JNBE affected by the Zero and Carry flags?

**정답:**
They are the same instruction: the jump is taken only when CF = 0 and ZF = 0

> **해설:**
> 부호 없는 값에서 "above"는 작지도(CF = 0) 같지도(ZF = 0) 않다는 뜻이다. JA와 JNBE는 같은 opcode의 두 니모닉이다.

---

### **Q12.** What will be the final value in EDX after this code executes?

```asm
    mov edx,1
    mov eax,7FFFh
    cmp eax,8000h
    jl L1
    mov edx,0
L1:
```

**정답:**
1

> **해설:**
> JL은 부호 있는 비교다. 7FFFh(32767)와 8000h(32768)는 둘 다 양의 32비트 값이므로 7FFFh < 8000h가 성립해 점프하고 EDX는 1을 유지한다.

---

### **Q13.** What will be the final value in EDX after this code executes?

```asm
    mov edx,1
    mov eax,7FFFh
    cmp eax,8000h
    jb L1
    mov edx,0
L1:
```

**정답:**
1

> **해설:**
> JB는 부호 없는 비교다. 7FFFh는 8000h보다 작으므로 점프하고 EDX는 1 그대로다.

---

### **Q14.** What will be the final value in EDX after this code executes?

```asm
    mov edx,1
    mov eax,7FFFh
    cmp eax,0FFFF8000h
    jl L2
    mov edx,0
L2:
```

**정답:**
0

> **해설:**
> 0FFFF8000h는 부호 있는 32비트 값으로 음수(−32768)다. 32767은 −32768보다 작지 않으므로 JL은 실행되지 않고 EDX는 0이 된다. (부호 없는 JB였다면 점프했을 것이다.)

---

### **Q15.** (True/False): The following code will jump to the label named Target.

```asm
mov eax,-30
cmp eax,-50
jg Target
```

**정답:**
True

> **해설:**
> JG는 부호 있는 비교다: −30은 −50보다 크므로 점프한다.

---

### **Q16.** (True/False): The following code will jump to the label named Target.

```asm
mov eax,-42
cmp eax,26
ja Target
```

**정답:**
True

> **해설:**
> JA는 부호 없는 값을 비교한다. −42는 FFFFFFD6h로 저장되며 부호 없는 수로는 26보다 훨씬 크므로 점프한다.

---

### **Q17.** What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0FFFFFFFFFFFFFFFFh
and rbx,80h
```

**정답:**
0000000000000080h

> **해설:**
> 모두 1인 값과 80h를 AND하면 bit 7만 남는다. 즉시값은 0으로 64비트 확장되므로 나머지 비트는 모두 0이 된다.

---

### **Q18.** What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0FFFFFFFFFFFFFFFFh
and rbx,808080h
```

**정답:**
0000000000808080h

> **해설:**
> 마스크 808080h에서 1인 비트만 남는다: 하위 세 바이트 각각의 최상위 비트.

---

### **Q19.** What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0FFFFFFFFFFFFFFFFh
and rbx,80808080h
```

**정답:**
0000000080808080h

> **해설:**
> 32비트 마스크 80808080h가 64비트로 0 확장되므로 상위 32비트는 0이 되고 하위 더블워드는 네 개의 최상위 비트만 남는다.

---
