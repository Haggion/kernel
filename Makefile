CLEAR  ?= 0
TARGET ?= qemu
ARCH   ?= riscv

ELF := tmp/kernel.elf
SRC := src
TMP := tmp

TOOLCHAIN_PREFIX ?= riscv64-none-elf-
GNATMAKE := $(TOOLCHAIN_PREFIX)gnatmake
LD := $(TOOLCHAIN_PREFIX)ld
AS := $(TOOLCHAIN_PREFIX)as
GCC := $(TOOLCHAIN_PREFIX)gcc -mcmodel=medany

ADA_DIRS := $(shell find $(SRC) -type f \( -name '*.adb' -o -name '*.ads' \) | xargs -n1 dirname | sort -u)
ADA_INCLUDES := $(addprefix -I$(shell pwd)/, $(ADA_DIRS))

CFLAGS := -ffreestanding -nostdlib -mno-relax -g -mcmodel=medany
ADAFLAGS := -gnatg -gnatA -gnatD -gnatec=$(shell pwd)/src/gnat.adc -nostdlib -nostartfiles -I$(shell pwd)/runtime/src $(ADA_INCLUDES) -mcmodel=medany
# gnatp gnatn
ADAPROJFLAGS := -gnatg -gnatA -gnatD -gnatec=src/gnat.adc -nostdlib

ADA_SRC := $(shell find $(SRC) -type f -name '*.adb')
ASM_SRC := $(shell find $(SRC) -type f -name '*.s')
C_SRC := $(shell find $(SRC) -type f -name '*.c')
ARCH_SRC := $(shell find targets/$(TARGET) -type f -name '*.s')

ADA_OBJ := $(foreach f,$(ADA_SRC), $(TMP)/ada/$(subst $(SRC)/,,$(f:.adb=.o)))
C_OBJ   := $(foreach f,$(C_SRC),	  $(TMP)/c/$(subst $(SRC)/,,$(f:.c=.o)))
ASM_OBJ := $(foreach f,$(ASM_SRC), $(TMP)/asm/$(subst $(SRC)/,,$(f:.s=.o)))
ARCH_OBJ := $(foreach f,$(ARCH_SRC), $(TMP)/arch/$(subst ,,$(f:.s=.o)))

OBJS = $(ASM_OBJ) $(ARCH_OBJ) $(C_OBJ) $(ADA_OBJ) runtime/build/adalib/*.o

all: $(TMP) $(ELF)

$(TMP):
	mkdir -p $(TMP)/asm/
	mkdir -p $(TMP)/ada/
	mkdir -p $(TMP)/c/

$(TMP)/ada/%.o:
	mkdir -p $(dir $@)
	cd $(dir $@) && \
	$(GNATMAKE) -c $(ADAFLAGS) \
	  -o $(notdir $@) \
	  $(abspath $(patsubst $(TMP)/ada/%.o,$(SRC)/%.adb,$@))

$(TMP)/c/%.o:
	mkdir -p $(dir $@)
	$(GCC) -c $(patsubst %.o,%.c,$(subst $(TMP)/c/,src/,$@)) -o $@

$(TMP)/asm/%.o:
	mkdir -p $(dir $@)
	$(AS) -o $@ $(patsubst %.o,%.s,$(subst $(TMP)/asm/,src/,$@))

$(TMP)/arch/%.o:
	mkdir -p $(dir $@)
	$(AS) -o $@ $(patsubst %.o,%.s,$(subst $(TMP)/arch/,,$@))

$(ELF): $(OBJS)
	$(LD) -T $(SRC)/linker.ld -o $@ $(OBJS)

clean:
	rm -rf $(TMP)

bin: all
	if [ ! -d "build" ]; then \
		mkdir build; \
	fi

	$(TOOLCHAIN_PREFIX)objcopy -O binary $(ELF) build/kernel.bin --remove-section .riscv.attributes

.PHONY: runtime
runtime:
	cd runtime; \
	./setup-runtime.sh

qemu-bin: bin
ifeq ($(CLEAR),1)
	clear
endif
	@qemu-system-riscv64 -machine virt -bios default -device loader,file=build/kernel.bin,addr=0x80000000 -serial mon:stdio -m 256M -device ramfb -device virtio-keyboard-device

qemu-elf: all
	qemu-system-riscv64 -machine virt -bios none -kernel $(ELF) -serial mon:stdio
