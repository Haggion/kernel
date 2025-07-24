TARGET = tmp/kernel.elf

GNATMAKE = riscv64-none-elf-gnatmake
LD = riscv64-none-elf-ld
AS = riscv64-none-elf-as
GCC = riscv64-none-elf-gcc -mcmodel=medany

CFLAGS = -ffreestanding -nostdlib -mno-relax -g -mcmodel=medany
ADAFLAGS = -gnatg -gnatA -gnatD -gnatec=src/gnat.adc -nostdlib -nostartfiles -Iruntime/src -I. -mcmodel=medany
# gnatp gnatn
SRC = src
TMP = tmp

ADA_SRC = $(wildcard $(SRC)/*.adb)
ASM_SRC = $(wildcard $(SRC)/*.s)
C_SRC = $(wildcard $(SRC)/*.c)

ADA_OBJ := $(patsubst $(SRC)/%.adb, $(TMP)/ada/%.o, $(ADA_SRC))
ASM_OBJ := $(patsubst $(SRC)/%.s,   $(TMP)/asm/%.o, $(ASM_SRC))
C_OBJ   := $(patsubst $(SRC)/%.c,   $(TMP)/c/%.o,   $(C_SRC))

OBJS = $(ASM_OBJ) $(C_OBJ) $(ADA_OBJ) runtime/build/adalib/*.o

all: $(TMP) $(TARGET)

$(TMP):
	mkdir -p $(TMP)/asm/
	mkdir -p $(TMP)/ada/
	mkdir -p $(TMP)/c/

$(TMP)/ada/%.o: $(SRC)/%.adb
	$(GNATMAKE) $< $(ADAFLAGS) -c -o $(@F)
	mv $(@F) $@

$(TMP)/asm/%.o: $(SRC)/%.s
	$(AS) -o $@ $<

$(TMP)/c/%.o: $(SRC)/%.c
	$(GCC) -c $< -o $@

$(TARGET): $(OBJS)
	$(LD) -T $(SRC)/linker.ld -o $@ $(OBJS)

clean:
	rm -f *.o *.ali *.dg $(TARGET)
	rm -rf $(TMP)
	rm -f esp.img image.iso

bin: all
	if [ ! -d "build" ]; then \
		mkdir build; \
	fi

	riscv64-none-elf-objcopy -O binary $(TARGET) build/kernel.bin

qemu-bin: bin
	qemu-system-riscv64 -machine virt -bios none -device loader,file=build/kernel.bin,addr=0x80000000 -serial mon:stdio -m 256M

qemu-elf: all
	qemu-system-riscv64 -machine virt -bios none -kernel tmp/kernel.elf -serial mon:stdio
