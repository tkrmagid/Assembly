# Short Answer

### **Q1.** What is the purpose of the STRUCT directive?

**정답:**
To define a structure template — a group of named fields of possibly different types — from which variables can later be declared

> **해설:**
> STRUCT … ENDS는 저장 공간을 할당하지 않고 배치(필드 이름, 타입, 기본값)만 기술한다. 저장 공간은 그 구조체 타입의 변수를 선언할 때 할당된다.

---

### **Q2.** Assume that the following structure has been defined:

```asm
RentalInvoice STRUCT
    invoiceNum BYTE 5 DUP(' ')
    dailyPrice WORD ?
    daysRented WORD ?
RentalInvoice ENDS
```

State whether or not each of the following declarations is valid:

**정답:**
a. `rentals RentalInvoice <>` → valid  
b. `RentalInvoice rentals <>` → invalid  
c. `march RentalInvoice <'12345',10,0>` → valid  
d. `RentalInvoice <,10,0>` → valid  
e. `current RentalInvoice <,15,0,0>` → invalid

> **해설:**
> a. 유효(기본값). b. 무효 — 변수 이름이 구조체 타입보다 앞에 와야 한다. c. 유효 — 세 필드 모두 초기화. d. 유효 — 뒤의 두 필드를 덮어쓰는 이름 없는 구조체 변수. e. 무효 — 필드가 세 개인 구조체에 초기값 네 개.

---

### **Q3.** (True/False): A macro cannot contain data definitions.

**정답:**
False

> **해설:**
> 매크로는 .data로 전환해 변수를 정의하고(보통 LOCAL 레이블 사용) 다시 .code로 돌아올 수 있다 — mWrite가 바로 그렇게 한다.

---

### **Q4.** What is the purpose of the LOCAL directive?

**정답:**
To declare labels inside a macro that receive a unique name in each expansion, avoiding duplicate-label errors when the macro is invoked more than once

> **해설:**
> 확장마다 매크로 본문이 복사되므로 LOCAL이 없으면 string이나 L1 같은 레이블이 두 번 정의된다. (PROC 안에서는 LOCAL이 스택 변수를 선언한다.)

---

### **Q5.** Which directive displays a message on the console during the assembly step?

**정답:**
ECHO

> **해설:**
> ECHO는 어셈블러가 실행되는 동안 텍스트를 표준 출력에 쓴다. 잘못된 매크로 인수를 알릴 때 유용하다.

---

### **Q6.** Which directive marks the end of a conditional block of statements?

**정답:**
ENDIF

> **해설:**
> IF(또는 IFB, IFIDN, …)가 조건부 어셈블 블록을 열고, 선택적인 ELSE/ELSEIF가 이어지며, ENDIF가 닫는다.

---

### **Q7.** List all the relational operators that can be used in constant boolean expressions.

**정답:**
LT, GT, EQ, NE, LE, GE

> **해설:**
> IF 지시어의 상수식은 어셈블러의 관계 연산자 LT(작다), GT(크다), EQ(같다), NE(다르다), LE(작거나 같다), GE(크거나 같다)를 쓴다. 반면 런타임 .IF 지시어는 C 스타일 기호를 쓴다. (순서는 상관없다.)

---

### **Q8.** What is the purpose of the & operator in a macro definition?

**정답:**
Substitution: it forces a parameter to be expanded even when it appears inside a string literal or as part of an identifier

> **해설:**
> &가 없으면 따옴표 안의 "Hello, name"은 치환되지 않는다. "Hello, &name"은 인수 값으로 치환된다.

---

### **Q9.** What is the purpose of the ! operator in a macro definition?

**정답:**
Literal-character operator: the character that follows it is treated as an ordinary character rather than an operator, e.g. !> passes a >

> **해설:**
> <, >, ; 같은 문자는 매크로 처리기에서 특별한 의미를 가진다. 앞에 !를 붙이면 어셈블러가 문자 그대로 받아들인다.

---

### **Q10.** What is the purpose of the % operator in a macro definition?

**정답:**
Expansion operator: it evaluates a constant expression or text equate and passes the resulting value as the argument, e.g. mWrite %(count+1)

> **해설:**
> 보통 매크로 인수는 텍스트로 전달된다. %는 어셈블러가 먼저 평가하게 하여 매크로가 식의 텍스트 대신 숫자 결과를 받게 한다.

---
