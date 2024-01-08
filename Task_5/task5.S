.text
.globl _start
_start:
# ----------------------Start of Code----------------------
   
_start:
   la    t0, m_trap        // setting trap handler address
   csrw  mtvec, t0
   
#  Setting PMP TOR Region address
   li    t0, 0xFFFFFFFF
   srli  t0, t0, 2
   csrw  pmpaddr0, t0

#  Configuring PMP TOR Region
   li    t1, 0x0F
   csrw  pmpcfg0, t1

   li   a0, 0x80000000     # Setting Physical Address
   li   a1, 0xF            # Setting permissions [DAGUXWRV](8'b00001111)
   li   a2, 0x80000000     # Setting Virtual Address for one to one mapping
   
   jal  _setup_pte         # Function to setup Page Table Entry

   jal  _set_SATP          # Function to set the SATP register

   li   a0, 0              # Argument (0=>S-Mode, 1=>U-Mode)   
   jal  change_mode

#  bunch of nop's
   nop
   nop
   nop
   nop
   nop
   nop

#  Jump to exit routine
   j     write_tohost


#  Function to Setup Page table entry
_setup_pte:
      la   t0, root_page_table     # Page Table Root Address
      srli t1, a2, 22
      slli t1, t1, 2
      # Create PTE by getting PPN and adding permissions bit
      srli a0, a0, 12
      slli a0, a0, 10
      or   a0, a0, a1
      add  t0, t0 ,t1
      sw   a0, 0(t0)
   ret

#  Function to set the SATP register
_set_SATP:
   la   t0, root_page_table
   srli t0, t0, 12         # PPN of Page table root
   li   t1, 0x80000000     # Mode = SV32
   or   t0, t0, t1
   csrw satp, t0
   ret

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
   li    t4, 0xc
   beq   t0, t1, ignore_exception
   beq   t0, t2, ignore_exception
   beq   t0, t3, ignore_exception
   beq   t0, t4, write_tohost       // If page fault occurs then exit (Self Checking)
   j     ignore_exception   // If none of the above. just ignore exception 

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
   csrw  mepc, ra    // In case of acess fault 
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
.align 4                                                      
    root_page_table:                                                       
        .word 4096
.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;