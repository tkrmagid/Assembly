# Algorithm Workbench

### **Q1.** Show an example of a base-index operand in 32-bit mode.

**정답:**
```asm
mov eax,[ebx+esi]      ; EBX = row offset, ESI = column offset
```

> **해설:**
> 베이스-인덱스 피연산자는 베이스 레지스터(행)와 인덱스 레지스터(열) 두 개를 더하며 상수 변위는 없다.

---

### **Q2.** Show an example of a base-index-displacement operand in 32-bit mode.

**정답:**
```asm
mov eax,table[ebx+esi]     ; or: mov eax,[ebx+esi+8]
```

> **해설:**
> 베이스와 인덱스 레지스터에 레이블이나 상수를 더하면 베이스-인덱스-변위 주소 지정이 된다. 레이블은 배열의 시작 오프셋을 제공한다.

---

### **Q3.** Suppose a two-dimensional array of doublewords has three logical rows and four logical columns. Write an expression using ESI and EDI that addresses the third column in the second row. (Numbering for rows and columns starts at zero.)

**정답:**
```asm
; RowSize = 4 columns * 4 bytes = 16
mov esi,1 * 16          ; row 1 (second row) → byte offset 16
mov edi,2 * 4           ; column 2 (third column) → byte offset 8
mov eax,table[esi+edi]  ; element at row 1, column 2
```

> **해설:**
> 1행은 배열 시작에서 16바이트 뒤(더블워드 4개짜리 한 행)에서 시작하고, 2열은 그 행에서 8바이트 뒤다. 베이스-인덱스-변위 피연산자 table[esi+edi]가 두 오프셋을 배열 주소에 더한다.

---

### **Q4.** Write instructions using CMPSW that compare two arrays of 16-bit values named sourcew and targetw.

**정답:**
```asm
mov esi,OFFSET sourcew
mov edi,OFFSET targetw
mov ecx,LENGTHOF sourcew
cld                        ; forward
repe cmpsw                 ; repeat while equal
jne notEqual               ; a pair differed (or fall through: equal)
```

> **해설:**
> REPE CMPSW는 워드 쌍이 같은 동안 비교하며, 첫 차이(ZF = 0)에서 일찍 멈추거나 모두 같으면 ECX가 0이 될 때 멈춘다.

---

### **Q5.** Write instructions that use SCASW to scan for the 16-bit value 0100h in an array named wordArray, and copy the offset of the matching member into the EAX register.

**정답:**
```asm
mov edi,OFFSET wordArray
mov ecx,LENGTHOF wordArray
mov ax,0100h
cld
repne scasw                ; scan until match or ECX = 0
jne notFound
sub edi,TYPE WORD          ; back up: EDI was one word past the match
mov eax,edi                ; EAX = offset of the matching element
notFound:
```

> **해설:**
> REPNE SCASW는 워드가 AX와 같을 때 멈춘다. EDI는 이미 일치 위치에서 2바이트 지나 있으므로 오프셋을 복사하기 전에 TYPE WORD를 뺀다.

---

### **Q6.** Write a sequence of instructions that use the Str_compare procedure to determine the larger of two input strings and write it to the console window.

**정답:**
```asm
.data
string1 BYTE "apple",0
string2 BYTE "banana",0
.code
INVOKE Str_compare, ADDR string1, ADDR string2
.IF CARRY?                     ; CF = 1 → string1 < string2
    mov edx,OFFSET string2
.ELSE
    mov edx,OFFSET string1
.ENDIF
call WriteString
call Crlf
```

> **해설:**
> Str_compare는 string1이 string2보다 작으면 Carry 플래그를 설정한다. 그 경우 다른 문자열을 골라 오프셋을 EDX에 넣고 WriteString을 호출한다.

---

### **Q7.** Show how to call the Str_trim procedure and remove all trailing "@" characters from a string.

**정답:**
```asm
.data
myString BYTE "Hello@@@",0
.code
INVOKE Str_trim, ADDR myString, '@'
```

> **해설:**
> Str_trim은 문자열 포인터와 제거할 문자를 받는다. 끝에서 뒤로 훑어 마지막 "@"가 아닌 문자 뒤에 널을 넣는다.

---

### **Q8.** Show how to modify the Str_ucase procedure from the Irvine32 library so it changes all characters to lower case.

**정답:**
```asm
Str_lcase PROC USES eax esi,
    pString:PTR BYTE
    mov esi,pString
L1: mov al,[esi]
    cmp al,0                    ; end of string?
    je  L3
    cmp al,'A'                  ; below 'A'?
    jb  L2
    cmp al,'Z'                  ; above 'Z'?
    ja  L2
    or  BYTE PTR [esi],00100000b   ; set bit 5 → lowercase
L2: inc esi
    jmp L1
L3: ret
Str_lcase ENDP
```

> **해설:**
> ASCII 대문자와 소문자는 bit 5(20h)만 다르다. 'a'..'z' 대신 'A'..'Z' 범위를 검사하고, AND로 지우는 대신 OR로 bit 5를 설정한다.

---

### **Q9.** Create a 64-bit version of the Str_trim procedure.

**정답:**
```asm
; Str_trim64: RCX = pointer to string, DL = character to remove
Str_trim PROC
    push rdi
    push rax
    mov  rdi,rcx
    call Str_length          ; Irvine64: RCX = string, returns RAX = length
    cmp  rax,0
    je   L3
    mov  rcx,rax             ; loop counter
    dec  rax
    add  rdi,rax             ; point to last character
L1: mov  al,[rdi]
    cmp  al,dl               ; delimiter?
    jne  L2
    dec  rdi
    loop L1                  ; LOOP uses RCX in 64-bit mode
L2: mov  BYTE PTR [rdi+1],0
L3: pop  rax
    pop  rdi
    ret
Str_trim ENDP
```

> **해설:**
> 논리는 32비트 버전과 같다. 32비트 레지스터를 64비트로 바꾸고, Irvine64 라이브러리 방식대로 매개변수를 레지스터(RCX, DL)로 받으며, LOOP는 RCX로 센다.

---

### **Q10.** Show an example of a base-index operand in 64-bit mode.

**정답:**
```asm
mov rax,[rbx+rsi]      ; RBX = row offset, RSI = column offset
```

> **해설:**
> 64비트 모드에서도 같은 베이스 + 인덱스 형태를 쓰며, 주소 계산에 64비트 레지스터를 사용한다.

---

### **Q11.** Assuming that EBX contains a row index into a two-dimensional array of 32-bit integers named myArray and EDI contains the index of a column, write a single statement that moves the content of the given array element into the EAX register.

**정답:**
```asm
mov eax,myArray[ebx+edi*4]
```

Here EBX must hold the row's *byte offset* (row index × RowSize, e.g. `imul ebx,RowSize` beforehand); the scale factor 4 converts the column index in EDI to a byte offset.

> **해설:**
> x86은 피연산자당 스케일 레지스터를 하나만 허용하므로 열 인덱스에 스케일 팩터(더블워드는 ×4)를 붙이고, 행은 베이스 레지스터에 미리 바이트 단위로 표현해야 한다.

---

### **Q12.** Assuming that RBX contains a row index into a two-dimensional array of 64-bit integers named myArray and RDI contains the index of a column, write a single statement that moves the content of the given array element into the RAX register.

**정답:**
```asm
mov rax,myArray[rbx+rdi*8]
```

RBX holds the row's byte offset (row index × RowSize) and the scale factor 8 matches 64-bit elements.

> **해설:**
> 32비트 경우와 같되 64비트 레지스터와 스케일 팩터 8을 쓴다. 각 원소가 쿼드워드이기 때문이다.

---
