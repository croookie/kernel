[org 0x100000]

align 4
MULTIBOOT_HEADER:
	dd 0x1BADB002
	dd 0x00010002
	dd -(0x1BADB002 + 0x00010002)
	dd MULTIBOOT_HEADER
	dd 0x100000
	dd 0
	dd 0
	dd _start

_start:
	hlt
	jmp $
