rm -f build/adainclude/*
rm -f build/adalib/*
rm -f obj/*

for f in ./src/*.adb; do
	riscv64-none-elf-gnatmake -c -gnatg -gnatA -nostdlib -nostartfiles -I./src -D ./obj -a "$f"
done

cp -f src/*.ads build/adainclude/
cp -f obj/*.ali obj/*.o build/adalib/
