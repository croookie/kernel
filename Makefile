all: my_kernel.iso

my_kernel.iso: boot.asm linker.ld grub.cfg
	mkdir -p isodir/boot/grub
	cp grub.cfg isodir/boot/grub/grub.cfg
	nasm -f elf32 boot.asm -o boot.o
	ld -m elf_i386 -T linker.ld -o my_kernel.elf boot.o 
	cp my_kernel.elf isodir/boot/my_kernel.elf
	grub-mkrescue isodir -o my_os.iso

clean: 
	rm -rf isodir
	rm boot.o
	rm my_kernel.elf
	rm my_os.iso

run:
	qemu-system-i386 -cdrom my_os.iso -boot d -display curses
