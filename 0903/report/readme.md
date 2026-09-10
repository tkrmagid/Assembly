# report1

1. In an 8-bit binary number, which is the most significant bit (MSB)?
    > 가장 왼쪽 비트 bit7

2. What is the decimal representation of each of the following unsigned binary integers?
    > a. 00110101: 32 + 16 + 4 + 1 = 53  
      b. 10010110: 128 + 16 + 4 + 2 = 150  
      c. 11001100: 128 + 64 + 8 + 4 = 204

3. What is the sum of each pair of binary integers?
    > a. 10101111 + 11011011: 110001010  
      b. 10010111 + 11111111: 110010110  
      c. 01110101 + 10101100: 100100001

4. Calculate binary 00001101 minus 00000111.
    > 00000110 (십진수: 13 - 7 = 6)

5. How many bits are used by each of the following data types?
    > a. word: 16 bits (2 bytes)  
      b. doubleword: 32 bits (4 bytes)  
      c. quadword: 64 bits (8 bytes)  
      d. double quadword: 128 bits (16 bytes)

6. What is the minimum number of binary bits needed to represent each of the following unsigned decimal integers?
    > a. 4095: 12 bits  
      b. 65534: 16 bits  
      c. 42319: 16 bits

7. What is the hexadecimal representation of each of the following binary numbers?
    > a. 0011 0101 1101 1010: 35DA  
      b. 1100 1110 1010 0011: CEA3  
      c. 1111 1110 1101 1011: FEDB

8. What is the binary representation of the following hexadecimal numbers?
    > a. 0126F9D4: 0000 0001 0010 0110 1111 1001 1101 0100  
      b. 6ACDFA95: 0110 1010 1100 1101 1111 1010 1001 0101  
      c. F69BDC2A: 1111 0110 1001 1011 1101 1100 0010 1010

9. What is the unsigned decimal representation of each of the following hexadecimal integers?
    > a. 3A: 58  
      b. 1BF: 447  
      c. 1001: 4097

10. What is the unsigned decimal representation of each of the following hexadecimal integers?
    > a. 62: 98  
      b. 4B3: 1203  
      c. 29F: 671

11. What is the 16-bit hexadecimal representation of each of the following signed decimal integers?
    > a. -24: FFE8  
      b. -331: FEB5

12. What is the 16-bit hexadecimal representation of each of the following signed decimal integers?
    > a. -21: FFEB  
      b. -45: FFD3

13. The following 16-bit hexadecimal numbers represent signed integers. Convert each to decimal.
    > a. 6BF9: 27641  
      b. C123: -16093

14. The following 16-bit hexadecimal numbers represent signed integers. Convert each to decimal.
    > a. 4CD2: 19666  
      b. 8230: -32208 (검산 결과 정정: 33328 - 65536 = -32208)

15. What is the decimal representation of each of the following signed binary numbers?
    > a. 10110101: -75  
      b. 00101010: 42  
      c. 11110000: -16

16. What is the decimal representation of each of the following signed binary numbers?
    > a. 10000000: -128  
      b. 11001100: -52  
      c. 10110111: -73

17. What is the 8-bit binary (two's-complement) representation of each of the following signed decimal integers?
    > a. -5: 11111011  
      b. -42: 11010110  
      c. -16: 11110000

18. What is the 8-bit binary (two's-complement) representation of each of the following signed decimal integers?
    > a. -72: 10111000  
      b. -98: 10011110  
      c. -26: 11100110

19. What is the sum of each pair of hexadecimal integers?
    > a. 6B4 + 3FE: AB2  
      b. A49 + 6BD: 1106

20. What is the sum of each pair of hexadecimal integers?
    > a. 7C4 + 3BE: B82  
      b. B69 + 7AD: 1316

21. What are the hexadecimal and decimal representations of the ASCII character capital B?
    > 10진수(Decimal): 66  
      16진수(Hexadecimal): 42

22. What are the hexadecimal and decimal representations of the ASCII character capital G?
    > 10진수(Decimal): 71  
      16진수(Hexadecimal): 47

23. Challenge: What is the largest decimal value you can represent, using a 129-bit unsigned integer?
    > 2^129 - 1

24. Challenge: What is the largest decimal value you can represent, using an 86-bit signed integer?
    > 2^85 - 1

25. Create a truth table to show all possible inputs and outputs for the boolean function described by ¬(A∨B).
    > | A | B | A∨B | ¬(A∨B) |
      |---|---|---|---|
      | 0 | 0 | 0 | 1 |
      | 0 | 1 | 1 | 0 |
      | 1 | 0 | 1 | 0 |
      | 1 | 1 | 1 | 0 |

26. Create a truth table for (¬A∧¬B) and compare it with question 25.
    > | A | B | ¬A | ¬B | ¬A∧¬B |
      |---|---|---|---|---|
      | 0 | 0 | 1 | 1 | 1 |
      | 0 | 1 | 1 | 0 | 0 |
      | 1 | 0 | 0 | 1 | 0 |
      | 1 | 1 | 0 | 0 | 0 |
      
      25번과 결과가 동일함 → 드모르간 법칙 ¬(A∨B) = ¬A∧¬B 성립 확인

27. If a boolean function has four inputs, how many rows are required for its truth table?
    > 2^4 = 16행

28. How many selector bits are required for a four-input multiplexer?
    > 2비트