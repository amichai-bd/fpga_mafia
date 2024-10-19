#ifndef ACCEL_CORE_DEFINES_H
#define ACCEL_CORE_DEFINES_H

// macros
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)
#define NOP() __asm__("nop")

typedef unsigned int uint32_t;

#endif