TARGET = tmp/kernel.elf

GNATMAKE = riscv64-none-elf-gnatmake
LD = riscv64-none-elf-ld
AS = riscv64-none-elf-as
GCC = riscv64-none-elf-gcc

CFLAGS = -ffreestanding -nostdlib -mno-relax -g
ADAFLAGS = -gnatg -gnatA -nostdlib -nostartfiles -Iruntime/src -I.

SRC = src/
OBJS = tmp/asm/boot.o runtime/build/adalib/*.o tmp/asm/io.o tmp/ada/io.o tmp/ada/kernel.o

all: tmp $(TARGET)

tmp:
	mkdir -p tmp/asm/
	mkdir -p tmp/ada/

tmp/asm/boot.o: $(SRC)boot.s
	$(AS) -o $@ $<

tmp/asm/io.o: $(SRC)io.s
	$(AS) -o $@ $<

tmp/ada/kernel.o: $(SRC)kernel.adb
	$(GNATMAKE) $(SRC)kernel $(ADAFLAGS) -c -o $@
	mv kernel.o tmp/ada/kernel.o

tmp/ada/io.o: $(SRC)io.adb
	$(GNATMAKE) $(SRC)io $(ADAFLAGS) -c -o $@
	mv io.o tmp/ada/io.o

$(TARGET): tmp/asm/io.o tmp/ada/kernel.o tmp/asm/boot.o tmp/ada/io.o
	$(LD) -T $(SRC)linker.ld -o $(TARGET) $(OBJS)

clean:
	rm -f *.o *.ali $(TARGET)
	rm -rf tmp
	rm -f esp.img image.iso

bin: all
	if [ ! -d "build" ]; then \
		mkdir build; \
	fi

	riscv64-none-elf-objcopy -O binary $(TARGET) build/kernel.bin

qemu-bin: bin
	qemu-system-riscv64 -machine virt -bios none -device loader,file=build/kernel.bin,addr=0x80000000 -serial mon:stdio
