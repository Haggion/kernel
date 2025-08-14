riscv64-none-elf-objdump -d -M numeric,no-aliases tmp/kernel.elf | grep $1 -C 10 
