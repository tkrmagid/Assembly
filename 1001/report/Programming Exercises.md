# Programming Exercises

### **Q1.** **Converting from Big Endian to Little Endian** — Write a program that uses the variables below and MOV instructions to copy the value from bigEndian to littleEndian, reversing the order of the bytes. The number's 32-bit value is understood to be 12345678 hexadecimal.

```asm
.data
bigEndian BYTE 12h,34h,56h,78h
littleEndian DWORD ?
```

**정답:**
```asm
.code
main PROC
    mov al,bigEndian                ; 12h (most significant byte)
    mov BYTE PTR littleEndian+3,al  ; goes to the highest byte
    mov al,[bigEndian+1]            ; 34h
    mov BYTE PTR littleEndian+2,al
    mov al,[bigEndian+2]            ; 56h
    mov BYTE PTR littleEndian+1,al
    mov al,[bigEndian+3]            ; 78h (least significant byte)
    mov BYTE PTR littleEndian,al    ; goes to the lowest byte

    mov eax,littleEndian            ; EAX = 12345678h
    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 빅 엔디언 배열에서는 최상위 바이트가 먼저 저장되므로 더블워드의 가장 높은 주소로 가야 한다. 0번 바이트를 +3, 1번 바이트를 +2로 옮기는 식으로 순서를 뒤집으면 더블워드를 읽었을 때 12345678h가 된다. littleEndian이 DWORD로 선언되었으므로 BYTE PTR이 필요하다.

---

### **Q2.** **Exchanging Pairs of Array Values** — Write a program with a loop and indexed addressing that exchanges every pair of values in an array with an even number of elements. Therefore, item i will exchange with item i+1, and item i+2 will exchange with item i+3, and so on.

**정답:**
```asm
.data
array DWORD 10,20,30,40,50,60       ; even number of elements

.code
main PROC
    mov ecx,LENGTHOF array / 2      ; one iteration per pair
    mov esi,0                       ; byte index
L1: mov eax,array[esi]                    ; first of the pair
    mov ebx,array[esi + TYPE array]       ; second of the pair
    mov array[esi],ebx
    mov array[esi + TYPE array],eax
    add esi,2 * TYPE array          ; skip to the next pair
    loop L1

    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 반복마다 원소 두 개를 처리하므로 루프 카운터는 LENGTHOF/2이고, 인덱스는 원소 크기의 두 배씩 전진한다. 4나 6 같은 상수 대신 TYPE과 LENGTHOF를 쓰면 배열 타입이나 크기가 바뀌어도 같은 코드가 동작한다. MOV 두 쌍 대신 XCHG를 쓸 수도 있다: xchg eax,array[esi+TYPE array].

---

### **Q3.** **Summing the Gaps between Array Values** — Write a program with a loop and indexed addressing that calculates the sum of all the gaps between successive array elements. The array elements are doublewords, sequenced in nondecreasing order. So, for example, the array {0, 2, 5, 9, 10} has gaps of 2, 3, 4, and 1, whose sum equals 10.

**정답:**
```asm
.data
array DWORD 0,2,5,9,10
sum   DWORD ?

.code
main PROC
    mov esi,0
    mov ecx,LENGTHOF array - 1      ; n elements → n-1 gaps
    mov eax,0                       ; running sum
L1: mov ebx,array[esi + TYPE array] ; next element
    sub ebx,array[esi]              ; gap = next - current
    add eax,ebx
    add esi,TYPE array
    loop L1

    mov sum,eax                     ; EAX = 10
    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 원소가 n개면 간격은 n−1개이므로 루프는 LENGTHOF−1번 돌아야 한다. LENGTHOF번 돌리면 배열 끝을 넘어 읽는다. 배열이 비감소 순서이므로 모든 간격이 0 이상이고, 총합은 항상 마지막 − 첫 번째와 같아서 결과를 검산하기 좋다.

---

### **Q4.** **Copying a Word Array to a DoubleWord array** — Write a program that uses a loop to copy all the elements from an unsigned Word (16-bit) array into an unsigned doubleword (32-bit) array.

**정답:**
```asm
.data
wordArray  WORD  1234h,5678h,9ABCh,0DEF0h
dwordArray DWORD LENGTHOF wordArray DUP(?)

.code
main PROC
    mov ecx,LENGTHOF wordArray
    mov esi,0                       ; index into the word array
    mov edi,0                       ; index into the doubleword array
L1: movzx eax,wordArray[esi]        ; zero-extend: unsigned data
    mov dwordArray[edi],eax
    add esi,TYPE wordArray          ; +2
    add edi,TYPE dwordArray         ; +4
    loop L1

    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 두 배열의 원소 크기가 달라 인덱스 레지스터가 두 개 필요하다. 부호 없는 값에는 MOVZX가 맞다. 상위 16비트를 0으로 채우므로 0DEF0h는 0000DEF0h가 된다. MOVSX는 같은 값을 부호 확장해 FFFFDEF0h로 만들기 때문에 여기서는 틀렸다.

---

### **Q5.** **Fibonacci Numbers** — Write a program that uses a loop to calculate the first seven values of the Fibonacci number sequence, described by the following formula: Fib(1) = 1, Fib(2) = 1, Fib(n) = Fib(n − 1) + Fib(n − 2).

**정답:**
```asm
.data
fib DWORD 7 DUP(0)

.code
main PROC
    mov fib,1                       ; Fib(1)
    mov fib+4,1                     ; Fib(2)
    mov esi,2 * TYPE fib            ; start writing at Fib(3)
    mov ecx,LENGTHOF fib - 2        ; 5 values left
L1: mov eax,fib[esi - TYPE fib]     ; Fib(n-1)
    add eax,fib[esi - 2*TYPE fib]   ; + Fib(n-2)
    mov fib[esi],eax
    add esi,TYPE fib
    loop L1
                                    ; 1,1,2,3,5,8,13
    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 처음 두 항은 주어져 있으므로 직접 저장하고 루프는 남은 다섯 개를 계산한다. 현재 인덱스에서 음의 변위를 쓰면 앞의 두 원소에 접근할 수 있다. 배열 없이 하려면 마지막 두 값을 레지스터 두 개에 두고 반복마다 교체하면 된다.

---

### **Q6.** **Reverse an Array** — Use a loop with indirect or indexed addressing to reverse the elements of an integer array in place. Do not copy the elements to any other array. Use the SIZEOF, TYPE, and LENGTHOF operators to make the program as flexible as possible if the array size and type should be changed in the future.

**정답:**
```asm
.data
array DWORD 10,20,30,40,50,60

.code
main PROC
    mov esi,OFFSET array                          ; first element
    mov edi,OFFSET array + SIZEOF array - TYPE array   ; last element
    mov ecx,LENGTHOF array / 2                    ; swap count
L1: mov eax,[esi]
    mov ebx,[edi]
    mov [esi],ebx
    mov [edi],eax
    add esi,TYPE array              ; move inward from the left
    sub edi,TYPE array              ; move inward from the right
    loop L1

    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 두 포인터가 서로를 향해 이동하며 교환하므로 LENGTHOF/2번만 반복하면 된다. 모든 원소를 돌면 각 쌍을 두 번 교환해 원래 순서로 돌아간다. 원소 개수가 홀수면 가운데 원소는 그대로 남고, 정수 나눗셈이 이를 자동으로 처리한다. SIZEOF, TYPE, LENGTHOF만 썼으므로 선언을 SWORD로 바꾸거나 원소를 추가해도 코드는 그대로다.

---

### **Q7.** **Copy a String in Reverse Order** — Write a program with a loop and indirect addressing that copies a string from source to target, reversing the character order in the process. Use the following variables:

```asm
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')
```

**정답:**
```asm
.code
main PROC
    mov esi,OFFSET source
    mov edi,OFFSET target + SIZEOF source - 2  ; last character, skipping the null
    mov ecx,SIZEOF source - 1                  ; character count without the null
L1: mov al,[esi]
    mov [edi],al
    inc esi                         ; forward through the source
    dec edi                         ; backward through the target
    loop L1

    mov target[SIZEOF source - 1],0 ; terminate the copy
    mov edx,OFFSET target
    call WriteString                ; "gnirts ecruos eht si sihT"
    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> SIZEOF source는 널 바이트까지 세므로 루프는 SIZEOF−1번 돌아야 하고 target 포인터는 SIZEOF−2에서 시작한다. 메모리 대 메모리 MOV는 허용되지 않으므로 AL을 거쳐 한 바이트씩 복사한다. 루프 뒤에 널 종료 문자를 써 주면 target을 문자열로 쓸 수 있다.

---

### **Q8.** **Shifting the Elements in an Array** — Using a loop and indexed addressing, write code that rotates the members of a 32-bit integer array forward one position. The value at the end of the array must wrap around to the first position. For example, the array [10,20,30,40] would be transformed into [40,10,20,30].

**정답:**
```asm
.data
array DWORD 10,20,30,40

.code
main PROC
    mov eax,array[SIZEOF array - TYPE array]   ; save the last value (40)
    mov esi,SIZEOF array - TYPE array          ; index of the last element
    mov ecx,LENGTHOF array - 1                 ; moves to perform
L1: mov ebx,array[esi - TYPE array]            ; take the element before it
    mov array[esi],ebx                         ; move it one position forward
    sub esi,TYPE array
    loop L1

    mov array,eax                   ; wrap the saved value around
                                    ; array = 40,10,20,30
    INVOKE ExitProcess,0
main ENDP
```

> **해설:**
> 배열 끝에서 시작해 뒤로 진행해야 한다. 앞에서부터 하면 복사하기 전에 원소를 덮어쓴다. 마지막 값을 먼저 저장해 두고 끝에 0번 위치에 넣으면 순환이 완성된다. 저장한 값은 따로 넣으므로 이동하는 원소는 LENGTHOF−1개다.

---
