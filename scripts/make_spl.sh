# ./scripts/make_spl.sh disk
gmake clean bin TARGET=starfive CLEAR=1 || exit 1
./spl_tool -c -f build/kernel.bin || exit 1
sudo dd if=build/kernel.bin.normal.out of=$1 bs=512 seek=4096 conv=fsync
