# Programming Exercises

### **Q1.** **Display ASCII Decimal** — Write a procedure named WriteScaled that outputs a decimal ASCII number with an implied decimal point. With DECIMAL_OFFSET = 5 and the number below, WriteScaled would display 1001234567.89765. When calling WriteScaled, pass the number's offset in EDX, the number length in ECX, and the decimal offset in EBX. Write a test program that passes three numbers of different sizes.

```asm
DECIMAL_OFFSET = 5
.data
decimal_one BYTE "100123456789765"
```

**정답:**
```asm
INCLUDE Irvine32.inc
.data
decimal_one   BYTE "100123456789765"
decimal_two   BYTE "9876543"
decimal_three BYTE "12345"

.code
main PROC
    mov edx,OFFSET decimal_one
    mov ecx,LENGTHOF decimal_one
    mov ebx,5
    call WriteScaled                ; 1001234567.89765
    call Crlf
    mov edx,OFFSET decimal_two
    mov ecx,LENGTHOF decimal_two
    mov ebx,2
    call WriteScaled                ; 98765.43
    call Crlf
    mov edx,OFFSET decimal_three
    mov ecx,LENGTHOF decimal_three
    mov ebx,4
    call WriteScaled                ; 1.2345
    call Crlf
    exit
main ENDP

; WriteScaled: displays a digit string with an inserted decimal point
;   Receives: EDX = offset of the digits, ECX = length,
;             EBX = number of digits to the right of the point
WriteScaled PROC
    pushad
    mov esi,edx
    mov edi,ecx
    sub edi,ebx                     ; digits before the decimal point
L1: mov al,[esi]
    call WriteChar
    inc esi
    dec edi
    jnz L2                          ; not at the point yet
    mov al,'.'                      ; insert the decimal point
    call WriteChar
L2: loop L1
    popad
    ret
WriteScaled ENDP
END main
```

> **해설:**
> 소수점 오프셋은 오른쪽부터 자릿수를 세므로 소수점은 (길이 − 오프셋)개의 자릿수 뒤에 온다. 그 값으로 카운터를 초기화하고 매번 감소시키면 삽입 지점에서 정확히 0이 된다. 자릿수가 이미 ASCII이므로 변환 없이 WriteChar로 바로 출력한다.

---

### **Q2.** **Extended Subtraction Procedure** — Create a procedure named Extended_Sub that subtracts two binary integers of arbitrary size. The storage size of the two integers must be the same, and their size must be a multiple of 32 bits. Write a test program that passes several pairs of integers, each at least 10 bytes long.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
op1  DWORD 0FFFFFFFFh,0FFFFFFFFh,0FFFFFFFFh,0   ; 96+32 bits
op2  DWORD 1,0,0,0
diff DWORD 4 DUP(0)

.code
main PROC
    mov esi,OFFSET op1
    mov edi,OFFSET op2
    mov ebx,OFFSET diff
    mov ecx,LENGTHOF op1            ; number of doublewords
    call Extended_Sub
    exit
main ENDP

; Extended_Sub: diff = op1 - op2, one doubleword at a time
;   Receives: ESI = op1, EDI = op2, EBX = destination, ECX = doubleword count
Extended_Sub PROC
    pushad
    clc                             ; clear the borrow before the first unit
L1: mov eax,[esi]
    sbb eax,[edi]                   ; subtract with borrow from the last unit
    mov [ebx],eax
    lea esi,[esi+4]                 ; LEA does not disturb the Carry flag
    lea edi,[edi+4]
    lea ebx,[ebx+4]
    dec ecx                         ; DEC leaves CF alone (SUB would not)
    jnz L1
    popad
    ret
Extended_Sub ENDP
END main
```

> **해설:**
> 확장 뺄셈은 최하위 더블워드부터 시작해야 하고, 리틀 엔디언 머신에서 그것은 가장 낮은 주소이며, SBB가 빌림을 위로 전파하게 한다. 까다로운 부분은 반복 사이에 Carry 플래그를 망치지 않는 것이다. 포인터에 ADD/SUB를 쓰면 CF를 덮어쓰므로 LEA(또는 CF를 건드리지 않는 INC/DEC)를 쓰고, 루프는 DEC/JNZ로 끝낸다.

---

### **Q3.** **Packed Decimal Conversion** — Write a procedure named PackedToAsc that converts a 4-byte packed decimal integer to a string of ASCII decimal digits. Pass the packed integer and the address of a buffer holding the ASCII digits to the procedure. Write a short test program that passes at least 5 packed decimal integers to your procedure.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
packed DWORD 12345678h, 00000001h, 90000000h, 00099000h, 55555555h
buffer BYTE 9 DUP(0)                ; 8 digits + null

.code
main PROC
    mov ecx,LENGTHOF packed
    mov esi,0
L1: push ecx
    mov eax,packed[esi*4]
    mov edi,OFFSET buffer
    call PackedToAsc
    mov edx,OFFSET buffer
    call WriteString
    call Crlf
    inc esi
    pop ecx
    loop L1
    exit
main ENDP

; PackedToAsc: converts a 4-byte packed decimal to an ASCII string
;   Receives: EAX = packed integer, EDI = buffer (9 bytes)
PackedToAsc PROC
    pushad
    add edi,8                       ; write backwards from the end
    mov BYTE PTR [edi],0            ; null terminator
    mov ecx,4                       ; four bytes to unpack
L1: mov bl,al                       ; take the low byte
    and bl,0Fh                      ; low nibble = one digit
    or  bl,30h                      ; to ASCII
    dec edi
    mov [edi],bl
    mov bl,al
    shr bl,4                        ; high nibble = the next digit
    or  bl,30h
    dec edi
    mov [edi],bl
    shr eax,8                       ; next packed byte
    loop L1
    popad
    ret
PackedToAsc ENDP
END main
```

> **해설:**
> 팩 10진수는 바이트당 두 자릿수를 담으므로 각 바이트가 두 문자를 만든다. 하위 니블을 마스킹하고, 상위 니블을 시프트해 내린 뒤, 0–9 값에 30h를 OR하여 ASCII 코드로 만든다. 정수의 하위 바이트가 최하위 두 자릿수를 담으므로 숫자는 버퍼의 오른쪽 끝에서 거꾸로 써야 한다. 앞의 0은 '0' 문자로 나오며, 이를 잘라내는 것은 간단한 확장이다.

---

### **Q4.** **Encryption Using Rotate Operations** — Write a procedure that performs simple encryption by rotating each plaintext byte a varying number of positions in different directions. In the key below, a negative value indicates a rotation to the left and a positive value a rotation to the right, and the magnitude is the number of positions. Loop through the message aligning the key to each successive group of 10 bytes. Write a program that tests your procedure by calling it twice with different data sets.

```asm
key BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6
```

**정답:**
```asm
INCLUDE Irvine32.inc
KEY_LEN = 10
.data
key    BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6
msg1   BYTE "Attack at dawn on the north side",0
MSG1_LEN = ($ - msg1) - 1

.code
; Encrypt: rotates each byte by the matching key value
;   Receives: ESI = message, ECX = length
Encrypt PROC
    pushad
    mov edi,0                       ; index into the key
L1: mov al,[esi]
    mov bl,key[edi]
    cmp bl,0
    jl  RotLeft                     ; negative → rotate left
    mov cl,bl                       ; CL holds the rotation count
    ror al,cl
    jmp Store
RotLeft:
    neg bl                          ; magnitude
    mov cl,bl
    rol al,cl
Store:
    mov [esi],al
    inc esi
    inc edi
    cmp edi,KEY_LEN                 ; wrap the key every 10 bytes
    jb  Next
    mov edi,0
Next:
    dec ecx                         ; ECX is the length counter…
    jnz L1                          ; …but CL was reused above, so see the note
    popad
    ret
Encrypt ENDP

; Decrypt: identical, with the rotation directions swapped
;   (ROR becomes ROL and ROL becomes ROR)
```

> **해설:**
> 가변 회전 횟수는 CL에 있어야 하는데, ECX를 길이 카운터로 쓰는 것과 충돌한다. 코드의 주석처럼 길이는 다른 레지스터(또는 스택)에 보관해야 한다. 복호화는 같은 프로시저를 두 번 실행하는 것이 아니다. 회전은 자기 역연산이 아니므로, 복호화 버전은 각 바이트를 같은 양만큼 반대 방향으로 회전시켜야 한다. 시프트가 아니라 회전을 쓰는 것이 중요한데, 비트가 손실되지 않기 때문이다.

---

### **Q5.** **Prime Numbers** — Write a program that generates all prime numbers between 2 and 1000, using the Sieve of Eratosthenes method. Display all the prime values.

**정답:**
```asm
INCLUDE Irvine32.inc
LIMIT = 1000
.data
sieve BYTE LIMIT+1 DUP(0)           ; 0 = still prime, 1 = composite
space BYTE " ",0

.code
main PROC
    ; mark the multiples of each number, starting at 2
    mov ebx,2                       ; current base
Outer:
    mov eax,ebx
    mul ebx                         ; base * base
    cmp eax,LIMIT                   ; stop once base^2 > LIMIT
    ja  Display
    cmp sieve[ebx],1                ; already crossed out?
    je  NextBase
    mov esi,eax                     ; start marking at base^2
Inner:
    cmp esi,LIMIT
    ja  NextBase
    mov sieve[esi],1
    add esi,ebx                     ; next multiple
    jmp Inner
NextBase:
    inc ebx
    jmp Outer

Display:
    mov esi,2
L1: cmp sieve[esi],0                ; unmarked → prime
    jne L2
    mov eax,esi
    call WriteDec
    mov edx,OFFSET space
    call WriteString
L2: inc esi
    cmp esi,LIMIT
    jbe L1
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> 체는 나눗셈을 전혀 하지 않는다. 덧셈을 반복해 배수를 지우고, 살아남은 것이 소수다. 산술에서 두 가지 최적화가 나온다. 외부 루프는 base²가 한계를 넘으면 멈출 수 있고(합성수는 제곱근 이하의 약수를 가진다), 내부 루프는 base²에서 시작할 수 있다(더 작은 배수는 더 작은 base가 이미 지웠다). 인덱스 1000이 존재하도록 배열은 LIMIT+1 바이트가 필요하다.

---

### **Q6.** **Greatest Common Divisor (GCD)** — Implement the following function in assembly language and write a test program that calls it several times, passing different values. Display all results on the screen.

```asm
int GCD(int x, int y)
{
  x = abs(x)          // absolute value
  y = abs(y)
  do {
    int n = x % y
    x = y
    y = n
  } while (y > 0)
  return x
}
```

**정답:**
```asm
INCLUDE Irvine32.inc
.data
pairs DWORD 5,20, 24,18, 11,7, -432,226, 26,13
space BYTE "  ",0

.code
main PROC
    mov esi,0
    mov ecx,LENGTHOF pairs / 2
L1: push ecx
    mov eax,pairs[esi*4]            ; x
    mov ebx,pairs[esi*4+4]          ; y
    call GCD
    call WriteDec
    mov edx,OFFSET space
    call WriteString
    add esi,2
    pop ecx
    loop L1
    call Crlf
    exit
main ENDP

; GCD: Euclid's algorithm
;   Receives: EAX = x, EBX = y
;   Returns:  EAX = gcd(|x|,|y|)
GCD PROC
    push edx
    push ebx
    or  eax,eax                     ; x = abs(x)
    jns L1
    neg eax
L1: or  ebx,ebx                     ; y = abs(y)
    jns L2
    neg ebx
L2: mov edx,0                       ; clear the high half of the dividend
    div ebx                         ; EDX = x MOD y
    mov eax,ebx                     ; x = y
    mov ebx,edx                     ; y = n
    or  ebx,ebx                     ; while (y > 0)
    jnz L2
    pop ebx
    pop edx
    ret
GCD ENDP
END main
```

> **해설:**
> 부호 없는 DIV의 나머지는 EDX에 들어가는데, 이것이 알고리즘이 필요한 "x % y"다. 그래서 루프 본문은 DIV와 레지스터 이동 두 개 정도다. 매 DIV 전에 EDX를 지워야 한다. EDX는 피제수의 상위 절반이므로 이전 나머지를 남겨 두면 결과가 틀린다. 먼저 절댓값을 취하면 부호 없는 나눗셈을 안전하게 쓸 수 있고, 부호 있는 IDIV 버전이라면 CDQ가 필요하다.

---

### **Q7.** **Bitwise Multiplication** — Write a procedure named BitwiseMultiply that multiplies any unsigned 32-bit integer by EAX, using only shifting and addition. Pass the integer to the procedure in the EBX register and return the product in EAX (assume the product is never larger than 32 bits). Write a short test program that calls the procedure and displays the product.

**정답:**
```asm
INCLUDE Irvine32.inc
.code
main PROC
    mov eax,213                     ; multiplicand
    mov ebx,15                      ; multiplier
    call BitwiseMultiply            ; 213 * 15 = 3195
    call WriteDec
    call Crlf
    exit
main ENDP

; BitwiseMultiply: EAX = EAX * EBX using shifts and adds only
;   Receives: EAX = multiplicand, EBX = multiplier
;   Returns:  EAX = product
BitwiseMultiply PROC
    push ecx
    push edx
    push esi
    mov esi,eax                     ; ESI = running multiplicand
    mov eax,0                       ; EAX = accumulating product
    mov ecx,32                      ; examine 32 bits of the multiplier
L1: shr ebx,1                       ; move the lowest bit into CF
    jnc L2                          ; bit = 0: nothing to add
    add eax,esi                     ; bit = 1: add this power-of-two multiple
L2: shl esi,1                       ; multiplicand *= 2 for the next bit
    or  ebx,ebx                     ; any 1 bits left?
    jz  L3
    loop L1
L3: pop esi
    pop edx
    pop ecx
    ret
BitwiseMultiply ENDP
END main
```

> **해설:**
> 이것은 2진 필산 곱셈이다. 곱하는 수의 1 비트마다 해당 자리만큼 시프트한 피승수를 더한다. SHR이 검사하는 비트를 Carry 플래그로 떨어뜨려 주므로 JNC로 더할지 결정하고, 매 회 피승수를 두 배로 만들어 시프트된 값을 공급한다. 곱하는 수가 0이 되면 바로 멈춰 남은 무의미한 반복을 피한다.

---

### **Q8.** **Add Packed Integers** — Extend the AddPacked procedure from Section 7.6.1 so that it adds two packed decimal integers of arbitrary size (both lengths must be the same). Write a test program that passes AddPacked several pairs of integers: 4-byte, 8-byte, and 16-byte. Suggested registers: ESI = pointer to the first number, EDI = pointer to the second, EDX = pointer to the sum, ECX = number of bytes to add.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
packed_1 BYTE 34h,12h,00h,00h       ; 1234 (little-endian packed BCD)
packed_2 BYTE 21h,43h,00h,00h       ; 4321
sum      BYTE 4 DUP(0)              ; 5555

.code
main PROC
    mov esi,OFFSET packed_1
    mov edi,OFFSET packed_2
    mov edx,OFFSET sum
    mov ecx,LENGTHOF packed_1
    call AddPacked
    exit
main ENDP

; AddPacked: adds two packed decimal integers of arbitrary length
;   Receives: ESI, EDI = the operands, EDX = the sum, ECX = byte count
AddPacked PROC
    pushad
    clc                             ; no carry into the first byte
L1: mov al,[esi]
    adc al,[edi]                    ; add with carry from the previous byte
    daa                             ; decimal adjust: keeps both nibbles 0-9
    mov [edx],al                    ; DAA sets CF for the next byte
    inc esi                         ; INC does not touch the Carry flag
    inc edi
    inc edx
    dec ecx
    jnz L1
    popad
    ret
AddPacked ENDP
END main
```

> **해설:**
> 각 바이트가 10진 두 자리를 담으므로 ADC만으로는 니블에 0Ah 같은 잘못된 값이 남을 수 있다. DAA가 그 바이트를 팩 10진 형태로 보정하고, 중요하게는 다음 바이트를 위한 Carry 플래그를 설정한다. 이것이 연쇄를 가능하게 한다. 확장 2진 덧셈처럼 루프는 최하위 바이트부터 위로 진행해야 하고 반복 사이에 CF를 건드리면 안 되므로 ADD와 LOOP 대신 INC와 DEC/JNZ를 쓴다.

---
