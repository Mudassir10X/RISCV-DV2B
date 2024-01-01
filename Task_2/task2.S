.text             
.globl _start
_start:
# ----------------------Start of Code----------------------
   
_start:
   la    t0, m_trap        // setting trap handler address
   csrw  mtvec, t0
   li    sp, 0x80005000    // setting stack pointer

#  Setting PMP Regions address
   li    t0, 0x80001000
   srli  t0, t0, 2
   csrw  pmpaddr0, t0

   li    t1, 0x80001000
   srli  t1, t1, 2
   ori   t1, t1, 0x1FF
   csrw  pmpaddr1, t1

#  Configuring PMP Regions
   li    t2, 0x0707190C
   csrw  pmpcfg0, t2

#  Jump to S-Mode
   li    a0, 0             // argument a0 = 0 (S-Mode)
   jal   change_mode

   
#  Bunch of nop's to test that the PMP TOR region has execute permissions
   nop
   nop
   nop
   nop
   nop

#  TOR: Store and load in S-Mode
   li    t0, 0x80000a00
   sw    t2, 0(t0)
   lw    t2, 0(t0)

#  NAPOT: Store and load in S-Mode
   li    t0, 0x80001a00
   sw    t2, 0(t0)
   lw    t2, 0(t0)
   jalr  ra, t0, 0

#  Back in machine mode and now applying PMP for M mode
   ecall
   
   nop 
   nop
   li    t2, 0x0707998C
   csrw  pmpcfg0, t2


#  TOR: Store and load in M-Mode
   li    t0, 0x80000a00
   sw    t2, 0(t0)
   lw    t2, 0(t0)

#  NAPOT: Store and load in M-Mode
   li    t0, 0x80001a00
   sw    t2, 0(t0)
   lw    t2, 0(t0)
   jalr  ra, t0, 0

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
   li    t2, 0x5
   li    t3, 0x7
   beq   t0, t1, i_access_fault
   beq   t0, t2, ignore_exception
   beq   t0, t3, ignore_exception
   li    t1, 0x8
   li    t2, 0x9
   li    t3, 0xb
   beq   t0, t1, uecall_escape
   beq   t0, t2, ecall_escape
   beq   t0, t3, ecall_escape
   j     trap_exit   // If none of the above. just exit trap 

trap_to_s:           // Return in S mode
   li    t1, 0x800
   or    t0, t0, t1
   csrs  mstatus, t0
   j     trap_exit

trap_to_m:           // Return in M mode
   li    t1, 0x1800
   or    t0, t0, t1
   csrs  mstatus, t0
   j     trap_exit

ecall_escape:        // Just raise mode to M and leave trap-handler
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
   j     trap_to_m

uecall_escape:       // Just raise mode to S and leave trap-handler
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
   j     trap_to_s

i_access_fault:
   csrw  mepc, ra    // In case of acess fault as I am going to NAPOT region and there is nothing present after that. thus returning to the ra where the jump was made.
   j     trap_exit

ignore_exception:    // Just ignore exception and leave trap-handler
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
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
