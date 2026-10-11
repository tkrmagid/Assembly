# Short Answer

### **Q1.** Which instruction pushes all of the 32-bit general-purpose registers on the stack?

**정답:**
PUSHAD

> **해설:**
> PUSHAD는 EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI 순으로 푸시하고 POPAD가 복원한다(PUSHA는 16비트 버전).

---

### **Q2.** Which instruction pushes the 32-bit EFLAGS register on the stack?

**정답:**
PUSHFD

> **해설:**
> PUSHFD는 32비트 EFLAGS 레지스터를 푸시한다(PUSHF는 16비트 FLAGS).

---

### **Q3.** Which instruction pops the stack into the EFLAGS register?

**정답:**
POPFD

> **해설:**
> POPFD는 스택의 더블워드를 EFLAGS로 팝해 PUSHFD로 저장한 플래그를 복원한다.

---

### **Q4.** Challenge: Another assembler (called NASM) permits the PUSH instruction to list multiple specific registers. Why might this approach be better than the PUSHAD instruction in MASM? Here is a NASM example:

```asm
PUSH EAX EBX ECX
```

**정답:**
You push only the registers you actually need to save, using less stack space and time than PUSHAD, and the code documents which registers matter

> **해설:**
> PUSHAD는 두세 개만 보존하면 될 때도 항상 8개(32바이트)를 푸시한다. 선택적 목록이 더 효율적이고 명확하다.

---

### **Q5.** Challenge: Suppose there were no PUSH instruction. Write a sequence of two other instructions that would accomplish the same as push eax.

**정답:**
```asm
sub esp,4
mov [esp],eax
```

> **해설:**
> PUSH는 먼저 ESP를 피연산자 크기(더블워드는 4)만큼 감소시킨 뒤, 새 스택 맨 위에 피연산자를 저장한다.

---

### **Q6.** (True/False): The RET instruction pops the top of the stack into the instruction pointer.

**정답:**
True

> **해설:**
> RET은 CALL이 푸시한 반환 주소를 EIP로 팝하므로 CALL 다음부터 실행이 이어진다.

---

### **Q7.** (True/False): Nested procedure calls are not permitted by the Microsoft assembler unless the NESTED operator is used in the procedure definition.

**정답:**
False

> **해설:**
> 중첩 호출은 항상 허용된다. 각 CALL이 자신의 반환 주소를 스택에 푸시한다. NESTED 연산자는 존재하지 않는다.

---

### **Q8.** (True/False): In protected mode, each procedure call uses a minimum of 4 bytes of stack space.

**정답:**
True

> **해설:**
> CALL이 32비트 반환 주소를 푸시하므로 매개변수를 푸시하지 않아도 최소 4바이트가 쓰인다.

---

### **Q9.** (True/False): The ESI and EDI registers cannot be used when passing 32-bit parameters to procedures.

**정답:**
False

> **해설:**
> 어떤 범용 레지스터로도 매개변수를 전달할 수 있다. ArraySum도 배열 포인터를 ESI로 받는다.

---

### **Q10.** (True/False): The ArraySum procedure (Section 5.2.5) receives a pointer to any array of doublewords.

**정답:**
True

> **해설:**
> ArraySum은 범용으로 작성되어 ESI가 임의의 더블워드 배열을 가리키고 ECX가 원소 개수를 주므로 특정 변수에 묶여 있지 않다.

---

### **Q11.** (True/False): The USES operator lets you name all registers that are modified within a procedure.

**정답:**
True

> **해설:**
> USES는 보존할 레지스터를 나열하며, 어셈블러가 자동으로 저장하고 복원한다.

---

### **Q12.** (True/False): The USES operator only generates PUSH instructions, so you must code POP instructions yourself.

**정답:**
False

> **해설:**
> USES는 시작 부분의 PUSH 명령과 RET 직전의 대응하는 POP 명령을 모두 생성한다.

---

### **Q13.** (True/False): The register list in the USES directive must use commas to separate the register names.

**정답:**
False

> **해설:**
> USES의 레지스터 이름은 공백으로 구분한다: ArraySum PROC USES esi ecx.

---

### **Q14.** Which statement(s) in the ArraySum procedure (Section 5.2.5) would have to be modified so it could accumulate an array of 16-bit words? Create such a version of ArraySum and test it.

**정답:**
```asm
ArraySum PROC                ; ESI = array of WORDs, ECX = count
    push esi
    push ecx
    mov  eax,0
L1: add  ax,[esi]            ; was: add eax,[esi]   (16-bit add)
    add  esi,TYPE WORD       ; was: add esi,TYPE DWORD
    loop L1
    pop  ecx
    pop  esi
    ret                      ; AX = sum
ArraySum ENDP
```

> **해설:**
> 두 줄이 바뀐다: 누적은 16비트 피연산자를 써야 하고(add ax,[esi], 또는 movzx로 임시 레지스터에 읽어 EAX에 더하면 32비트 합), 포인터는 2바이트(TYPE WORD)씩 전진해야 한다.

---

### **Q15.** What will be the final value in EAX after these instructions execute?

```asm
push 5
push 6
pop eax
pop eax
```

**정답:**
5

> **해설:**
> 스택은 LIFO다: 첫 pop이 마지막에 푸시한 6을 꺼내고, 두 번째 pop이 5를 꺼내 EAX에 남는다.

---

### **Q16.** Which statement is true about what will happen when the example code runs?

```asm
 1: main PROC
 2:   push 10
 3:   push 20
 4:   call Ex2Sub
 5:   pop eax
 6:   INVOKE ExitProcess,0
 7: main ENDP
 8:
 9: Ex2Sub PROC
10:   pop eax
11:   ret
12: Ex2Sub ENDP
```

a. EAX will equal 10 on line 6
b. The program will halt with a runtime error on Line 10
c. EAX will equal 20 on line 6
d. The program will halt with a runtime error on Line 11

**정답:**
d. The program will halt with a runtime error on Line 11

> **해설:**
> Ex2Sub에 들어왔을 때 스택 맨 위는 반환 주소다. 10번 줄이 이를 EAX로 팝해 버리므로 11번 줄의 RET은 그 다음 항목인 20을 팝해 주소 20으로 점프한다 — 런타임 오류. (10번 줄 자체는 정상 실행된다.)

---

### **Q17.** Which statement is true about what will happen when the example code runs?

```asm
 1: main PROC
 2:   mov eax,30
 3:   push eax
 4:   push 40
 5:   call Ex3Sub
 6:   INVOKE ExitProcess,0
 7: main ENDP
 8:
 9: Ex3Sub PROC
10:   pusha
11:   mov eax,80
12:   popa
13:   ret
14: Ex3Sub ENDP
```

a. EAX will equal 40 on line 6
b. The program will halt with a runtime error on Line 6
c. EAX will equal 30 on line 6
d. The program will halt with a runtime error on Line 13

**정답:**
c. EAX will equal 30 on line 6

> **해설:**
> PUSHA가 범용 레지스터(EAX = 30 포함)를 모두 저장하고 POPA가 복원하므로 mov eax,80은 취소된다. 스택이 균형을 이루어 RET은 정상 반환하고, 6번 줄에서 EAX는 여전히 30이다. main이 푸시한 두 값은 팝되지 않지만 ExitProcess 전에는 오류를 일으키지 않는다.

---

### **Q18.** Which statement is true about what will happen when the example code runs?

```asm
 1: main PROC
 2:   mov eax,40
 3:   push offset Here
 4:   jmp Ex4Sub
 5: Here:
 6:   mov eax,30
 7:   INVOKE ExitProcess,0
 8: main ENDP
 9:
10: Ex4Sub PROC
11:   ret
12: Ex4Sub ENDP
```

a. EAX will equal 30 on line 7
b. The program will halt with a runtime error on Line 4
c. EAX will equal 30 on line 6
d. The program will halt with a runtime error on Line 11

**정답:**
a. EAX will equal 30 on line 7

> **해설:**
> Here의 오프셋을 푸시하고 점프하는 것은 CALL을 흉내 낸 것이다: Ex4Sub의 RET이 그 오프셋을 팝해 Here에서 계속된다. 6번 줄이 EAX = 30으로 만들므로 7번 줄에서 EAX는 30이다. (6번 줄 실행 전에는 아직 40.)

---

### **Q19.** Which statement is true about what will happen when the example code runs?

```asm
 1: main PROC
 2:   mov edx,0
 3:   mov eax,40
 4:   push eax
 5:   call Ex5Sub
 6:   INVOKE ExitProcess,0
 7: main ENDP
 8:
 9: Ex5Sub PROC
10:   pop eax
11:   pop edx
12:   push eax
13:   ret
14: Ex5Sub ENDP
```

a. EDX will equal 40 on line 6
b. The program will halt with a runtime error on Line 13
c. EDX will equal 0 on line 6
d. The program will halt with a runtime error on Line 11

**정답:**
a. EDX will equal 40 on line 6

> **해설:**
> 10번 줄이 반환 주소를 EAX로 팝하고, 11번 줄이 푸시된 값 40을 EDX로 팝한 뒤, 12번 줄이 반환 주소를 다시 푸시한다. 따라서 RET은 6번 줄로 정상 반환하며 EDX = 40이다.

---

### **Q20.** What values will be written to the array when the following code executes?

```asm
.data
array DWORD 4 DUP(0)
.code
main PROC
    mov eax,10
    mov esi,0
    call proc_1
    add esi,4
    add eax,10
    mov array[esi],eax
    INVOKE ExitProcess,0
main ENDP
proc_1 PROC
    call proc_2
    add esi,4
    add eax,10
    mov array[esi],eax
    ret
proc_1 ENDP
proc_2 PROC
    call proc_3
    add esi,4
    add eax,10
    mov array[esi],eax
    ret
proc_2 ENDP
proc_3 PROC
    mov array[esi],eax
    ret
proc_3 ENDP
```

**정답:**
array[0] = 10, array[1] = 20, array[2] = 30, array[3] = 40

> **해설:**
> 호출이 proc_3까지 중첩되어 오프셋 0에 10을 저장한다. proc_2, proc_1, main으로 돌아오면서 각 단계가 ESI에 4, EAX에 10을 더한 뒤 저장한다: 오프셋 4에 20, 8에 30, 12에 40. 최종 배열: 10, 20, 30, 40.

---
