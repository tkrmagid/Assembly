# Algorithm Workbench

### **Q1.** Here is a calling sequence for a procedure named AddThree that adds three doublewords (assume that the STDCALL calling convention is used):

```asm
push 10h
push 20h
push 30h
call AddThree
```

Draw a picture of the procedure's stack frame immediately after EBP has been pushed on the runtime stack.

**정답:**
```asm
   higher addresses
   +---------------+
   |     10h       |  [EBP+16]  (third parameter, pushed first)
   +---------------+
   |     20h       |  [EBP+12]
   +---------------+
   |     30h       |  [EBP+8]   (first parameter, pushed last)
   +---------------+
   | return address|  [EBP+4]
   +---------------+
   |   old EBP     |  [EBP]  ← ESP, EBP (after mov ebp,esp)
   +---------------+
   lower addresses
```

> **해설:**
> 인수는 역순으로 푸시되므로 마지막에 푸시된 30h가 반환 주소에 가장 가깝다. CALL이 반환 주소를 푸시하고 프롤로그가 그 위에 EBP를 푸시한다. mov ebp,esp 후에는 EBP로부터 고정된 양의 오프셋으로 매개변수에 접근할 수 있다.

---

### **Q2.** Create a procedure named AddThree that receives three integer parameters and calculates and returns their sum in the EAX register.

**정답:**
```asm
AddThree PROC
    push ebp
    mov  ebp,esp
    mov  eax,[ebp+8]
    add  eax,[ebp+12]
    add  eax,[ebp+16]
    pop  ebp
    ret  12              ; remove three doubleword parameters
AddThree ENDP

; or with declared parameters:
AddThree PROC, x:DWORD, y:DWORD, z:DWORD
    mov eax,x
    add eax,y
    add eax,z
    ret
AddThree ENDP
```

> **해설:**
> 명시적 스택 매개변수를 쓰면 세 더블워드는 [ebp+8], [ebp+12], [ebp+16]에 있고 RET 12가 이를 정리한다(STDCALL). PROC 매개변수 목록을 쓰면 어셈블러가 같은 프롤로그, 에필로그, RET 12를 대신 생성한다.

---

### **Q3.** Declare a local variable named pArray that is a pointer to an array of doublewords.

**정답:**
LOCAL pArray:PTR DWORD

> **해설:**
> LOCAL은 프로시저 안에 스택 변수를 선언한다. PTR DWORD는 더블워드 포인터 타입이다.

---

### **Q4.** Declare a local variable named buffer that is an array of 20 bytes.

**정답:**
LOCAL buffer[20]:BYTE

> **해설:**
> 이름 뒤 대괄호의 크기는 LOCAL이 해당 타입의 원소 20개를 스택에 예약하도록 한다.

---

### **Q5.** Declare a local variable named pwArray that points to a 16-bit unsigned integer.

**정답:**
LOCAL pwArray:PTR WORD

> **해설:**
> WORD가 16비트 부호 없는 타입이므로 그 포인터는 PTR WORD다.

---

### **Q6.** Declare a local variable named myByte that holds an 8-bit signed integer.

**정답:**
LOCAL myByte:SBYTE

> **해설:**
> SBYTE는 부호 있는 8비트 타입이다.

---

### **Q7.** Declare a local variable named myArray that is an array of 20 doublewords.

**정답:**
LOCAL myArray[20]:DWORD

> **해설:**
> 지역 배열을 위해 80바이트(20 × 4)의 스택 공간을 예약한다.

---

### **Q8.** Create a procedure named SetColor that receives two stack parameters: forecolor and backcolor, and calls the SetTextColor procedure from the Irvine32 library.

**정답:**
```asm
SetColor PROC, forecolor:DWORD, backcolor:DWORD
    mov eax,backcolor
    shl eax,4              ; background * 16
    add eax,forecolor      ; + foreground
    call SetTextColor
    ret
SetColor ENDP

; sample call: INVOKE SetColor, yellow, blue
```

> **해설:**
> SetTextColor는 EAX = (배경색 × 16) + 전경색을 기대한다. 배경색을 왼쪽으로 4비트 시프트하면 16을 곱한 것이고, 여기에 전경색을 더한다.

---

### **Q9.** Create a procedure named WriteColorChar that receives three stack parameters: char, forecolor, and backcolor. It displays a single character, using the color attributes specified in forecolor and backcolor.

**정답:**
```asm
WriteColorChar PROC, char:DWORD, forecolor:DWORD, backcolor:DWORD
    INVOKE SetColor, forecolor, backcolor   ; from the previous exercise
    mov  al,BYTE PTR char
    call WriteChar
    ret
WriteColorChar ENDP

; sample call: INVOKE WriteColorChar, 'X', yellow, blue
```

> **해설:**
> SetColor를 재사용해 속성을 설정한 뒤 문자를 AL(WriteChar의 입력 레지스터)에 넣고 WriteChar를 호출한다.

---

### **Q10.** Write a procedure named DumpMemory that encapsulates the DumpMem procedure in the Irvine32 library. Use declared parameters and the USES directive. The following is an example of how it should be called: INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array.

**정답:**
```asm
DumpMemory PROC USES esi ecx ebx,
    pStart:PTR BYTE,        ; starting offset
    count:DWORD,            ; number of units
    unitSize:DWORD          ; size of each unit (1, 2 or 4)
    mov  esi,pStart
    mov  ecx,count
    mov  ebx,unitSize
    call DumpMem
    ret
DumpMemory ENDP
```

> **해설:**
> DumpMem은 입력을 ESI, ECX, EBX로 받는다. 래퍼는 선언된 매개변수를 그 레지스터에 복사하고, USES가 호출자를 위해 레지스터를 보존한다.

---

### **Q11.** Declare a procedure named MultArray that receives two pointers to arrays of doublewords, and a third parameter indicating the number of array elements. Also, create a PROTO declaration for this procedure.

**정답:**
```asm
MultArray PROTO, pArray1:PTR DWORD, pArray2:PTR DWORD, count:DWORD

MultArray PROC, pArray1:PTR DWORD, pArray2:PTR DWORD, count:DWORD
    ...
    ret
MultArray ENDP
```

> **해설:**
> PROTO는 프로시저 이름과 매개변수 목록을 반복해 INVOKE를 검사할 수 있게 한다. PTR DWORD는 포인터 매개변수, DWORD는 원소 개수를 나타낸다.

---
