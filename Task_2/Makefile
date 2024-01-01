all: run 
.PHONNY: all
run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task2.S -o task2.elf
	riscv_sim_RV32 -P task2.elf > sail.log
	spike --isa=RV32IMAFDC  -l --log-commits  task2.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task2.elf

sail_run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task2.S -o task2.elf
	riscv_sim_RV32 -P task2.elf > sail.log
	riscv32-unknown-elf-objdump -d task2.elf

spike_debug:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task2.S -o task2.elf
	spike -d --log-commits --isa=rv32imac_zicsr task2.elf
	
spike_run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task2.S -o task2.elf
	spike --isa=RV32IMAFDC  -l --log-commits  task2.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task2.elf