.386
.model flat, stdcall
.stack 4096

includelib kernel32.lib

GetStdHandle PROTO :DWORD
WriteConsoleA PROTO :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess PROTO :DWORD

.data
  output BYTE "NA HYEONJI", 13, 10, "2025664014", 13, 10
  written DWORD ?

.code
main PROC
  invoke GetStdHandle, -11
  mov ebx, eax

  invoke WriteConsoleA, ebx, ADDR output, SIZEOF output, ADDR written, 0

  invoke ExitProcess, 0
main ENDP
END main