TARGET = tmp/kernel.elf

GNATMAKE = riscv64-none-elf-gnatmake
LD = riscv64-none-elf-ld
AS = riscv64-none-elf-as
GCC = riscv64-none-elf-gcc -mcmodel=medany

CFLAGS = -ffreestanding -nostdlib -mno-relax -g -mcmodel=medany
ADAFLAGS = -gnatg -gnatA -gnatD -gnatec=src/gnat.adc -nostdlib -nostartfiles -Iruntime/src -I. -mcmodel=medany
# gnatp gnatn
ADAPROJFLAGS = -gnatg -gnatA -gnatD -gnatec=src/gnat.adc -nostdlib

SRC = src
TMP = tmp

ADA_SRC = $(shell find $(SRC) -type f -name '*.adb')
ASM_SRC = $(shell find $(SRC) -type f -name '*.s')
C_SRC = $(shell find $(SRC) -type f -name '*.c')

ADA_OBJ := $(patsubst $(SRC)/%.adb, $(TMP)/ada/%.o, $(ADA_SRC))
ASM_OBJ := $(patsubst $(SRC)/%.s,   $(TMP)/asm/%.o, $(ASM_SRC))
C_OBJ   := $(patsubst $(SRC)/%.c,   $(TMP)/c/%.o,   $(C_SRC))

OBJS = $(ASM_OBJ) $(C_OBJ) $(ADA_OBJ) runtime/build/adalib/*.o

all: $(TMP) $(TARGET)
#	$(GNATMAKE) -P kernel.gpr

$(TMP):
	mkdir -p $(TMP)/asm/
	mkdir -p $(TMP)/ada/
	mkdir -p $(TMP)/c/

$(TMP)/ada/%.o: $(SRC)/%.adb
	mkdir -p $(dir $@)
	$(GNATMAKE) $< $(ADAFLAGS) -c -o $(@F)
	mv $(@F) $@

$(TMP)/asm/%.o: $(SRC)/%.s
	mkdir -p $(dir $@)
	$(AS) -o $@ $<

$(TMP)/c/%.o: $(SRC)/%.c
	mkdir -p $(dir $@)
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
	clear
	qemu-system-riscv64 -machine virt -bios none -device loader,file=build/kernel.bin,addr=0x80000000 -serial mon:stdio -m 256M

qemu-elf: all
	qemu-system-riscv64 -machine virt -bios none -kernel tmp/kernel.elf -serial mon:stdio
