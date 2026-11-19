# Algorithm Workbench

### **Q1.** Create a structure named SampleStruct containing two fields: field1, a single 16-bit WORD, and field2, an array of 20 32-bit DWORDs. The initial values of the fields may be left undefined.

**정답:**
```asm
SampleStruct STRUCT
    field1 WORD ?
    field2 DWORD 20 DUP(?)
SampleStruct ENDS
```

> **해설:**
> 필드는 STRUCT와 ENDS 사이에 일반 변수처럼 선언한다. ?는 기본값을 미정으로 두고 DUP이 배열 필드를 만든다.

---

### **Q2.** Write a statement that retrieves the wHour field of a SYSTEMTIME structure.

**정답:**
mov ax,sysTime.wHour

> **해설:**
> 필드는 구조체 변수에 점 연산자로 접근한다. wHour는 WORD이므로 목적지는 16비트 레지스터다(SYSTEMTIME 타입의 변수 sysTime을 가정).

---

### **Q3.** Using the following Triangle structure, declare a structure variable and initialize its vertices to (0,0), (5, 0), and (7,6):

```asm
Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS
```

**정답:**
```asm
tri Triangle <<0,0>,<5,0>,<7,6>>
```

> **해설:**
> 각 꼭짓점은 중첩된 COORD 구조체이므로 그 초기값도 바깥 꺾쇠괄호 안에 다시 꺾쇠괄호로 감싼다.

---

### **Q4.** Declare an array of Triangle structures. Write a loop that initializes Vertex1 of each triangle to random coordinates in the range (0...10, 0...10).

**정답:**
```asm
.data
triangles Triangle 10 DUP(<>)
.code
    mov esi,OFFSET triangles
    mov ecx,LENGTHOF triangles
L1: mov eax,11                          ; RandomRange returns 0..10
    call RandomRange
    mov (Triangle PTR [esi]).Vertex1.X,ax
    mov eax,11
    call RandomRange
    mov (Triangle PTR [esi]).Vertex1.Y,ax
    add esi,TYPE Triangle               ; next structure
    loop L1
```

> **해설:**
> RandomRange(EAX = n)는 0..n−1을 반환하므로 0..10에는 11을 넘긴다. 간접 필드 접근은 (타입 PTR [esi]).필드 형태를 쓰고, 포인터는 원소마다 TYPE Triangle(12바이트)만큼 전진한다.

---

### **Q5.** Write a macro named mPrintChar that displays a single character on the screen. It should have two parameters: this first specifies the character to be displayed and the second specifies how many times the character should be repeated. Here is a sample call:

```asm
mPrintChar 'X',20
```

**정답:**
```asm
mPrintChar MACRO char:REQ, count:REQ
    LOCAL L1
    push eax
    push ecx
    mov  al,char
    mov  ecx,count
L1: call WriteChar
    loop L1
    pop  ecx
    pop  eax
ENDM
```

> **해설:**
> WriteChar는 AL을 출력한다. 매크로를 여러 번 호출할 수 있도록 루프 레이블은 LOCAL이어야 하고, 매크로가 쓰는 레지스터는 저장하고 복원한다.

---

### **Q6.** Write a macro named mGenRandom that generates a random integer between 0 and n − 1. Let n be the only parameter.

**정답:**
```asm
mGenRandom MACRO n:REQ
    mov  eax,n
    call RandomRange        ; returns EAX in the range 0..n-1
ENDM
; sample: mGenRandom 100
```

> **해설:**
> Irvine32의 RandomRange는 EAX로 n을 받아 0부터 n−1까지의 난수를 EAX로 반환하므로 매크로는 얇은 래퍼다.

---

### **Q7.** Write a macro named mPromptInteger that displays a prompt and inputs an integer from the user. Pass it a string literal and the name of a doubleword variable. Sample call:

```asm
.data
minVal DWORD ?
.code
mPromptInteger "Enter the minimum value", minVal
```

**정답:**
```asm
mPromptInteger MACRO prompt:REQ, varName:REQ
    mWrite prompt          ; display the literal (mWrite defines the string)
    call ReadInt           ; EAX = integer typed by the user
    mov  varName,eax
ENDM
```

> **해설:**
> mWrite가 문자열 리터럴을 처리하고(LOCAL 레이블로 데이터 생성), ReadInt가 부호 있는 정수를 EAX로 읽으며, 결과를 지정된 변수에 저장한다.

---

### **Q8.** Write a macro named mWriteAt that locates the cursor and writes a string literal to the console window. Suggestion: Invoke the mGotoxy and mWrite macros from the book's macro library.

**정답:**
```asm
mWriteAt MACRO X:REQ, Y:REQ, text:REQ
    mGotoxy X, Y
    mWrite  text
ENDM
; sample: mWriteAt 10, 5, "Hello"
```

> **해설:**
> 매크로는 다른 매크로를 호출할 수 있다. mGotoxy가 커서를(X 열, Y 행) 위치시키고 mWrite가 리터럴을 출력한다.

---

### **Q9.** Show the expanded code produced by the following statement that invokes the mWriteString macro from Section 10.2.5:

```asm
mWriteStr namePrompt
```

**정답:**
```asm
push edx
mov  edx,OFFSET namePrompt
call WriteString
pop  edx
```

> **해설:**
> 전처리기가 매크로 본문을 복사하고 매개변수 buffer를 인수 namePrompt로 바꾼다. 매크로는 EDX를 저장하고 문자열 오프셋을 넣어 WriteString을 호출한 뒤 EDX를 복원한다.

---

### **Q10.** Show the expanded code produced by the following statement that invokes the mReadString macro from Section 10.2.5:

```asm
mReadStr customerName
```

**정답:**
```asm
push ecx
push edx
mov  edx,OFFSET customerName
mov  ecx,SIZEOF customerName
call ReadString
pop  edx
pop  ecx
```

> **해설:**
> ReadString은 EDX = 버퍼 오프셋, ECX = 최대 문자 수가 필요하다. 매크로는 변수 이름으로부터 OFFSET과 SIZEOF로 둘을 채우고 레지스터를 보존한다.

---

### **Q11.** Write a macro named mDumpMemx that receives a single parameter, the name of a variable. Your macro must call the mDumpMem macro from the book's library, passing it the variable's offset, number of units, and unit size. Demonstrate a call to the mDumpMemx macro.

**정답:**
```asm
mDumpMemx MACRO varName:REQ
    mDumpMem OFFSET varName, LENGTHOF varName, TYPE varName
ENDM

.data
array DWORD 1,2,3,4
.code
mDumpMemx array
```

> **해설:**
> OFFSET, LENGTHOF, TYPE는 어셈블러가 변수 이름으로부터 계산하므로, 인수 하나로 세 인수짜리 mDumpMem 호출을 만들 수 있다.

---

### **Q12.** Show an example of a macro parameter having a default argument initializer.

**정답:**
```asm
mWriteSpace MACRO count:=<1>      ; default: 1 space
    push eax
    push ecx
    mov  al,' '
    mov  ecx,count
L1: call WriteChar
    loop L1
    pop  ecx
    pop  eax
ENDM
; mWriteSpace        → writes 1 space
; mWriteSpace 5      → writes 5 spaces
```

> **해설:**
> 이름:=<값> 문법은 호출자가 그 인수를 생략했을 때 사용되는 기본값을 지정한다.

---

### **Q13.** Write a short example that uses the IF, ELSE, and ENDIF directives.

**정답:**
```asm
mSetCount MACRO count
    IF count EQ 0
        mov ecx,1        ;; assembled only when count is 0
    ELSE
        mov ecx,count    ;; assembled otherwise
    ENDIF
ENDM
```

> **해설:**
> IF는 어셈블 시점에 상수식을 검사한다. 선택된 분기의 줄만 어셈블되고 ENDIF가 블록을 끝낸다.

---

### **Q14.** Write a statement using the IF directive that checks the value of the constant macro parameter Z; if Z is less than zero, display a message during assembly indicating that Z is invalid.

**정답:**
```asm
IF Z LT 0
    ECHO Z is invalid: it must be greater than or equal to zero
ENDIF
```

> **해설:**
> LT는 상수식용 어셈블러의 "작다" 연산자이고, ECHO는 파일이 어셈블되는 동안 메시지를 출력한다.

---

### **Q15.** Write a short macro that demonstrates the use of the & operator when the macro parameter is embedded in a literal string.

**정답:**
```asm
mGreet MACRO name
    LOCAL str
    .data
    str BYTE "Hello, &name!",0        ;; & substitutes the argument inside the string
    .code
    push edx
    mov  edx,OFFSET str
    call WriteString
    pop  edx
ENDM
; mGreet Sam   → "Hello, Sam!"
```

> **해설:**
> 따옴표 안에서는 매개변수 이름이 보통 그대로 남는다. &name이라고 쓰면 치환이 강제되어 문자열에 실제 인수가 들어간다.

---

### **Q16.** Assume the following mLocate macro definition:{code0}Show the source code generated by the preprocessor when the macro is expanded by each of the following statements:{code1}

**정답:**
```asm
; mLocate -2,20  → xval LT 0 is true, EXITM: NO code is generated

; mLocate 10,20
mov bx,0
mov ah,2
mov dh,20
mov dl,10
int 10h

; mLocate col,row  (col and row are labels, not negative constants)
mov bx,0
mov ah,2
mov dh,row
mov dl,col
int 10h
```

> **해설:**
> IF/EXITM 검사는 어셈블 시점에 수행된다. −2는 첫 검사에서 걸려 명령이 하나도 나오기 전에 확장이 멈춘다. 나머지 두 호출에서는 인수가 본문의 xval과 yval을 그대로 대체하며, ;; 주석은 확장에 복사되지 않는다.

---
