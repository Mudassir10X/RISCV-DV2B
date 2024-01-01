all: run 
.PHONNY: all
sail_run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task1.S -o task1.elf
	riscv_sim_RV32 task1.elf > sail.log
	riscv32-unknown-elf-objdump -d task1.elf

spike_debug:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task1.S -o task1.elf
	spike -d --log-commits --isa=rv32imac_zicsr task1.elf
	
spike_run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task1.S -o task1.elf
	spike --isa=RV32IMAFDC  -l --log-commits  task1.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task1.elf

