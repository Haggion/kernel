# ./scripts/put_bin.sh partition
gmake clean TARGET=starfive bin || exit 1
diskutil mount $1 || exit 1
# misnominer
cp -f build/kernel.bin /Volumes/BOOT/boot/kernel.bin
diskutil unmount $1
