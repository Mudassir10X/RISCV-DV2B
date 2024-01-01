.text             
.globl _start
_start:
# ----------------------Start of Code----------------------
   
_start:
   la    t0, m_trap        // setting M trap handler address
   csrw  mtvec, t0
   la    t1, s_trap        // setting S trap handler address
   csrw  stvec, t1
   li    t2, 0x104
   csrw  medeleg, t2
   li    sp, 0x80005000    // setting stack pointer

#  Jump to U-Mode
   li    a0, 1             // argument a0 = 1 (U-Mode)
   jal   change_mode


   
#  Bunch of nop's
   nop
   nop
   nop

#  Illegal instruction exception
   csrr  t3, sstatus 
   ecall

#  jump to exit Routine
   j     write_tohost

#  Mode Changing Function
change_mode:
   csrw  mepc, ra
   li    t0, 1
   beq   a0, zero, _super
   beq   a0, t0,   _user   

_super:
   li    t2, 0x1800     // Clearing MPP bits
   csrc  mstatus, t2
   li    t3, 0x800      // setting MPP bits to S mode (01)
   csrs  mstatus, t3
   lw    ra, 0(sp)
   addi  sp, sp, 4
   mret

_user:
   li    t2, 0x1800     // Clearing MPP bits
   csrc  mstatus, t2    // setting MPP bits to U mode (00)
   mret

#  Machine Mode TRAP-HANDLER
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
   j     m_check_cause

m_check_cause:
#  Checking mcause for appropriate trap handling
   csrr  t0, mcause
   li    t1, 0x5
   li    t2, 0x7
   li    t3, 0x9
   li    t4, 0xb
   beq   t0, t1, m_ignore_exception
   beq   t0, t2, m_ignore_exception
   beq   t0, t3, m_ecall_escape
   beq   t0, t4, m_ecall_escape
   j     m_trap_exit   // If none of the above. just exit trap 

m_trap_to_s:           // Return in S mode
   li    t1, 0x800
   or    t0, t0, t1
   csrs  mstatus, t0
   j     m_trap_exit

m_trap_to_m:           // Return in M mode
   li    t1, 0x1800
   or    t0, t0, t1
   csrs  mstatus, t0
   j     m_trap_exit

m_ecall_escape:        // Just raise mode to M and leave trap-handler
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
   j     m_trap_to_m

m_ignore_exception:    // Just ignore exception and leave trap-handler
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
   j     m_trap_exit
   
m_trap_exit:
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


#  Supervisor Mode TRAP-HANDLER
.align 4;
s_trap:  
#  Loading regs in Stack
   addi  sp, sp, -28
   sw    t0, 0(sp)
   sw    t1, 4(sp)
   sw    t2, 8(sp)
   sw    t3, 12(sp)
   sw    t4, 16(sp)
   sw    t5, 20(sp)
   sw    ra, 24(sp)
   j     s_check_cause

s_check_cause:
#  Checking scause for appropriate trap handling
   csrr  t0, scause
   li    t1, 0x2
   li    t2, 0x8
   beq   t0, t1, s_trap_to_s
   beq   t0, t2, s_uecall_escape
   j     s_trap_exit   // If none of the above. just exit trap 

s_trap_to_s:           // Return in S mode
   li    t1, 0x100
   or    t0, t0, t1
   csrs  sstatus, t0
   j     s_trap_exit

s_uecall_escape:       // Just raise mode to S and leave trap-handler
   csrr  t2, sepc
   addi  t2, t2, 4
   csrw  sepc, t2
   j     s_trap_to_s

# s_i_instruction_fault:
   # csrw  sepc, ra    // In case of acess fault 
   # j     s_trap_exit

s_trap_exit:
#  Loading regs from Stack
   lw    t0, 0(sp)
   lw    t1, 4(sp)
   lw    t2, 8(sp)
   lw    t3, 12(sp)
   lw    t4, 16(sp)
   lw    t5, 20(sp)
   lw    ra, 24(sp)
   addi  sp, sp, 28
   sret     // Exiting Trap

# -----------------------End of Code-----------------------
write_tohost:
   li    x1, 1
   la    t0, tohost
   sw    x1, 0(t0)
   j     write_tohost

.data
.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;
