# Programming Exercises

### **Q1.** **Draw Text Colors** — Write a program that displays the same string in four different colors, using a loop. Call the SetTextColor procedure from the book's link library. Any colors may be chosen, but you may find it easiest to change the foreground color.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
msg BYTE "Assembly language is fun!",0dh,0ah,0

.code
main PROC
    mov ecx,4                       ; four colors
    mov ebx,white                   ; first foreground color (15)
L1: push ecx                        ; keep the loop counter safe across calls
    mov eax,ebx                     ; EAX = (background * 16) + foreground
    call SetTextColor
    mov edx,OFFSET msg
    call WriteString
    dec ebx                         ; next color: yellow, magenta, red...
    pop ecx
    loop L1

    mov eax,lightGray               ; restore a normal color
    call SetTextColor
    exit
main ENDP
END main
```

> **해설:**
> SetTextColor는 EAX로 (배경색 × 16) + 전경색 속성을 받으므로 배경을 0(검정)으로 두면 EAX가 곧 전경색 번호다. 색상 상수(black, blue … white = 0…15)는 Irvine32.inc에 정의되어 있다. 라이브러리 호출을 건너 루프 카운터를 스택에 보관하는 것은 안전한 습관이고, 프로그램이 끝나기 전에 색을 되돌리면 콘솔이 정상 상태로 남는다.

---

### **Q2.** **Linking Array Items** — You are given three data items: a starting index in a list, an array of characters, and an array of link indexes. Write a program that traverses the links and locates the characters in their correct sequence, copying each one to a new array. With start = 1, chars = HACEBDFG and links = 04562370 (zero-based indexes), the values copied in order would be A,B,C,D,E,F,G,H. Declare the character array as type BYTE and the links array as type DWORD.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
start  DWORD 1
chars  BYTE  "HACEBDFG"
links  DWORD 0,4,5,6,2,3,7,0
output BYTE  LENGTHOF chars DUP(0),0

.code
main PROC
    mov esi,start                   ; current index
    mov edi,0                       ; position in the output array
    mov ecx,LENGTHOF chars
L1: mov al,chars[esi]               ; scale 1: BYTE array
    mov output[edi],al
    mov esi,links[esi*4]            ; follow the link (DWORD array)
    inc edi
    loop L1

    mov edx,OFFSET output
    call WriteString                ; ABCDEFGH
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> 원소 크기가 다른 두 배열에 같은 인덱스 레지스터를 쓴다. chars[esi]는 바이트라 스케일이 필요 없고, links[esi*4]는 더블워드이므로 스케일 팩터 4를 쓴다. 반복마다 문자 하나를 내보내고 인덱스를 링크 값으로 바꾸므로 루프는 원소 개수만큼만 돌면 된다. 링크 0이 정상 인덱스로도 나타나므로 종료 표시를 기다리기보다 개수 기반 루프가 안전하다.

---

### **Q3.** **Simple Addition (1)** — Write a program that clears the screen, locates the cursor near the middle of the screen, prompts the user for two integers, adds the integers, and displays their sum.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
prompt1 BYTE "Enter the first number: ",0
prompt2 BYTE "Enter the second number: ",0
result  BYTE "The sum is: ",0

.code
main PROC
    call Clrscr
    mov dl,20                       ; column
    mov dh,10                       ; row
    call Gotoxy

    mov edx,OFFSET prompt1
    call WriteString
    call ReadInt                    ; EAX = first integer
    mov ebx,eax

    mov dl,20
    mov dh,11
    call Gotoxy
    mov edx,OFFSET prompt2
    call WriteString
    call ReadInt                    ; EAX = second integer
    add eax,ebx

    mov dl,20
    mov dh,13
    call Gotoxy
    mov edx,OFFSET result
    call WriteString
    call WriteInt                   ; display the signed sum
    call Crlf
    exit
main ENDP
END main
```

> **해설:**
> Gotoxy는 DL에 열, DH에 행을 받고, ReadInt는 부호 있는 정수를 EAX로 반환한다(입력이 잘못되면 Overflow 플래그도 설정한다). ReadInt가 EAX를 덮어쓰므로 두 번째 호출 전에 첫 값을 다른 곳으로 옮겨야 한다.

---

### **Q4.** **Simple Addition (2)** — Use the solution program from the preceding exercise as a starting point. Let this new program repeat the same steps three times, using a loop. Clear the screen after each loop iteration.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
prompt1 BYTE "Enter the first number: ",0
prompt2 BYTE "Enter the second number: ",0
result  BYTE "The sum is: ",0
pause   BYTE "Press Enter to continue...",0

.code
main PROC
    mov ecx,3                       ; three repetitions
L1: push ecx                        ; keep the loop counter safe across calls
    call AskAndAdd
    pop ecx
    loop L1
    exit
main ENDP

AskAndAdd PROC
    call Clrscr
    mov dl,20
    mov dh,10
    call Gotoxy
    mov edx,OFFSET prompt1
    call WriteString
    call ReadInt
    mov ebx,eax
    mov edx,OFFSET prompt2
    call WriteString
    call ReadInt
    add eax,ebx
    call Crlf
    mov edx,OFFSET result
    call WriteString
    call WriteInt
    call Crlf
    mov edx,OFFSET pause            ; let the user read the result
    call WriteString
    call ReadChar                   ; before the screen is cleared
    ret
AskAndAdd ENDP
END main
```

> **해설:**
> 본문을 프로시저로 빼면 루프가 읽기 쉬워지고, 이는 이 장이 권하는 방식이다. 호출 전후로 ECX를 푸시/팝하면 중첩 프로시저와 그 안의 라이브러리 호출이 루프 카운터를 건드릴 수 없다. 다음 Clrscr 전에 멈추는 것도 중요하다. 그러지 않으면 마지막 결과가 보이기 전에 지워진다.

---

### **Q5.** **BetterRandomRange Procedure** — The RandomRange procedure generates a pseudorandom integer between 0 and N − 1. Create an improved version that generates an integer between M and N − 1. Let the caller pass M in EBX and N in EAX. Write a short test program that calls BetterRandomRange from a loop that repeats 50 times, displaying each value. Sample call:

```asm
mov ebx,-300      ; lower bound
mov eax,100       ; upper bound
call BetterRandomRange
```

**정답:**
```asm
INCLUDE Irvine32.inc
.code
main PROC
    call Randomize                  ; new seed on each run
    mov ecx,50
L1: push ecx
    mov ebx,-300                    ; M
    mov eax,100                     ; N
    call BetterRandomRange
    call WriteInt
    call Crlf
    pop ecx
    loop L1
    exit
main ENDP

; BetterRandomRange: returns a random integer in M .. N-1
;   Receives: EBX = M (lower bound), EAX = N (upper bound)
;   Returns:  EAX = random value
BetterRandomRange PROC
    sub eax,ebx                     ; span = N - M
    call RandomRange                ; EAX = 0 .. span-1
    add eax,ebx                     ; shift into M .. N-1
    ret
BetterRandomRange ENDP
END main
```

> **해설:**
> RandomRange는 0부터 시작하는 값만 만들므로, 구간의 크기(N − M)를 요청한 뒤 하한을 더하는 것이 핵심이다. 결과는 M부터 N − 1까지이며 원래와 같은 개수의 값을 갖는다. 프로그램 시작 시 Randomize를 한 번 호출하지 않으면 매 실행마다 같은 수열이 나온다.

---

### **Q6.** **Random Strings** — Create a procedure that generates a random string of length L, containing all capital letters. When calling the procedure, pass the value of L in EAX, and pass a pointer to an array of bytes that will hold the random string. Write a test program that calls your procedure 20 times and displays the strings in the console window.

**정답:**
```asm
INCLUDE Irvine32.inc
STR_LEN = 10
.data
buffer BYTE STR_LEN+1 DUP(0)        ; room for the null terminator

.code
main PROC
    call Randomize
    mov ecx,20
L1: push ecx
    mov eax,STR_LEN
    mov esi,OFFSET buffer
    call RandomString
    mov edx,OFFSET buffer
    call WriteString
    call Crlf
    pop ecx
    loop L1
    exit
main ENDP

; RandomString: fills a buffer with L random capital letters
;   Receives: EAX = L, ESI = pointer to the buffer
RandomString PROC
    push ecx
    push esi
    mov ecx,eax                     ; loop counter = L
L1: mov eax,26                      ; 26 letters
    call RandomRange                ; EAX = 0 .. 25
    add al,'A'                      ; 'A' .. 'Z'
    mov [esi],al
    inc esi
    loop L1
    mov BYTE PTR [esi],0            ; terminate the string
    pop esi
    pop ecx
    ret
RandomString ENDP
END main
```

> **해설:**
> EAX = 26으로 RandomRange를 호출하면 0–25가 나오고, 여기에 'A'의 문자 코드를 더하면 대문자로 대응된다. 널 종료 문자가 들어가야 하므로 버퍼는 L보다 한 바이트 커야 하고, 프로시저는 자신이 쓰는 레지스터를 저장해 호출자의 루프 카운터를 지킨다.

---

### **Q7.** **Random Screen Locations** — Write a program that displays a single character at 100 random screen locations, using a timing delay of 100 milliseconds. Hint: Use the GetMaxXY procedure to determine the current size of the console window.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
maxX BYTE ?
maxY BYTE ?

.code
main PROC
    call Randomize
    call Clrscr
    call GetMaxXY                   ; DL = columns, DH = rows
    mov maxX,dl
    mov maxY,dh

    mov ecx,100
L1: push ecx
    movzx eax,maxX                  ; random column 0 .. maxX-1
    call RandomRange
    mov bl,al                       ; keep it: RandomRange uses EAX
    movzx eax,maxY                  ; random row 0 .. maxY-1
    call RandomRange
    mov dh,al
    mov dl,bl
    call Gotoxy
    mov al,'*'
    call WriteChar
    mov eax,100                     ; 100 ms delay
    call Delay
    pop ecx
    loop L1
    exit
main ENDP
END main
```

> **해설:**
> GetMaxXY는 창 크기를 DL, DH로 반환하므로 RandomRange 호출 전에 EAX로 0 확장해야 한다. RandomRange가 EAX로 값을 반환하므로 두 번째 호출 전에 첫 좌표를 다른 레지스터에 옮겨 두어야 한다. Delay는 EAX로 밀리초를 받는다.

---

### **Q8.** **Color Matrix** — Write a program that displays a single character in all possible combinations of foreground and background colors (16 × 16 = 256). The colors are numbered from 0 to 15, so you can use a nested loop to generate all possible combinations.

**정답:**
```asm
INCLUDE Irvine32.inc
.code
main PROC
    call Clrscr
    mov ecx,16                      ; outer loop: background
    mov bh,0                        ; background number
L1: push ecx
    mov ecx,16                      ; inner loop: foreground
    mov bl,0                        ; foreground number
L2: movzx eax,bh
    shl eax,4                       ; background * 16
    or  al,bl                       ; + foreground
    call SetTextColor
    mov al,'X'
    call WriteChar
    inc bl
    loop L2
    call Crlf                       ; one row per background color
    pop ecx
    inc bh
    loop L1

    mov eax,lightGray
    call SetTextColor
    exit
main ENDP
END main
```

> **해설:**
> 속성 바이트는 배경색을 bit 4–7, 전경색을 bit 0–3에 담으므로 배경색을 왼쪽으로 4비트 밀고 전경색을 OR하면 256가지 값이 모두 만들어진다. 내부 루프가 ECX를 다시 쓰므로 외부 카운터는 미리 푸시해야 한다. 배경색마다 한 행씩 출력하면 결과를 보기 쉽다. 전경색과 배경색이 같은 16개 칸은 보이지 않는다.

---

### **Q9.** **Recursive Procedure** — Write a program that calls a recursive procedure. Inside this procedure, add 1 to a counter so you can verify the number of times it executes. Put a number in ECX that specifies the number of times you want to allow the recursion to continue. Using only the LOOP instruction (and no other conditional statements from later chapters), find a way for the recursive procedure to call itself a fixed number of times. Run your program with a debugger and check the counter's value at the end.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
counter DWORD 0

.code
main PROC
    mov ecx,5                       ; allow 5 levels of recursion
    call Rec1
    mov eax,counter                 ; inspect this in the debugger: 5
    exit
main ENDP

; Rec1: calls itself while ECX > 0
Rec1 PROC
    inc counter                     ; count this activation
    loop Rec1                       ; decrement ECX; if not zero, call again
                                    ; (LOOP jumps to the procedure label,
                                    ;  which re-enters the procedure body)
    ret
Rec1 ENDP
END main
```

> **해설:**
> LOOP는 ECX를 감소시키고 0이 아닐 때 점프하므로, CMP나 조건 점프 없이 종료 조건 역할을 할 수 있다. 스택 동작을 보자: 각 진입이 추가로 푸시하는 것은 없고 마지막 RET만 실행되므로, 사실상 프로시저 모양을 한 루프다. 진짜 재귀라면 RET 앞에서 CALL Rec1을 해서 단계마다 반환 주소를 푸시하며, 그래서 제한 없는 재귀는 스택을 소진한다.

---

### **Q10.** **Fibonacci Generator** — Write a procedure that produces N values in the Fibonacci number series and stores them in an array of doublewords. Input parameters should be a pointer to an array of doublewords and a counter of the number of values to generate. Write a test program that calls your procedure, passing N = 47. The first value in the array will be 1, and the last value will be 2,971,215,073. Use the debugger to inspect the array contents.

**정답:**
```asm
INCLUDE Irvine32.inc
COUNT = 47
.data
fibArray DWORD COUNT DUP(?)

.code
main PROC
    mov esi,OFFSET fibArray
    mov ecx,COUNT
    call Fibonacci                  ; inspect fibArray in the debugger
    exit
main ENDP

; Fibonacci: stores ECX values of the Fibonacci series
;   Receives: ESI = pointer to a DWORD array, ECX = count
Fibonacci PROC
    push esi
    push ecx
    push eax
    push ebx
    mov eax,1                       ; current value  Fib(n)
    mov ebx,0                       ; previous value Fib(n-1)
L1: mov [esi],eax                   ; store Fib(n)
    add eax,ebx                     ; Fib(n+1) = Fib(n) + Fib(n-1)
    mov ebx,[esi]                   ; previous becomes the value just stored
    add esi,TYPE DWORD
    loop L1
    pop ebx
    pop eax
    pop ecx
    pop esi
    ret
Fibonacci ENDP
END main
```

> **해설:**
> 가장 최근 두 항만 필요하므로 레지스터 두 개로 충분하고, 배열을 거꾸로 인덱싱할 필요가 없다. N = 47은 부호 없는 더블워드의 실질적 한계다. Fib(47) = 2,971,215,073은 32비트에 들어가지만 Fib(48)은 넘친다. 프로시저는 수정하는 모든 레지스터를 저장해 호출자에게 부작용을 남기지 않는다.

---

### **Q11.** **Finding Multiples of K** — In a byte array of size N, write a procedure that finds all multiples of K that are less than N. Initialize the array to all zeros at the beginning of the program, and then whenever a multiple is found, set the corresponding array element to 1. Your procedure must save and restore any registers it modifies. Call your procedure twice, with K = 2 and again with K = 3. Let N equal 50. Run your program in the debugger and verify that the array values were set correctly.

**정답:**
```asm
INCLUDE Irvine32.inc
ARRAY_SIZE = 50
.data
sieve BYTE ARRAY_SIZE DUP(0)        ; already all zeros

.code
main PROC
    mov esi,OFFSET sieve
    mov ecx,ARRAY_SIZE              ; N
    mov ebx,2                       ; K = 2
    call MarkMultiples
    mov ebx,3                       ; K = 3
    call MarkMultiples
                                    ; inspect sieve in the debugger:
                                    ; positions 2,3,4,6,8,9,... = 1
    exit
main ENDP

; MarkMultiples: sets array[i] = 1 for every multiple of K below N
;   Receives: ESI = array pointer, ECX = N, EBX = K
MarkMultiples PROC
    pushad                          ; save all general-purpose registers
    mov edi,ebx                     ; current multiple = K
L1: cmp edi,ecx                     ; still below N?
    jae L2
    mov BYTE PTR [esi+edi],1        ; mark it
    add edi,ebx                     ; next multiple
    jmp L1
L2: popad
    ret
MarkMultiples ENDP
END main
```

> **해설:**
> K씩(2, 4, 6, …) 전진하면 나눗셈 없이 배수를 바로 표시할 수 있다. 인덱스를 바이트 오프셋으로 쓰므로 [esi+edi]에 스케일 팩터가 필요 없다. PUSHAD/POPAD는 "저장하고 복원" 요구를 만족시키는 가장 빠른 방법이지만, 실제로 쓰는 레지스터만 푸시하는 편이 더 깔끔하다. 이것이 에라토스테네스의 체의 표시 단계이며 9장에서 다시 다룬다. 표시되지 않은 위치가 소수다.

---
