[bits 32]

section .multiboot
align 4
	dd 0x1BADB002
	dd 0x00000002
	dd -(0x1BADB002 + 0x00000002)

section .text
global _start
_start:
	mov byte [0xb8002], 'O'
	mov byte [0xb8003], 0x0f
	mov byte [0xb8004], 'K'
	mov byte [0xb8005], 0x0f

	hlt
	jmp $
