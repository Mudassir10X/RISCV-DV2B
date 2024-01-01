all: run 
.PHONNY: all

debug:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task7.S -o task7.elf
	spike -d --log-commits --isa=rv32imac_smepmp task7.elf
	
run:
	riscv32-unknown-elf-gcc -march=rv32imac_smepmp -mabi=ilp32 -nostdlib -T linker.ld task7.S -o task7.elf
	spike --isa=rv32imac_smepmp  -l --log-commits  task7.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task7.elf
