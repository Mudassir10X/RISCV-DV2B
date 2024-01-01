all: run 
.PHONNY: all

debug:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task6.S -o task6.elf
	spike -d --log-commits --isa=rv32imac_smepmp task6.elf
	
run:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task6.S -o task6.elf
	spike --isa=rv32imac_smepmp  -l --log-commits  task6.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task6.elf
