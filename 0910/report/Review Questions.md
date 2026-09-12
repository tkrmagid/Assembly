# Review Questions

### **Q1.** In 32-bit mode, aside from the stack pointer (ESP), what other register points to variables on the stack?

**정답:**
`EBP` (base pointer)

> **해설:**
> EBP(확장 베이스 포인터)는 고급 언어가 스택의 함수 매개변수와 지역 변수를 `[ebp+8]`, `[ebp-4]` 같은 형태로 참조할 때 사용한다.

---

### **Q2.** Name at least four CPU status flags.

**정답:**
Carry, Overflow, Sign, Zero

> **해설:**
> **상태 플래그 표**

| 플래그 | 설명 |
| :--- | :--- |
| Carry (CF) | **부호 없는** 연산 결과가 목적지에 담기에 너무 크거나 작을 때 설정 |
| Overflow (OF) | **부호 있는** 연산 결과가 목적지에 담기에 너무 크거나 작을 때 설정 |
| Sign (SF) | 산술/논리 연산 결과가 **음수**(MSB = 1)일 때 설정 |
| Zero (ZF) | 결과가 0일 때 설정 |
| Auxiliary Carry (AC) | 8비트 연산에서 bit 3에서 올림이 발생할 때 |
| Parity (PF) | 결과 하위 바이트의 1 비트 개수가 짝수일 때 설정 |

제어 플래그로는 Direction 플래그(문자열 연산), Interrupt 플래그 등이 있다.

---

### **Q3.** Which flag is set when the result of an unsigned arithmetic operation is too large to fit into the destination?

**정답:**
Carry flag (CF)

> **해설:**
> Carry 플래그는 부호 없는 오버플로를 나타낸다.  
> 
> 최상위 비트에서 올림이 나가면 부호 없는 결과가 목적지에 들어가지 않았다는 뜻이다.

---

### **Q4.** Which flag is set when the result of a signed arithmetic operation is either too large or too small to fit into the destination?

**정답:**
Overflow flag (OF)

> **해설:**
> Overflow 플래그는 부호 있는 오버플로를 나타낸다. 예를 들어 부호 있는 바이트에서 127 + 1은 −128이 되며 OF가 설정된다.

---

### **Q5.** (True/False): When a register operand size is 32 bits and the REX prefix is used, the R8D register is available for programs to use.

**정답:**
True

> **해설:**
> REX 접두사를 쓰면 추가 레지스터 R8–R15를 사용할 수 있고, 그 32비트 부분의 이름이 R8D–R15D다.

---

### **Q6.** Which flag is set when an arithmetic or logical operation generates a negative result?

**정답:**
Sign flag (SF)

> **해설:**
> Sign 플래그는 결과의 최상위 비트를 복사한 값이다. 그 비트가 1이면 부호 있는 수로 볼 때 음수라는 뜻이다.

---

### **Q7.** Which part of the CPU performs floating-point arithmetic?

**정답:**
the floating-point unit (FPU)


> **해설:**
> 부동소수점 유닛(FPU)이 자체 레지스터 스택에서 부동소수점 명령을 실행한다. 예전에는 별도의 8087 코프로세서였지만 지금은 CPU에 내장되어 있다.

---

### **Q8.** On a 32-bit processor, how many bits are contained in each floating-point data register?

**정답:**
80

> **해설:**
> FPU에는 80비트 데이터 레지스터 ST(0)~ST(7) 8개가 있으며 확장 정밀도 형식으로 값을 저장한다.

---

### **Q9.** (True/False): The x86-64 instruction set is backward-compatible with the x86 instruction set.

**정답:**
True

> **해설:**
> x86-64는 x86 명령어 집합을 확장한 것이므로 기존 32비트 프로그램도 실행된다.

---

### **Q10.** (True/False): In current 64-bit chip implementations, all 64 bits are used for addressing.

**정답:**
False

> **해설:**
> 주소는 64비트이지만 현재 구현은 하위 48비트만 사용하며, 256 TB의 주소 공간을 지원한다.

---

### **Q11.** (True/False): The Itanium instruction set is completely different from the x86 instruction set.

**정답:**
True

> **해설:**
> Itanium(IA-64)은 고성능 서버용 별도 인텔 아키텍처로, 명령어 집합이 x86 및 x86-64와 완전히 다르다.

---

### **Q12.** (True/False): Static RAM is usually less expensive than dynamic RAM.

**정답:**
False

> **해설:**
> SRAM은 비싸고 빨라서 캐시에 쓰이고, DRAM은 더 싸고 느리며 계속 리프레시해야 한다.

---

### **Q13.** (True/False): The 64-bit RDI register is available when the REX prefix is used.

**정답:**
True

> **해설:**
> REX 접두사가 64비트 피연산자를 가능하게 하므로 기존 레지스터의 64비트 형태(RAX, RBX, …, RDI, RSP)를 사용할 수 있다.

---

### **Q14.** (True/False): In native 64-bit mode, you can use 16-bit real mode, but not the virtual-8086 mode.

**정답:**
False

> **해설:**
> 네이티브 64비트 모드에서는 16비트 실모드와 가상-8086 모드를 둘 다 지원하지 않는다.

---

### **Q15.** (True/False): The x86-64 processors have 4 more general-purpose registers than the x86 processors.

**정답:**
False

> **해설:**
> x86-64는 범용 레지스터 8개(R8–R15)를 추가해 총 16개이므로 4개가 아니라 8개 더 많다.

---

### **Q16.** (True/False): The 64-bit version of Microsoft Windows does not support virtual-8086 mode.

**정답:**
True

> **해설:**
> 네이티브 64비트 모드는 가상-8086 모드를 없앴고 64비트 Windows에서는 레거시 16비트 모드도 쓸 수 없어서 옛 MS-DOS 프로그램을 직접 실행할 수 없다.

---

### **Q17.** (True/False): DRAM can only be erased using ultraviolet light.

**정답:**
False

> **해설:**
> 자외선으로 지우는 것은 EPROM이다. DRAM은 전기적으로 쓰고 계속 리프레시해야 하는 일반 휘발성 메모리다.

---

### **Q18.** (True/False): In 64-bit mode, you can use up to eight floating-point registers.

**정답:**
True

> **해설:**
> 64비트 실행 환경에는 80비트 부동소수점 레지스터 8개(FPU 레지스터 스택)가 있다.

---

### **Q19.** (True/False): A bus is a plastic cable that is attached to the motherboard at both ends, but does not sit directly on the motherboard.

**정답:**
False

> **해설:**
> 버스는 컴퓨터의 각 부분 사이에서 데이터를 전달하는 병렬 전선 묶음이며, 시스템 버스는 메인보드 자체에 인쇄되어 있다.

---

### **Q20.** (True/False): CMOS RAM is the same as static RAM, meaning that it holds its value without any extra power or refresh cycles.

**정답:**
False

> **해설:**
> CMOS RAM은 시스템 설정 정보를 저장하며, 전원이 꺼져 있을 때는 메인보드의 작은 배터리로 유지된다.

---

### **Q21.** (True/False): PCI connectors are used for graphics cards and sound cards.

**정답:**
True

> **해설:**
> 메인보드에는 사운드 카드, 그래픽 카드, 데이터 수집 보드 등 I/O 장치를 위한 PCI 버스 커넥터가 있다.

---

### **Q22.** (True/False): The 8259A is a controller that handles external interrupts from hardware devices.

**정답:**
True

> **해설:**
> 8259A 프로그래머블 인터럽트 컨트롤러(PIC)는 키보드, 시스템 클록, 디스크 드라이브 같은 장치의 인터럽트를 처리한다.

---

### **Q23.** (True/False): The acronym PCI stands for programmable component interface.

**정답:**
False

> **해설:**
> PCI는 Peripheral Component Interconnect의 약자다.

---

### **Q24.** (True/False): VRAM stands for virtual random access memory.

**정답:**
False

> **해설:**
> VRAM은 비디오 RAM으로, 화면이 갱신되는 동안 비디오 데이터를 담는 듀얼 포트 메모리다.

---

### **Q25.** At which level(s) can an assembly language program manipulate input/output?

**정답:**
All levels: library (3), operating system (2), BIOS (1) and hardware ports (0)

> **해설:**
> 어셈블리 언어는 라이브러리 함수, OS 함수, BIOS 함수를 호출할 수 있고 하드웨어 포트를 직접 읽고 쓸 수도 있으므로 모든 계층에서 동작할 수 있다.

---

### **Q26.** Why do game programs often send their sound output directly to the sound card's hardware ports?

**정답:**
For speed and full control — bypassing the OS and BIOS layers avoids their overhead and exposes the card's special features

> **해설:**
> 포트 직접 접근(Level 0)은 더 빠르고 장치를 완전히 제어할 수 있지만 이식성은 포기해야 한다.

---
