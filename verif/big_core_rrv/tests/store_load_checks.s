     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  1   
  li    x2,  2
  li    x3,  3
  li    x4,  4
  li    x5,  5
  li    x6,  6
  li    x7,  7
  li    x8,  8
  li    x10, 65600

  sw	x1, 0(x10)
  lw	x9, 0(x10)
  
     
eot:
    nop
    nop
    nop
    nop
    nop
    ebreak
    nop
    nop
    nop
     .size     main, .-main
     .ident     "GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"
     