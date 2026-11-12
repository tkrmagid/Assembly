# Programming Exercises

### **Q1.** **Improved Str_copy Procedure** — The Str_copy procedure shown in this chapter does not limit the number of characters to be copied. Create a new version (named Str_copyN) that receives an additional input parameter indicating the maximum number of characters to be copied.

**정답:**
```asm
INCLUDE Irvine32.inc
Str_copyN PROTO, source:PTR BYTE, target:PTR BYTE, maxChars:DWORD

.data
str1   BYTE "This string is rather long",0
buffer BYTE 11 DUP(0)               ; 10 characters + null

.code
main PROC
    INVOKE Str_copyN, ADDR str1, ADDR buffer, 10
    mov edx,OFFSET buffer
    call WriteString                ; "This strin"
    call Crlf
    exit
main ENDP

Str_copyN PROC USES eax ecx esi edi,
    source:PTR BYTE, target:PTR BYTE, maxChars:DWORD
    mov esi,source
    mov edi,target
    mov ecx,maxChars
    cmp ecx,0                       ; nothing to copy?
    je  L2
L1: mov al,[esi]
    mov [edi],al
    cmp al,0                        ; was that the null terminator?
    je  L3                          ; then the string ended early
    inc esi
    inc edi
    loop L1
L2: mov BYTE PTR [edi],0            ; hit the limit: terminate here
L3: ret
Str_copyN ENDP
END main
```

> **해설:**
> 루프의 종료 경로가 둘이고 둘 다 처리해야 한다. 원본 문자열이 한계보다 먼저 끝날 수 있고(널이 이미 복사되었으므로 더 할 일이 없다), 한계에 먼저 도달할 수도 있다(종료 문자를 직접 써야 하며, 그러지 않으면 target이 올바른 문자열이 아니다). ECX = 0으로 LOOP를 시작하면 42억 번 넘게 도므로 0 한계는 미리 검사해야 한다.

---

### **Q2.** **Str_concat Procedure** — Write a procedure named Str_concat that concatenates a source string to the end of a target string. Sufficient space must exist in the target string to accommodate the new characters. Pass pointers to the source and target strings. Here is a sample call:

```asm
.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0
.code
INVOKE Str_concat, ADDR targetStr, ADDR sourceStr
```

**정답:**
```asm
INCLUDE Irvine32.inc
Str_concat PROTO, target:PTR BYTE, source:PTR BYTE

.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0

.code
main PROC
    INVOKE Str_concat, ADDR targetStr, ADDR sourceStr
    mov edx,OFFSET targetStr
    call WriteString                ; ABCDEFGH
    call Crlf
    exit
main ENDP

Str_concat PROC USES eax ecx esi edi,
    target:PTR BYTE, source:PTR BYTE
    INVOKE Str_length, target       ; EAX = current length of the target
    mov edi,target
    add edi,eax                     ; point at the target's null byte
    mov esi,source
    cld                             ; forward direction
L1: lodsb                           ; AL = [ESI], ESI++
    stosb                           ; [EDI] = AL, EDI++
    cmp al,0                        ; the null is copied too, ending the string
    jne L1
    ret
Str_concat ENDP
END main
```

> **해설:**
> 연결은 대상의 널 바이트를 찾는 것에서 시작하며, 그것이 바로 Str_length가 주는 값이다. 그 지점부터 복사한다. 루프가 널 종료 문자까지 복사하게 두면 별도 저장 없이 결과가 올바르게 종료된다. LODSB는 ESI로 읽고 STOSB는 EDI로 쓰므로 여기서 자연스럽게 짝을 이루며, 진입 시 Direction 플래그 상태를 알 수 없으므로 CLD를 실행해야 한다.

---

### **Q3.** **Str_remove Procedure** — Write a procedure named Str_remove that removes n characters from a string. Pass a pointer to the position in the string where the characters are to be removed, and an integer specifying the number of characters to remove. The following code, for example, removes "xxxx" from target:

```asm
.data
target BYTE "abcxxxxdefghijklmop",0
.code
INVOKE Str_remove, ADDR [target+3], 4
```

**정답:**
```asm
INCLUDE Irvine32.inc
Str_remove PROTO, pString:PTR BYTE, nChars:DWORD

.data
target BYTE "abcxxxxdefghijklmop",0

.code
main PROC
    INVOKE Str_remove, ADDR [target+3], 4
    mov edx,OFFSET target
    call WriteString                ; abcdefghijklmop
    call Crlf
    exit
main ENDP

Str_remove PROC USES eax ecx esi edi,
    pString:PTR BYTE, nChars:DWORD
    mov edi,pString                 ; where the gap begins
    mov esi,edi
    add esi,nChars                  ; the first character to keep
    INVOKE Str_length, esi
    mov ecx,eax
    inc ecx                         ; copy the null terminator too
    cld
    rep movsb                       ; shift the tail left over the gap
    ret
Str_remove ENDP
END main
```

> **해설:**
> 문자 제거는 뒤따르는 모든 것을 왼쪽으로 옮기는 일이다. 꼬리를 position + n에서 position으로 복사한다. 개수에 널 종료 문자를 포함해야 한다. 그러지 않으면 짧아진 문자열이 뒤쪽의 옛 종료 표시를 그대로 갖는다. 영역이 겹치더라도 목적지가 원본보다 낮은 주소이므로 앞으로 복사하는 것이 안전하다. MOVSB는 덮어쓰기 전에 항상 그 바이트를 먼저 읽는다.

---

### **Q4.** **Str_find Procedure** — Write a procedure named Str_find that searches for the first matching occurrence of a source string inside a target string and returns the matching position. The input parameters are a pointer to the source string and a pointer to the target string. If a match is found, the procedure sets the Zero flag and EAX points to the matching position in the target string; otherwise the Zero flag is clear and EAX is undefined.

```asm
.data
target BYTE "123ABC342432",0
source BYTE "ABC",0
pos DWORD ?
.code
INVOKE Str_find, ADDR source, ADDR target
jnz notFound
mov pos,eax       ; store the position value
```

**정답:**
```asm
INCLUDE Irvine32.inc
Str_find PROTO, pSource:PTR BYTE, pTarget:PTR BYTE

.data
target BYTE "123ABC342432",0
source BYTE "ABC",0
pos    DWORD ?

.code
main PROC
    INVOKE Str_find, ADDR source, ADDR target
    jnz notFound
    mov pos,eax
    mov edx,eax
    call WriteString                ; ABC342432
    call Crlf
notFound:
    exit
main ENDP

Str_find PROC USES ebx ecx edx esi edi,
    pSource:PTR BYTE, pTarget:PTR BYTE
    INVOKE Str_length, pSource
    mov ebx,eax                     ; length of the pattern
    INVOKE Str_length, pTarget
    mov ecx,eax
    sub ecx,ebx                     ; last possible starting position
    inc ecx                         ; number of positions to try
    jle NotFound                    ; pattern longer than the target
    mov edx,pTarget                 ; current starting position
L1: mov esi,pSource
    mov edi,edx
    push ecx
    mov ecx,ebx                     ; compare the whole pattern
    cld
    repe cmpsb
    pop ecx
    je  Found                       ; every byte matched
    inc edx                         ; slide one position right
    loop L1
NotFound:
    or  ebx,ebx                     ; force ZF = 0 (EBX is never 0 here)
    ret
Found:
    mov eax,edx                     ; ZF is still set from REPE CMPSB
    ret
Str_find ENDP
END main
```

> **해설:**
> 전형적인 2단 탐색이다. 가능한 모든 시작 위치를 도는 외부 루프와, 그 자리에서 패턴을 비교하는 내부 REPE CMPSB. 시도할 위치는 (대상 길이 − 원본 길이 + 1)개뿐이고, 패턴이 대상보다 길면 개수가 음수가 되기 전에 걸러야 한다. 까다로운 부분은 플래그 규약이다. 호출자가 ZF를 검사하므로 성공 경로는 ZF를 설정된 상태로 두어야 하고(REPE CMPSB가 이미 그렇게 한다) 실패 경로는 의도적으로 지워야 한다. 그래서 내부 비교 전후로 ECX를 저장한다.

---

### **Q5.** **Str_nextWord Procedure** — Write a procedure called Str_nextWord that scans a string for the first occurrence of a certain delimiter character and replaces the delimiter with a null byte. There are two input parameters: a pointer to the string and the delimiter character. After the call, if the delimiter was found, the Zero flag is set and EAX contains the offset of the next character beyond the delimiter; otherwise the Zero flag is clear and EAX is undefined.

```asm
.data
target BYTE "Johnson,Calvin",0
.code
INVOKE Str_nextWord, ADDR target, ','
jnz notFound
```

**정답:**
```asm
INCLUDE Irvine32.inc
Str_nextWord PROTO, pString:PTR BYTE, delim:BYTE

.data
target BYTE "Johnson,Calvin",0

.code
main PROC
    INVOKE Str_nextWord, ADDR target, ','
    jnz notFound
    mov edx,eax
    call WriteString                ; Calvin  (the second word)
    call Crlf
    mov edx,OFFSET target
    call WriteString                ; Johnson (now null-terminated)
    call Crlf
notFound:
    exit
main ENDP

Str_nextWord PROC USES ecx esi,
    pString:PTR BYTE, delim:BYTE
    mov esi,pString
    mov cl,delim
L1: mov al,[esi]
    cmp al,0                        ; end of string?
    je  NotFound
    cmp al,cl                       ; the delimiter?
    je  Found
    inc esi
    jmp L1
NotFound:
    or  esi,esi                     ; clear ZF (ESI is never zero)
    ret
Found:
    mov BYTE PTR [esi],0            ; split the string here
    inc esi
    mov eax,esi                     ; offset of the next word
    cmp eax,eax                     ; set ZF
    ret
Str_nextWord ENDP
END main
```

> **해설:**
> 구분 문자를 널로 바꾸면 첫 단어가 끝나면서 버퍼의 나머지는 그대로 남아, 한 버퍼가 두 문자열을 담게 된다. 쉼표로 구분된 필드 한 줄을 제자리에서 쪼개는 방식이 이것이다. 탐색은 구분 문자뿐 아니라 문자열 자신의 널 바이트에서도 멈춰야 한다. 그러지 않으면 끝을 넘어간다. 반환 플래그가 인터페이스의 일부이므로 두 종료 경로 모두 ZF를 명시적으로 설정한다(설정에는 CMP EAX,EAX, 해제에는 OR).

---

### **Q6.** **Constructing a Frequency Table** — Write a procedure named Get_frequencies that constructs a character frequency table. Input is a pointer to a string and a pointer to an array of 256 doublewords initialized to all zeros. Each array position is indexed by its corresponding ASCII code; when the procedure returns, each entry contains a count of how many times that character occurred in the string.

```asm
.data
target BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
.code
INVOKE Get_frequencies, ADDR target, ADDR freqTable
```

**정답:**
```asm
INCLUDE Irvine32.inc
Get_frequencies PROTO, pString:PTR BYTE, pTable:PTR DWORD

.data
target    BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)

.code
main PROC
    INVOKE Get_frequencies, ADDR target, ADDR freqTable
    mov eax,freqTable + 41h*4       ; 'A' occurred 2 times
    mov eax,freqTable + 42h*4       ; 'B' occurred 3 times
    exit
main ENDP

Get_frequencies PROC USES eax ebx esi edi,
    pString:PTR BYTE, pTable:PTR DWORD
    mov esi,pString
    mov edi,pTable
    mov ebx,0                       ; EBX will hold the ASCII code
L1: mov al,[esi]
    cmp al,0                        ; end of the string?
    je  L2
    movzx ebx,al                    ; the character is the index
    inc DWORD PTR [edi+ebx*4]       ; scale 4: doubleword entries
    inc esi
    jmp L1
L2: ret
Get_frequencies ENDP
END main
```

> **해설:**
> 문자 자신의 코드가 배열 인덱스이므로 탐색이 필요 없다. 문자당 INC 한 번으로 한 번의 순회에 테이블 전체가 만들어진다. MOVZX가 필수다. 인덱스 레지스터는 32비트 전체여야 하고 상위 비트가 0이어야 한다. 최상위 비트가 1인 바이트(확장 ASCII 코드)라면 테이블 밖을 한참 벗어나 인덱싱하게 된다. 스케일 팩터 4는 더블워드 항목을 위한 것이다. 이런 형태의 빈도 테이블이 허프만 인코딩의 첫 단계다.

---

### **Q7.** **Sieve of Eratosthenes** — The Sieve of Eratosthenes provides a quick way to find all prime numbers within a given range: beginning with position 2, insert a 1 in each array position that is a multiple of 2, then do the same for 3, then 5, and so on. The remaining unmarked positions indicate which numbers are prime. For this program, create a 65,000-element array and display all primes between 2 and 65,000. Declare the array in an uninitialized data segment (see Section 3.4.11) and use STOSB to fill it with zeros.

**정답:**
```asm
INCLUDE Irvine32.inc
LIMIT = 65000
.data?
sieve BYTE LIMIT+1 DUP(?)           ; uninitialized segment: no file space used
.data
space BYTE " ",0

.code
main PROC
    mov edi,OFFSET sieve            ; clear the array with STOSB
    mov ecx,LIMIT+1
    mov al,0
    cld
    rep stosb

    mov ebx,2                       ; mark the multiples of each base
Outer:
    mov eax,ebx
    mul ebx                         ; base * base
    cmp eax,LIMIT
    ja  Display                     ; done once base^2 > LIMIT
    cmp sieve[ebx],1
    je  NextBase                    ; base is already composite
    mov esi,eax
Inner:
    cmp esi,LIMIT
    ja  NextBase
    mov sieve[esi],1
    add esi,ebx
    jmp Inner
NextBase:
    inc ebx
    jmp Outer

Display:
    mov esi,2
L1: cmp sieve[esi],0
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
> .data? 세그먼트는 65 KB 배열에 알맞은 자리다. 실행 파일에 0 바이트 65,000개를 저장하지 않고 로드 시점에 공간만 예약한다. 그래서 문제가 실행 시간에 REP STOSB로 지우라고 요구한다. 체 자체는 덧셈만 쓴다. base씩 전진해 배수를 표시한다. 두 가지 한계가 속도를 만든다. base²가 한계를 넘으면 외부 루프를 멈추고, 내부 루프는 base²에서 시작한다. 더 작은 배수는 이미 표시되었기 때문이다.

---

### **Q8.** **Bubble Sort** — Add a variable to the BubbleSort procedure in Section 9.5.1 that is set to 1 whenever a pair of values is exchanged within the inner loop. Use this variable to exit the sort before its normal completion if you discover that no exchanges took place during a complete pass through the array. (This variable is commonly known as an exchange flag.)

**정답:**
```asm
BubbleSort PROC USES eax ecx esi,
    pArray:PTR DWORD, Count:DWORD
    LOCAL swapped:DWORD
    mov ecx,Count
    dec ecx                         ; Count-1 passes at most
L1: push ecx                        ; save the outer loop count
    mov swapped,0                   ; no exchanges yet in this pass
    mov esi,pArray
L2: mov eax,[esi]
    cmp eax,[esi+4]                 ; compare a pair
    jle L3                          ; in order: leave them
    xchg eax,[esi+4]                ; out of order: exchange
    mov [esi],eax
    mov swapped,1                   ; remember that we swapped
L3: add esi,4
    loop L2
    pop ecx
    cmp swapped,0                   ; was the whole pass clean?
    je  L4                          ; then the array is already sorted
    loop L1
L4: ret
BubbleSort ENDP
```

> **해설:**
> 기본 버블 정렬은 이미 정렬된 데이터에서도 항상 n−1번 통과한다. 교환 플래그는 이를 적응형 정렬로 바꾼다. 한 번 완전히 통과하며 교환이 없었다면 순서가 어긋난 것이 없으므로 즉시 반환한다. 최선의 경우 비용이 n² 비교에서 n으로 줄어든다. 플래그는 외부 루프 전에 한 번이 아니라 매 통과 시작마다 초기화해야 한다.

---

### **Q9.** **Binary Search** — Rewrite the binary search procedure shown in this chapter by using registers for mid, first, and last. Add comments to clarify the registers' usage.

**정답:**
```asm
; BinarySearch: searches a sorted array of signed doublewords
;   Receives: pArray = array pointer, Count = element count,
;             searchVal = value to find
;   Returns:  EAX = index of the matching element, or -1 if not found
;   Register usage:  EBX = first   EDX = last   ESI = mid   EDI = searchVal
BinarySearch PROC USES ebx edx esi edi,
    pArray:PTR DWORD, Count:DWORD, searchVal:DWORD
    mov edi,searchVal
    mov ebx,0                       ; first = 0
    mov edx,Count
    dec edx                         ; last = Count - 1
L1: cmp ebx,edx                     ; while first <= last
    jg  NotFound
    mov esi,ebx                     ; mid = (first + last) / 2
    add esi,edx
    shr esi,1                       ; unsigned shift: indexes are never negative
    mov eax,pArray
    cmp edi,[eax+esi*4]             ; compare against array[mid]
    je  Found
    jl  GoLower
    lea ebx,[esi+1]                 ; searchVal is higher: first = mid + 1
    jmp L1
GoLower:
    lea edx,[esi-1]                 ; searchVal is lower: last = mid - 1
    jmp L1
NotFound:
    mov eax,-1
    ret
Found:
    mov eax,esi                     ; the index of the match
    ret
BinarySearch ENDP
```

> **해설:**
> first, last, mid를 레지스터에 두면 루프에서 메모리 접근이 모두 사라지는데, 이것이 문제의 요점이다. 주석 블록에 레지스터 용도를 적어 두는 것이 이런 코드를 읽을 수 있게 한다. 두 가지가 중요하다. 루프는 first ≤ last인 동안 계속해야 하고, 인덱스가 음수가 아니며 시프트가 훨씬 저렴하므로 mid는 IDIV가 아니라 SHR로 계산한다. 반복마다 남은 범위의 절반이 버려지므로 최악의 경우 log₂(n)번 비교한다.

---

### **Q10.** **Letter Matrix** — Create a procedure that generates a four-by-four matrix of randomly chosen capital letters. When choosing the letters, there must be a 50% probability that the chosen letter is a vowel. Write a test program with a loop that calls your procedure five times and displays each matrix in the console window.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
vowels BYTE "AEIOU"
matrix BYTE 16 DUP(?)
space  BYTE " ",0

.code
main PROC
    call Randomize
    mov ecx,5
L1: push ecx
    INVOKE MakeMatrix, ADDR matrix
    INVOKE ShowMatrix, ADDR matrix
    call Crlf
    pop ecx
    loop L1
    exit
main ENDP

; MakeMatrix: fills 16 bytes with capital letters, half of them vowels
MakeMatrix PROC USES eax ebx ecx edi, pMatrix:PTR BYTE
    mov edi,pMatrix
    mov ecx,16
L1: mov eax,2                       ; a coin flip
    call RandomRange
    cmp eax,0
    je  PickVowel
    mov eax,26                      ; any capital letter
    call RandomRange
    add al,'A'
    jmp Store
PickVowel:
    mov eax,5                       ; one of AEIOU
    call RandomRange
    mov al,vowels[eax]
Store:
    mov [edi],al
    inc edi
    loop L1
    ret
MakeMatrix ENDP

; ShowMatrix: displays the 16 bytes as four rows of four
ShowMatrix PROC USES eax ebx ecx esi, pMatrix:PTR BYTE
    mov esi,pMatrix
    mov ebx,4                       ; four rows
L1: mov ecx,4                       ; four columns
L2: mov al,[esi]
    call WriteChar
    mov edx,OFFSET space
    call WriteString
    inc esi
    loop L2
    call Crlf
    dec ebx
    jnz L1
    ret
ShowMatrix ENDP
END main
```

> **해설:**
> 50% 조건은 글자를 고르기 전에 별도의 동전 던지기로 만족시킨다. 26가지 추첨에 가중치를 주는 방식이 아니다. A–Z에서 균등하게 뽑으면 모음이 나올 확률은 5/26뿐이다. 행렬을 평평한 16바이트로 저장하고 한 행에 네 개씩 출력하는 것이 진짜 2차원 배치보다 간단하고 여기서는 손해도 없다. 배열이 BYTE이므로 vowels[eax]는 스케일 1 인덱스로 동작한다.

---

### **Q11.** **Letter Matrix/Sets with Vowels** — Use the letter matrix from the previous exercise as a starting point. Generate a single random four-by-four letter matrix in which each letter has a 50% probability of being a vowel. Traverse each matrix row, column, and diagonal, generating sets of letters. Display only four-letter sets containing exactly two vowels. For example, from the matrix POAZ / AEAU / GKAE / IAGD the sets displayed would be POAZ, GKAE, IAGD, PAGI, ZUED, PEAD and ZAKI. The order of letters within each set is unimportant.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
matrix BYTE 16 DUP(?)               ; row-major: matrix[row*4 + col]
setBuf BYTE 5 DUP(0)                ; four letters + null
; the ten sets to examine, as index quadruples
sets   BYTE  0, 1, 2, 3             ; row 0
       BYTE  4, 5, 6, 7             ; row 1
       BYTE  8, 9,10,11             ; row 2
       BYTE 12,13,14,15             ; row 3
       BYTE  0, 4, 8,12             ; column 0
       BYTE  1, 5, 9,13             ; column 1
       BYTE  2, 6,10,14             ; column 2
       BYTE  3, 7,11,15             ; column 3
       BYTE  0, 5,10,15             ; main diagonal
       BYTE  3, 6, 9,12             ; other diagonal
SET_COUNT = 10

.code
main PROC
    call Randomize
    INVOKE MakeMatrix, ADDR matrix  ; from the previous exercise
    mov ebx,OFFSET sets
    mov ecx,SET_COUNT
L1: push ecx
    INVOKE BuildSet, ebx, ADDR setBuf   ; gather the four letters
    INVOKE CountVowels, ADDR setBuf
    .IF eax == 2                    ; exactly two vowels
        mov edx,OFFSET setBuf
        call WriteString
        call Crlf
    .ENDIF
    add ebx,4                       ; next index quadruple
    pop ecx
    loop L1
    exit
main ENDP

; BuildSet: copies the four indexed letters into a buffer
BuildSet PROC USES eax ebx ecx esi edi, pIdx:PTR BYTE, pBuf:PTR BYTE
    mov esi,pIdx
    mov edi,pBuf
    mov ecx,4
L1: movzx ebx,BYTE PTR [esi]
    mov al,matrix[ebx]
    mov [edi],al
    inc esi
    inc edi
    loop L1
    mov BYTE PTR [edi],0
    ret
BuildSet ENDP

; CountVowels: returns the number of vowels in a null-terminated string
CountVowels PROC USES ecx esi, pStr:PTR BYTE
    mov eax,0
    mov esi,pStr
L1: mov cl,[esi]
    cmp cl,0
    je  Done
    mov edi,OFFSET vowels           ; "AEIOU" from the previous exercise
    mov ecx,5
L2: cmp cl,[edi]
    je  IsVowel
    inc edi
    loop L2
    jmp NextChar
IsVowel:
    inc eax
NextChar:
    inc esi
    jmp L1
Done:
    ret
CountVowels ENDP
END main
```

> **해설:**
> 이 문제를 다루기 쉽게 만드는 요령은 인덱스 네 쌍의 테이블이다. 행, 열, 두 대각선이 모두 같은 연산이 되므로 열 개의 테이블 항목을 도는 루프 하나가 세 가지 순회 루틴을 대체한다. 4×4 행렬에는 그런 집합이 정확히 4 + 4 + 2 = 10개 있다. "모음이 정확히 두 개"를 걸러내려면 플래그가 아니라 개수가 필요하다. 예시 출력이 이를 확인해 준다. POAZ는 두 개(O, A)여서 표시되고 AEAU는 네 개여서 표시되지 않는다.

---

### **Q12.** **Calculating the Sum of an Array Row** — Write a procedure named calc_row_sum that calculates the sum of a single row in a two-dimensional array of bytes, words, or doublewords. The procedure should have the following stack parameters: array offset, row size, array type, row index. It must return the sum in EAX. Use explicit stack parameters, not INVOKE or extended PROC. Write a program that tests your procedure with arrays of byte, word, and doubleword. Prompt the user for the row index and display the sum of the selected row.

**정답:**
```asm
INCLUDE Irvine32.inc
.data
bArray BYTE  10h,20h,30h,40h,  50h,60h,70h,80h
wArray WORD  100h,200h,300h,400h,  500h,600h,700h,800h
dArray DWORD 10000h,20000h,30000h,40000h,  50000h,60000h,70000h,80000h
prompt BYTE "Row index: ",0

.code
main PROC
    mov edx,OFFSET prompt
    call WriteString
    call ReadInt
    mov ebx,eax                     ; row index

    push ebx                        ; row index
    push TYPE bArray                ; array type (1)
    push 4 * TYPE bArray            ; row size in bytes
    push OFFSET bArray              ; array offset
    call calc_row_sum
    call WriteHex
    call Crlf

    push ebx
    push TYPE wArray                ; 2
    push 4 * TYPE wArray
    push OFFSET wArray
    call calc_row_sum
    call WriteHex
    call Crlf

    push ebx
    push TYPE dArray                ; 4
    push 4 * TYPE dArray
    push OFFSET dArray
    call calc_row_sum
    call WriteHex
    call Crlf
    exit
main ENDP

; calc_row_sum: sums one row of a two-dimensional array
;   Stack: [ebp+8]  = array offset
;          [ebp+12] = row size in bytes
;          [ebp+16] = array type (1, 2 or 4)
;          [ebp+20] = row index
;   Returns: EAX = sum
calc_row_sum PROC
    push ebp
    mov  ebp,esp
    push ebx
    push ecx
    push edx
    push esi
    mov eax,[ebp+20]                ; row index
    mul DWORD PTR [ebp+12]          ; * row size = byte offset of the row
    add eax,[ebp+8]                 ; + array base
    mov esi,eax                     ; ESI walks the row
    mov eax,[ebp+12]                ; row size in bytes
    mov edx,0                       ; clear the high dividend half
    div DWORD PTR [ebp+16]          ; / element size
    mov ecx,eax                     ; elements per row = rowSize / type
    mov eax,0                       ; running sum
    mov ebx,[ebp+16]                ; element size
L1: cmp ebx,1
    je  AddByte
    cmp ebx,2
    je  AddWord
    add eax,[esi]                   ; doubleword
    jmp Next
AddByte:
    movzx edx,BYTE PTR [esi]
    add eax,edx
    jmp Next
AddWord:
    movzx edx,WORD PTR [esi]
    add eax,edx
Next:
    add esi,ebx
    loop L1
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret 16                          ; discard four doubleword parameters
calc_row_sum ENDP
END main
```

> **해설:**
> 행의 바이트 오프셋은 rowIndex × rowSize이고 그 안의 원소 개수는 rowSize ÷ type이다. 그래서 두 값이 모두 매개변수다. 이어서 원소 크기가 각 항목을 읽는 방식을 결정한다. 바이트와 워드는 상위 비트에 남은 값이 섞이지 않도록 MOVZX를, 더블워드는 평범한 MOV를 쓴다. 여기서는 MUL과 DIV 모두 주의가 필요하다. MUL은 EDX를 덮어쓰고, DIV는 실행 전에 EDX를 0으로 지우고 EAX에 피제수가 들어 있어야 한다. 명시적 스택 매개변수를 쓰면 프롤로그, EBP 오프셋, RET 16이 모두 직접 챙길 몫이다.

---

### **Q13.** **Trimming Leading Characters** — Create a variant of the Str_trim procedure that lets the caller remove all instances of a leading character from a string. For example, calling it with a pointer to the string "###ABC" and the # character would leave "ABC".

**정답:**
```asm
INCLUDE Irvine32.inc
Str_trimLeft PROTO, pString:PTR BYTE, char:BYTE

.data
target BYTE "###ABC",0

.code
main PROC
    INVOKE Str_trimLeft, ADDR target, '#'
    mov edx,OFFSET target
    call WriteString                ; ABC
    call Crlf
    exit
main ENDP

Str_trimLeft PROC USES eax ecx esi edi,
    pString:PTR BYTE, char:BYTE
    mov esi,pString
    mov al,char
L1: cmp BYTE PTR [esi],0            ; the whole string is delimiters?
    je  Done
    cmp [esi],al                    ; still a leading delimiter?
    jne Shift
    inc esi
    jmp L1
Shift:
    cmp esi,pString                 ; nothing to remove?
    je  Done
    mov edi,pString                 ; shift the rest to the front
    INVOKE Str_length, esi
    mov ecx,eax
    inc ecx                         ; include the null terminator
    cld
    rep movsb
Done:
    ret
Str_trimLeft ENDP
END main
```

> **해설:**
> 앞쪽을 자르는 것은 뒤쪽을 자르는 것보다 일이 많다. Str_trim은 널 바이트만 저장하면 되지만, 여기서는 남은 텍스트를 버퍼 앞으로 옮겨야 호출자의 포인터가 여전히 그 문자열을 가리킨다. 목적지 주소가 원본보다 낮으므로 앞으로 복사하는 것이 안전하다. 두 가지 경계 사례를 시험해 볼 만하다. 전체가 구분 문자인 문자열과, 앞쪽에 구분 문자가 전혀 없는 문자열.

---

### **Q14.** **Trimming a Set of Characters** — Create a variant of the Str_trim procedure that lets the caller remove all instances of a set of characters from the end of a string. For example, calling it with a pointer to the string "ABC#$&" and a pointer to an array of filter characters containing "%#!;$&*" would leave "ABC".

**정답:**
```asm
INCLUDE Irvine32.inc
Str_trimSet PROTO, pString:PTR BYTE, pFilter:PTR BYTE

.data
target BYTE "ABC#$&",0
filter BYTE "%#!;$&*",0

.code
main PROC
    INVOKE Str_trimSet, ADDR target, ADDR filter
    mov edx,OFFSET target
    call WriteString                ; ABC
    call Crlf
    exit
main ENDP

Str_trimSet PROC USES eax ebx ecx edi,
    pString:PTR BYTE, pFilter:PTR BYTE
    INVOKE Str_length, pString
    cmp eax,0
    je  Done
    mov edi,pString
    add edi,eax
    dec edi                         ; EDI = last character
L1: mov al,[edi]
    INVOKE InFilter, eax, pFilter   ; is this character in the set?
    cmp eax,0
    je  Terminate                   ; no: the string ends here
    cmp edi,pString                 ; yes: was that the first character?
    je  TrimAll
    dec edi                         ; keep scanning backward
    jmp L1
TrimAll:
    mov edi,pString                 ; everything was filtered out
    dec edi
Terminate:
    mov BYTE PTR [edi+1],0
Done:
    ret
Str_trimSet ENDP

; InFilter: returns EAX = 1 if AL appears in the filter string
InFilter PROC USES ebx esi, char:DWORD, pFilter:PTR BYTE
    mov esi,pFilter
    mov bl,BYTE PTR char
L1: mov al,[esi]
    cmp al,0
    je  NotFound
    cmp al,bl
    je  Found
    inc esi
    jmp L1
NotFound:
    mov eax,0
    ret
Found:
    mov eax,1
    ret
InFilter ENDP
END main
```

> **해설:**
> 이것은 Str_trim을 구분 문자 하나에서 집합으로 일반화한 것이므로 CMP 하나가 필터 문자열 조회로 바뀐다. 그 조회를 작은 프로시저로 분리하면 자르는 루프가 읽기 쉬워진다. 탐색은 여전히 마지막 문자에서 뒤로 진행하다가 집합에 없는 첫 문자에서 멈추고 그 바로 뒤에 널을 쓴다. 모든 문자가 걸러지는 경우를 처리해야 한다. 포인터가 버퍼 시작보다 아래로 내려가면 안 되므로 그 경로를 따로 다룬다.

---
