# The Haggion Kernel
This repository contains the source of the monolithic kernel of the Haggion operating system.

![Photo of the kernel being ran on a DC-ROMA Framework laptop](https://jahanrashidi.com/assets/haggion/dc-roma.jpeg)

## About Haggion
Haggion is a small OS designed for notetaking and personal automation.

## About the kernel
The kernel is written primarily in Ada, with large portions (drivers especially) written in assembly, and a few bits in C.

### Features
- An unorthodox link based file system
- A built in powerful scripting language for personal automation and writing simple programs
- Made for RISC-V processors
- Designed for modern hardware

## Building
To build this project, you need a toolchain supporting compilation to RISC-V binaries for both GCC and GNAT. Provided in [scripts](./scripts/) is a [make-cross-compilers.sh](./scripts/make-cross-compilers.sh) file which is designed for making such a toolchain on an M-series Mac.

Running `make all` will produce an elf file, and `make bin` a bin file. For running on QEMU, `make qemu-bin` can be used also.

Specify the architecture you'll be building for with the `TARGET=` option.

Inside the [scripts](./scripts/) folder are a number of files which automate some of the build process, [qemu.sh](./scripts/qemu.sh) being useful for quickly creating a fresh build of the project and running it on QEMU, and [put_bin.sh](./scripts/put_bin.sh) for creating a bin targeted towards StarFive computers and putting it on a partition specified by it's first parameter (`./scripts/put_bin.sh /dev/diskXsY`.)

### Supported devices
Officially this kernel only supports the DC-ROMA RISC-V Framework 13 mainboard/laptop. Drivers are also being developed for QEMU, but it is not a priority. It should work on related computers (other DC-ROMA laptops, StarFive boards,) but it has only been tested on that one type of computer.

## Configuration
The [architecture](./architecture/) folder contains configurations for the specified `TARGET=`. The configuration files specify the default drivers for the build, which can be changed from within the kernel, but only if you've got enough working for it to do so. Thus, if your device doesn't fit readily into any of the predefined targets you can create a new configuration yourself. To do so, just create a new folder with the name of your architecture (this is what will be put after `TARGET=`,) copy one of the config.s files from another architecture, and choose the configurations which fit your machine.
