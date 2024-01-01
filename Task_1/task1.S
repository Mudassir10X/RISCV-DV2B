
.data
.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;

.text             
.globl _start
_start:
# ----------------------Start of Code----------------------
   
_start:
   la    t0, m_trap
   csrw  mtvec, t0
   li    sp, 0x80005000
   li    a0, 0
   jal   change_mode
   nop
   ecall
   li    a0, 1
   jal   change_mode
   j     write_tohost

m_trap:
   csrr  t2, mepc
   addi  t2, t2, 4
   csrw  mepc, t2
   csrr  t0, mcause
   li    t1, 0x8
   li    t2, 0x9
   beq   t0, t1, trap_to_s
   beq   t0, t2, trap_to_m
   mret

trap_to_s:
   li    t1, 0x00000800
   or    t0, t0, t1
   csrs  mstatus, t0
   mret

trap_to_m:
   li    t1, 0x1800
   or    t0, t0, t1
   csrs  mstatus, t0
   mret

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
   mret
_user:
   li    t2, 0x1800     // Clearing MPP bits
   csrc  mstatus, t2    // setting MPP bits to U mode (00)
   mret



  
   
# -----------------------End of Code-----------------------
write_tohost:
   li x1, 1
   la t0, tohost
   sw x1, 0(t0)
   j write_tohost

