riscv64-none-elf-gnatmake -c $1.adb -nostdlib -gnatA \
	-I./runtime/build/adainclude -aI./runtime/build/adainclude \
	-aO./runtime/build/adalib

riscv64-none-elf-gcc -nostdlib -T linker.ld $1.o runtime/build/adalib/*.o -o kernel.elf
