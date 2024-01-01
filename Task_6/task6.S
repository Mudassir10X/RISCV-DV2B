.text             
.globl _start
_start:
# ----------------------Start of Code----------------------
   
_start:
   la    t0, m_trap        // setting trap handler address
   csrw  mtvec, t0
   li    sp, 0x80005000    // setting stack pointer

# #  Setting PMP Regions address
   li    t0, 0x80001000
   srli  t0, t0, 2
   csrw  pmpaddr0, t0

   li    t1, 0x80001000
   srli  t1, t1, 2
   ori   t1, t1, 0x1FF
   csrw  pmpaddr1, t1

#  Configuring PMP Regions
   li    t2, 0x07079F8c
   csrw  pmpcfg0, t2

#  NAPOT: Store and load in M-Mode
   li    t0, 0x80001a00
   sw    t2, 0(t0)
   lw    t2, 0(t0)
   jalr  ra, t0, 0

   li    t2, 0x1
   csrs  mseccfg, t2
   li    t0, 0x80001a00
   sw    t2, 0(t0)
   lw    t2, 0(t0)
   jalr  ra, t0, 0
   li    t4, 2
   li    t5, 1
   bne   s0, t4, write_tohost
   bne   s0, t5, write_tohost

#  Bunch of nops for self checking
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop


#  jump to exit Routine
   j     write_tohost

#  TRAP-HANDLER
.align 4;
m_trap:  
#  Loading regs in Stack
   addi  sp, sp, -28
   sw    t0, 0(sp)
   sw    t1, 4(sp)
   sw    t2, 8(sp)
   sw    t3, 12(sp)
   sw    t4, 16(sp)
   sw    t5, 20(sp)
   sw    ra, 24(sp)
   j     check_cause

check_cause:
#  Checking mcause for appropriate trap handling
   csrr  t0, mcause
   li    t1, 0x1
   li    t2, 0x2
   li    t3, 0x7
   beq   t0, t1, i_instruction_fault
   beq   t0, t2, i_instruction_fault
   beq   t0, t3, ignore_exception
   j     ignore_exception   // If none of the above. just exit trap 

i_instruction_fault:
   csrw  mepc, ra    // In case of acess fault as I am going to NAPOT region and there is nothing present after that. thus returning to the ra where the jump was made.
   addi  s0, s0, 1       // Self-checking variable
   j     trap_exit

ignore_exception:    // Just ignore exception and leave trap-handler
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
   addi  s1, s1, 1       // Self-checking variable
   j     trap_exit

trap_exit:
#  Loading regs from Stack
   lw    t0, 0(sp)
   lw    t1, 4(sp)
   lw    t2, 8(sp)
   lw    t3, 12(sp)
   lw    t4, 16(sp)
   lw    t5, 20(sp)
   lw    ra, 24(sp)
   addi  sp, sp, 28
   mret     // Exiting Trap
   
# -----------------------End of Code-----------------------
write_tohost:
   li    x1, 1
   la    t0, tohost
   sw    x1, 0(t0)
   j     write_tohost

.data
.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;
