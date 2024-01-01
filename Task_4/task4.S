.text             
.globl _start
_start:
# ----------------------Start of Code----------------------
   
_start:
   li    sp, 0x80005000    // setting stack pointer

#  checking if FS is OFF
   li    a0, 0             // at first the FS should be OFF (00)
   jal   check_FS

#  Initializing FS 
   li    t0, 0x2000
   csrs  mstatus, t0       // Initializing FS (01)
   
#  checking FS to be clean. (01)
   li    a0, 1             
   jal   check_FS

#  Performing some Floating operations
   addi  t1, x0, 200
   addi  t2, x0, 50
   nop
   nop
   fcvt.s.w f0, t1
   fcvt.s.w f1, t2
   fadd.s   f3, f0, f1

#  Checking if FS is dirty now (11)
   li    a0, 3
   jal   check_FS

#  jump to exit Routine
   j     write_tohost

#  Check_FS function for self-checking
check_FS:   
   csrr  t2, mstatus
   li    t4, 0x6000
   and   t3, t2, t4
   srli  t3, t3, 13
   bne   t3, a0, write_tohost    // if FAIL, the program will exit immediately
   ret                           // if PASS, the program will return and continue execution

# -----------------------End of Code-----------------------
write_tohost:
   li    x1, 1
   la    t0, tohost
   sw    x1, 0(t0)
   j     write_tohost

.data
.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;
