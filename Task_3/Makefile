all: run 
.PHONNY: all
run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task3.S -o task3.elf
	riscv_sim_RV32 task3.elf > sail.log
	spike --isa=RV32IMAFDC  -l --log-commits  task3.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task3.elf

sail_run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task3.S -o task3.elf
	riscv_sim_RV32 task3.elf > sail.log
	riscv32-unknown-elf-objdump -d task3.elf

spike_debug:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task3.S -o task3.elf
	spike -d --log-commits --isa=rv32imac_zicsr task3.elf
	
spike_run:
	riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -T linker.ld task3.S -o task3.elf
	spike --isa=RV32IMAFDC  -l --log-commits  task3.elf 1>spike.out 2>spike.log
	riscv32-unknown-elf-objdump -d task3.elf
