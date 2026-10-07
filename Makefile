all: out/os.iso

out/os.iso: src/boot.asm src/kernel.c linker.ld grub.cfg
	mkdir out
	mkdir build
	mkdir -p isodir/boot/grub
	cp grub.cfg isodir/boot/grub/grub.cfg
	nasm -f elf64 src/boot.asm -o build/boot.o
	x86_64-elf-gcc \
    	-ffreestanding \
    	-m64 \
    	-mno-red-zone \
    	-O2 \
    	-c \
    	src/kernel.c \
		-o build/kernel.o
	x86_64-elf-gcc \
    	-ffreestanding \
    	-m64 \
    	-mno-red-zone \
    	-O2 \
    	-c \
    	src/output.c \
		-o build/output.o
	x86_64-elf-gcc \
    	-ffreestanding \
    	-m64 \
    	-mno-red-zone \
    	-O2 \
    	-c \
    	src/memory.c \
		-o build/memory.o
	x86_64-elf-ld \
    	-T linker.ld \
    	-o build/kernel.elf \
    	build/boot.o \
		build/kernel.o \
		build/output.o \
		build/memory.o
	cp build/kernel.elf isodir/boot/kernel.elf
	grub-mkrescue isodir -o out/os.iso

clean: 
	rm -rf build
	rm -rf isodir
	rm -rf out

run:
	qemu-system-x86_64 -cdrom out/os.iso -boot d -display curses

debug:
	qemu-system-x86_64 -cdrom out/os.iso -s -S -display curses
