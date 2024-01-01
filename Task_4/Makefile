all: run 
.PHONNY: all
run:
	riscv32-unknown-elf-gcc -march=rv32imafc_zicsr -mabi=ilp32 -nostdlib -T linker.ld task4.S -o task4.elf
	riscv_sim_RV32 task4.elf > sail.log
	spike --isa=RV32IMAFDC  -l --log-commits  task4.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task4.elf

sail_run:
	riscv32-unknown-elf-gcc -march=rv32imafc_zicsr -mabi=ilp32 -nostdlib -T linker.ld task4.S -o task4.elf
	riscv_sim_RV32 task4.elf > sail.log
	riscv32-unknown-elf-objdump -d task4.elf

spike_debug:
	riscv32-unknown-elf-gcc -march=rv32imafc_zicsr -mabi=ilp32 -nostdlib -T linker.ld task4.S -o task4.elf
	spike -d --log-commits --isa=rv32imafc_zicsr task4.elf
	
spike_run:
	riscv32-unknown-elf-gcc -march=rv32imafc_zicsr -mabi=ilp32 -nostdlib -T linker.ld task4.S -o task4.elf
	spike --isa=RV32IMAFDC  -l --log-commits  task4.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task4.elf
