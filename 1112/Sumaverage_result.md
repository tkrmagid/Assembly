# 정수 5개의 합계와 평균 구하기 (MASM 32비트)

Visual Studio 2022에서 MASM으로 작성한 32비트 콘솔 프로그램이다. 정수 5개를 입력받아 합계와 평균을 출력한다.

- 소스 파일: [SumAverage.asm](SumAverage.asm)
- 개발 환경: Visual Studio 2022, MASM(ml.exe), x86(Win32), Irvine32 라이브러리

## 1. 실행 결과

![코드실행결과](코드실행결과.png)

## 2. 소스 코드

```asm
INCLUDE Irvine32.inc

SetConsoleOutputCP PROTO, wCodePageID:DWORD

COUNT = 5

.data
titleMsg  BYTE "정수 5개의 합계와 평균 구하기",0
promptMsg BYTE "번째 정수 입력: ",0
sumMsg    BYTE "합계: ",0
avgMsg    BYTE "평균: ",0
numbers   SDWORD COUNT DUP(?)
sum       SDWORD 0

.code
main PROC
    INVOKE SetConsoleOutputCP, 65001    ; 콘솔 출력을 UTF-8로 설정 (한글 깨짐 방지, 이 파일은 UTF-8로 저장)

    mov  edx, OFFSET titleMsg
    call WriteString
    call Crlf
    call Crlf

    mov  esi, OFFSET numbers
    mov  ecx, COUNT
    mov  ebx, 1
L1:
    mov  eax, ebx
    call WriteDec
    mov  edx, OFFSET promptMsg
    call WriteString
    call ReadInt
    mov  [esi], eax
    add  esi, TYPE numbers
    inc  ebx
    loop L1

    mov  esi, OFFSET numbers
    mov  ecx, COUNT
    mov  eax, 0
L2:
    add  eax, [esi]
    add  esi, TYPE numbers
    loop L2
    mov  sum, eax

    call Crlf
    mov  edx, OFFSET sumMsg
    call WriteString
    mov  eax, sum
    call WriteInt
    call Crlf

    mov  edx, OFFSET avgMsg
    call WriteString
    mov  ebx, sum
    mov  al, '+'
    cmp  ebx, 0
    jge  L3
    neg  ebx                            ; 음수면 부호만 따로 출력하고 절댓값으로 나눈다
    mov  al, '-'
L3:
    call WriteChar
    mov  eax, ebx
    mov  edx, 0
    mov  ecx, COUNT
    div  ecx                            ; EAX = 몫(정수부), EDX = 나머지
    call WriteDec
    mov  al, '.'
    call WriteChar
    mov  eax, edx
    shl  eax, 1                         ; 나머지/5 = (나머지*2)/10 → 소수 첫째 자리
    call WriteDec
    call Crlf

    exit
main ENDP
END main
```

## 3. 코드 분석

### 3.1 전체 흐름

| 단계 | 내용 | 사용 레지스터 |
|---|---|---|
| ① 콘솔 설정 | 출력 코드 페이지를 UTF-8(65001)로 변경 | — |
| ② 입력 루프 `L1` | 정수 5개를 `numbers` 배열에 저장 | ESI(포인터), ECX(반복 횟수), EBX(순번), EAX(입력값) |
| ③ 합계 루프 `L2` | 배열 원소를 EAX에 누적 → `sum` | ESI, ECX, EAX |
| ④ 합계 출력 | `WriteInt`로 부호 있는 10진수 출력 | EAX |
| ⑤ 평균 출력 | 부호 처리 → `DIV`로 몫·나머지 → `몫.소수1자리` 출력 | EBX(절댓값), EAX(몫), EDX(나머지), ECX(제수) |

### 3.2 데이터 영역

- `COUNT = 5` : 기호 상수. 메모리를 차지하지 않고 어셈블 시점에 5로 치환된다. 입력 개수를 바꾸려면 이 한 줄만 고치면 된다(단, 소수 자리 계산 `shl eax,1`은 5로 나눌 때만 성립).
- `numbers SDWORD COUNT DUP(?)` : 부호 있는 32비트 정수 5개(20바이트)의 초기화되지 않은 배열.
- `sum SDWORD 0` : 합계를 저장하는 변수.
- 문자열은 모두 `0`으로 끝나는 널 종료 문자열이며, `WriteString`이 널 바이트를 만날 때까지 출력한다.

### 3.3 한글 출력 처리

- 소스 파일을 **UTF-8(BOM 없음)** 으로 저장했기 때문에 문자열의 한글은 UTF-8 바이트로 실행 파일에 들어간다.
- 한국어 Windows 콘솔의 기본 코드 페이지는 949(CP949)라서 그대로 출력하면 글자가 깨진다. 프로그램 시작 시 `SetConsoleOutputCP(65001)`을 호출해 콘솔이 출력 바이트를 UTF-8로 해석하도록 맞췄다.
- `SetConsoleOutputCP`는 kernel32.dll의 Win32 API인데 Irvine32.inc(SmallWin.inc)에 선언이 없어 `PROTO`로 직접 선언했고, 인수가 있으므로 `INVOKE`로 호출했다.

### 3.4 입력 루프 (L1)

- `ESI = OFFSET numbers` : 배열의 시작 주소를 넣어 간접 주소 지정(`[esi]`)으로 원소에 접근한다.
- `ECX = COUNT` : `LOOP` 명령이 ECX를 1 감소시키고 0이 아니면 `L1`으로 되돌아가므로 정확히 5번 반복한다.
- `EBX` : 화면에 보여 줄 순번(1~5). `WriteDec`가 EAX 값을 출력하므로 `mov eax, ebx`로 옮겨서 출력한다.
- `ReadInt` : 키보드에서 부호 있는 10진 정수를 읽어 EAX로 반환한다. 이 값을 `mov [esi], eax`로 배열에 저장한다.
- `add esi, TYPE numbers` : `TYPE numbers`는 원소 하나의 크기(4)이므로 다음 원소로 포인터를 옮긴다.
- Irvine32 프로시저는 반환값 레지스터 외의 레지스터를 보존하므로 루프 안에서 호출해도 ECX·ESI·EBX가 유지된다.

### 3.5 합계 루프 (L2)

- ESI와 ECX를 다시 초기화한 뒤 `add eax, [esi]`로 원소를 하나씩 누적한다.
- 결과를 `sum`에 저장하고, `WriteInt`로 출력한다. `WriteInt`는 양수에도 `+` 부호를 붙여 출력한다.

### 3.6 평균 계산

평균은 `합계 ÷ 5`이며, 정수 나눗셈의 몫만 쓰면 소수 부분이 버려지므로 **나머지로 소수 첫째 자리까지** 구했다.

1. **부호 분리** : `cmp ebx, 0 / jge L3`로 합계가 음수인지 검사한다. 음수면 `neg ebx`로 절댓값을 만들고 출력할 부호 문자를 `'-'`로 바꾼다. 부호를 먼저 출력하고 절댓값으로 계산하면 `-7 ÷ 5 = -1.4`처럼 몫이 0이거나 음수인 경우도 올바르게 표시된다.
2. **나눗셈** : `DIV ecx`는 `EDX:EAX`(64비트)를 ECX로 나누므로, 나누기 전에 `mov edx, 0`으로 상위 32비트를 반드시 0으로 만들어야 한다. 실행 후 `EAX = 몫`, `EDX = 나머지`.
3. **소수 첫째 자리** : 나머지 r(0~4)에 대해 `r/5 = (r×2)/10`이므로 `r×2`가 곧 소수 첫째 자리 숫자다. `shl eax, 1`(왼쪽 1비트 시프트)로 2를 곱했다. 5로 나눌 때는 소수 첫째 자리에서 항상 나누어떨어지므로 반올림 오차가 없다.

| 합계 | 절댓값 ÷ 5 | 몫 | 나머지 | 나머지×2 | 출력 |
|---|---|---|---|---|---|
| +87 | 87 ÷ 5 | 17 | 2 | 4 | `+17.4` |
| +15 | 15 ÷ 5 | 3 | 0 | 0 | `+3.0` |
| -7 | 7 ÷ 5 | 1 | 2 | 4 | `-1.4` |

### 3.7 사용한 주요 명령어·프로시저

| 구분 | 이름 | 역할 |
|---|---|---|
| 명령어 | `MOV`, `ADD`, `INC`, `NEG` | 데이터 이동, 덧셈, 1 증가, 부호 반전(2의 보수) |
| 명령어 | `LOOP` | ECX를 감소시키며 반복 |
| 명령어 | `CMP` + `JGE` | 부호 있는 비교 후 조건 점프 |
| 명령어 | `DIV`, `SHL` | 부호 없는 나눗셈, 왼쪽 시프트(×2) |
| Irvine32 | `WriteString` | EDX가 가리키는 널 종료 문자열 출력 |
| Irvine32 | `WriteDec` / `WriteInt` | EAX를 부호 없는 / 부호 있는 10진수로 출력 |
| Irvine32 | `WriteChar` | AL의 문자 1개 출력 |
| Irvine32 | `ReadInt` | 정수를 입력받아 EAX로 반환 |
| Irvine32 | `Crlf`, `exit` | 줄바꿈, 프로그램 종료 |
| Win32 API | `SetConsoleOutputCP` | 콘솔 출력 코드 페이지 설정 |

## 4. 빌드 및 실행 방법 (Visual Studio 2022)

1. `SumAverage.sln`을 Visual Studio로 연다. (구성: `Debug` / `x86`)
2. 프로젝트에는 MASM 빌드 사용자 지정(masm.props/targets)과 Irvine32 경로(Include·Library 디렉터리, `Irvine32.lib` 링크)가 설정되어 있다.
3. `Ctrl + F5`(디버그하지 않고 시작)로 실행하고 정수 5개를 입력한다.
