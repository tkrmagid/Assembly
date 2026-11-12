# Short Answer

### **Q1.** Which Direction flag setting causes index registers to move backward through memory when executing string primitives?

**정답:**
DF = 1 (set, with the STD instruction)

> **해설:**
> DF가 설정되면(STD) 각 문자열 연산 후 ESI와 EDI가 감소하고, 해제되면(CLD) 증가한다.

---

### **Q2.** When a repeat prefix is used with STOSW, what value is added to or subtracted from the index register?

**정답:**
2

> **해설:**
> STOSW는 16비트 워드를 저장하므로 EDI는 반복마다 2바이트씩 이동한다(STOSB는 1, STOSD는 4).

---

### **Q3.** In what way is the CMPS instruction ambiguous?

**정답:**
The mnemonic does not make clear which operand is compared to which — it actually computes [ESI] − [EDI], so JA means the ESI operand is greater

> **해설:**
> CMPSB/W/D는 ESI가 가리키는 메모리 피연산자를 EDI가 가리키는 것과 비교하며, cmp [esi],[edi]를 실행한 것과 같다. 두 피연산자가 모두 암시적이라 조건 점프를 고를 때 비교 방향을 거꾸로 생각하기 쉽다.

---

### **Q4.** When the Direction flag is clear and SCASB has found a matching character, where does EDI point?

**정답:**
One position beyond the matching character

> **해설:**
> EDI는 일치한 비교를 포함해 매 비교 후 증가하므로 일치 위치의 한 바이트 뒤에서 끝난다. 교재는 dec edi로 되돌린다.

---

### **Q5.** When scanning an array for the first occurrence of a particular character, which repeat prefix would be best?

**정답:**
REPNE (REPNZ)

> **해설:**
> REPNE는 값이 같지 않은 동안(그리고 ECX > 0인 동안) SCAS를 반복하므로 첫 일치에서 멈춘다.

---

### **Q6.** What Direction flag setting is used in the Str_trim procedure from Section 9.3?

**정답:**
The flag is set (backward) — the procedure starts at the last character and moves toward the beginning

> **해설:**
> Str_trim은 끝의 문자를 제거하므로 EDI를 마지막 문자에 두고 뒤로 훑는다(루프가 EDI를 감소시킴). 즉 뒤로 가는 방향이다.

---

### **Q7.** Why does the Str_trim procedure from Section 9.3 use the JNE instruction?

**정답:**
To exit the scanning loop as soon as a character that is not the delimiter is found; the null byte is then inserted after it

> **해설:**
> 루프는 각 문자(끝에서부터)를 구분 문자와 비교한다: cmp al,char / jne L2. 다르면 끝에 붙은 구분 문자 구간이 끝난 것이므로 L2로 점프해 [edi+1]에 0을 저장한다.

---

### **Q8.** What happens in the Str_ucase procedure from Section 9.3 if the target string contains a digit?

**정답:**
Nothing — digits are outside the range 'a'..'z', so they are skipped and left unchanged

> **해설:**
> Str_ucase는 'a'(61h)와 'z'(7Ah) 사이의 바이트만 수정한다. 숫자(30h–39h)를 포함한 다른 바이트는 JB/JA 검사로 건너뛴다.

---

### **Q9.** If the Str_length procedure from Section 9.3 used SCASB, which repeat prefix would be most appropriate?

**정답:**
REPNE (REPNZ)

> **해설:**
> AL = 0으로 두면 REPNE SCASB는 바이트가 0이 아닌 동안 훑고 널 종료 문자 바로 뒤에서 멈춘다.

---

### **Q10.** If the Str_length procedure from Section 9.3 used SCASB, how would it calculate and return the string length?

**정답:**
Set AL = 0 and ECX to a maximum count, REPNE SCASB, then length = EDI − starting offset − 1 (EDI stops one past the null)

> **해설:**
> REPNE SCASB가 널 바이트를 찾으면 EDI는 그 한 칸 뒤를 가리키므로, 원래 포인터와 1을 빼면 문자 수가 된다(또는 시작 개수 − 남은 ECX − 1).

---

### **Q11.** What is the maximum number of comparisons needed by the binary search algorithm when an array contains 1,024 elements?

**정답:**
10

> **해설:**
> 비교할 때마다 탐색 범위가 반으로 줄어 최악의 경우 log₂(1024) = 10번 비교한다(표 9-6). 순차 탐색은 1,024번.

---

### **Q12.** In the FillArray procedure from the Binary Search example in Section 9.5, why must the Direction flag be cleared by the CLD instruction?

**정답:**
FillArray stores values with STOSD, which must move EDI forward through the array; with DF set EDI would move backward

> **해설:**
> 진입 시 DF 상태를 알 수 없고 STOSD는 DF를 따른다. DF를 0으로 하면 저장되는 각 더블워드가 다음 높은 주소로 간다.

---

### **Q13.** In the BinarySearch procedure from Section 9.5, why could the statement at label L2 be removed without affecting the outcome?

**정답:**
The cmp edx,edi at L2 repeats the comparison already made before jge L2; a conditional jump does not change the flags, so they are still valid for jle L3

> **해설:**
> L2에는 cmp edx,edi 직후의 jge L2를 통해서만 도달한다. JGE는 플래그를 건드리지 않으므로 두 번째 cmp는 완전히 같은 플래그를 만들 뿐이며 불필요하다(교재는 "optional"이라고 표시).

---

### **Q14.** In the BinarySearch procedure from Section 9.5, how might the statement at label L4 be eliminated?

**정답:**
Replace the two jmp L4 instructions with jmp L1 so each branch returns directly to the loop test

> **해설:**
> L4에는 jmp L1만 있고, first나 last를 조정하는 두 분기의 jmp L4로만 도달한다. 그 분기에서 바로 L1으로 점프하면 L4가 필요 없다.

---
