all: run 
.PHONNY: all
run:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task5.S -o task5.elf
	riscv_sim_RV32 task5.elf > sail.log
	spike --isa=RV32IMAFDC  -l --log-commits  task5.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task5.elf

sail_run:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task5.S -o task5.elf
	riscv_sim_RV32 -P task5.elf > sail.log
	riscv32-unknown-elf-objdump -d task5.elf

spike_debug:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task5.S -o task5.elf
	spike -d --log-commits --isa=rv32imac_smepmp task5.elf
	
spike_run:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task5.S -o task5.elf
	spike --isa=RV32IMAFDC  -l --log-commits  task5.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task5.elf

diss:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task5.S -o task5.elf
	riscv32-unknown-elf-objdump -d task5.elf
