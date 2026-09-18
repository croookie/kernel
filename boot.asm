[bits 32]

section .multiboot
align 4
	dd 0x1BADB002
	dd 0x00000002
	dd -(0x1BADB002 + 0x00000002)

section .text
global _start
_start:
	mov byte [0xb8002], 'B'
	mov byte [0xb8003], 0x0f
	mov byte [0xb8004], 'o'
	mov byte [0xb8005], 0x0f
	mov byte [0xb8006], 'o'
	mov byte [0xb8007], 0x0f
	mov byte [0xb8008], 't'
	mov byte [0xb8009], 0x0f
	mov byte [0xb800a], 'e'
	mov byte [0xb800b], 0x0f
	mov byte [0xb800c], 'd'
	mov byte [0xb800d], 0x0f

	extern kernel_start
	extern kernel_end

	mov eax, kernel_start
	mov ebx, kernel_end
	; entering long mode
	;mov eax, cr0
	;and eax, 0x7fffffff
	;mov cr0, eax
;
	;mov eax, cr4
	;or eax, 1 << 5
	;mov cr4, eax
	hlt
	jmp $

section .bss
align 16
stack_bottom:
	resb 16384
stack_top:

align 4096
pml4:
	resb 4096
pdpt:
	resb 4096
pd:
	resb 4096
pt:
	resb 4096
