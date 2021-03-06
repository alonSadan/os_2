#include "asm.h"
#include "mmu.h"

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
  pushl %es
  pushl %fs
  pushl %gs
  pushal
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
  movw %ax, %ds
  movw %ax, %es

  # Call trap(tf), where tf=%esp
  pushl %esp
  call trap
  addl $4, %esp

  # Return falls through to trapret...
.globl trapret
.global afterhandling
trapret:
  pushl %esp
  call handlingSignals
  addl $4, %esp
afterhandling:

  popal
  popl %gs
  popl %fs
  popl %es
  popl %ds
  addl $0x8, %esp  # trapno and errcode
  iret


#include "syscall.h"
#include "traps.h"

.globl invoke_sigret_start
.globl invoke_sigret_end

invoke_sigret_start:
  movl $SYS_sigret, %eax
  int $T_SYSCALL
invoke_sigret_end: