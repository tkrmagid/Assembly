# Short Answer

### **Q1.** Which statements belong in a procedure's epilogue when the procedure has stack parameters and local variables?

**정답:**
mov esp,ebp (discard locals), pop ebp (restore EBP), ret n (return and clean up the parameters) — or LEAVE followed by ret n

> **해설:**
> 에필로그는 프롤로그의 반대다: ESP를 EBP로 되돌려 지역 변수를 버리고, 호출자의 EBP를 팝하며, RET n으로 스택 매개변수를 제거한다(STDCALL).

---

### **Q2.** When a C function returns a 32-bit integer, where is the return value stored?

**정답:**
in the EAX register

> **해설:**
> 관례상 32비트 반환값은 EAX에 담는다(64비트 값은 EDX:EAX).

---

### **Q3.** How does a program using the STDCALL calling convention clean up the stack after a procedure call?

**정답:**
The called procedure removes the parameters with RET n, where n is the number of bytes of parameters

> **해설:**
> STDCALL에서는 피호출자가 책임진다: RET 8은 반환 주소를 팝한 뒤 ESP에 8을 더해 더블워드 매개변수 두 개를 버린다. C 규약에서는 호출자가 add esp,n을 대신 실행한다.

---

### **Q4.** How is the LEA instruction more powerful than the OFFSET operator?

**정답:**
LEA computes the address of an indirect operand at runtime (e.g. a local variable at [ebp-8] or [ebx+esi*4]); OFFSET only works for addresses fixed at assembly time

> **해설:**
> OFFSET은 어셈블러가 결정하므로 스택 위치나 레지스터 기준 주소를 표현할 수 없다. LEA는 CPU가 실행하므로 어떤 유효 주소든 계산할 수 있고, 지역 변수와 스택 매개변수에 필요한 것이 바로 이것이다.

---

### **Q5.** In the C++ example shown in Section 8.2.3, how much stack space is used by a variable of type int?

**정답:**
4 bytes (a 32-bit doubleword)

> **해설:**
> 32비트 AddTwo 예제에서 각 int 매개변수는 스택에 푸시된 더블워드이므로 4바이트를 차지한다([ebp+8]과 [ebp+12]).

---

### **Q6.** What advantages might the C calling convention have over the STDCALL calling convention?

**정답:**
Because the caller cleans up the stack, a procedure can accept a variable number of arguments (like printf)

> **해설:**
> 몇 개의 인수를 푸시했는지는 호출자만 알기 때문에 호출자가 제거하게 하면(C 규약) 가변 인수 함수가 가능해진다. 반면 STDCALL은 호출 코드가 작고 정리를 보장한다.

---

### **Q7.** (True/False): When using the PROC directive, all parameters must be listed on the same line.

**정답:**
False

> **해설:**
> 각 줄이 쉼표로 끝나면 매개변수를 다음 줄로 이어 쓸 수 있다. PROC 뒤의 쉼표는 목록 전체가 한 줄에 있을 때만 생략할 수 있다.

---

### **Q8.** (True/False): If you pass a variable containing the offset of an array of bytes to a procedure that expects a pointer to an array of words, the assembler will flag this as an error.

**정답:**
False

> **해설:**
> MASM은 전달하는 포인터의 타입을 검증하지 않는다. 프로그램은 어셈블되고 실행되지만 프로시저가 잘못된 바이트 수를 읽거나 쓰게 된다.

---

### **Q9.** (True/False): If you pass an immediate value to a procedure that expects a reference parameter, you can generate a general-protection fault.

**정답:**
True

> **해설:**
> 프로시저는 즉시값(예: 1000h)을 주소로 여기고 역참조한다. 그 위치는 프로그램의 것이 아닐 가능성이 높아 OS가 일반 보호 오류를 일으킨다.

---
