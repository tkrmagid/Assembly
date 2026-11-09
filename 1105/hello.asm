default rel

section .data
  message db "Hello, Assembly!", 0

section .text
  global main
  extern printf

main:
  sub rsp, 40

  lea rcx, [message]
  call printf

  xor eax, eax
  add rsp, 40
  ret