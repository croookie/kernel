all: out/os.iso

out/os.iso: src/boot.asm linker.ld grub.cfg
	mkdir out
	mkdir build
	mkdir -p isodir/boot/grub
	cp grub.cfg isodir/boot/grub/grub.cfg
	nasm -f elf32 src/boot.asm -o build/boot.o
	ld -m elf_i386 -T linker.ld -o build/kernel.elf build/boot.o 
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
