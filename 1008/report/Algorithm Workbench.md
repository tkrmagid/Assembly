# Algorithm Workbench

### **Q1.** Write a sequence of statements that use only PUSH and POP instructions to exchange the values in the EAX and EBX registers (or RAX and RBX in 64-bit mode).

**정답:**
```asm
push eax
push ebx
pop eax       ; EAX gets the old EBX
pop ebx       ; EBX gets the old EAX
```

> **해설:**
> 스택은 LIFO이므로 푸시한 순서 그대로 팝하면 대입이 뒤바뀐다: 마지막에 푸시한 값(EBX)이 먼저 나와 EAX로 들어간다.

---

### **Q2.** Suppose you wanted a subroutine to return to an address that was 3 bytes higher in memory than the return address currently on the stack. Write a sequence of instructions that would be inserted just before the subroutine's RET instruction that accomplish this task.

**정답:**
```asm
add DWORD PTR [esp],3      ; modify the return address in place
ret
; or:
; pop eax
; add eax,3
; push eax
; ret
```

> **해설:**
> RET 직전에 반환 주소는 스택 맨 위([esp])에 있다. 여기에 3을 더하면 RET이 3바이트 뒤로 점프한다.

---

### **Q3.** Functions in high-level languages often declare local variables just below the return address on the stack. Write an instruction that you could put at the beginning of an assembly language subroutine that would reserve space for two integer doubleword variables. Then, assign the values 1000h and 2000h to the two local variables.

**정답:**
```asm
sub esp,8                      ; reserve two doublewords
mov DWORD PTR [esp],1000h      ; first local
mov DWORD PTR [esp+4],2000h    ; second local
...
add esp,8                      ; release before RET
ret
```

> **해설:**
> ESP에서 8을 빼면 반환 주소 아래에 8바이트 공간이 생긴다. 지역 변수는 ESP 기준으로 접근하고, RET 전에 공간을 해제해야 반환 주소가 다시 맨 위에 온다.

---

### **Q4.** Write a sequence of statements using indexed addressing that copies an element in a doubleword array to the previous position in the same array.

**정답:**
```asm
.data
array DWORD 10,20,30,40
.code
mov esi,2                     ; element index (copy element 2 to element 1)
mov eax,array[esi*4]
mov array[esi*4-4],eax        ; previous position
```

> **해설:**
> 스케일 팩터 4를 쓰면 인덱스가 원소를 센다. 주소에서 4바이트를 빼면 바로 앞 더블워드에 닿는다.

---

### **Q5.** Write a sequence of statements that display a subroutine's return address. Be sure that whatever modifications you make to the stack do not prevent the subroutine from returning to its caller.

**정답:**
```asm
ShowRet PROC
    mov eax,[esp]        ; return address is at the top of the stack
    call WriteHex        ; display it (Irvine32)
    call Crlf
    ret                  ; stack untouched, returns normally
ShowRet ENDP
; alternative: pop eax / push eax / call WriteHex / ret
```

> **해설:**
> 진입 시 반환 주소는 [esp]에 있다. MOV로 읽으면 스택이 그대로 유지되고, POP했다면 RET 전에 다시 PUSH해야 한다.

---
