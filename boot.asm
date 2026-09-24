[bits 32]

section .data
boot_msg db "Booted", 0
size_output db "Kernel memory footprint: ", 0

section .multiboot
align 4
	dd 0x1BADB002
	dd 0x00000002
	dd -(0x1BADB002 + 0x00000002)

section .text
global _start
_start:
	mov esp, stack_top

	push boot_msg
	push 0xb8002
	call print_vga
	add esp, 8

	extern kernel_start
	extern kernel_end

	mov eax, kernel_end
	sub eax, kernel_start
	mov ebx, kernel_size

	; takes input number from eax,
	; puts the output string at address pointed to by ebx
	itoa:
		; push ebp and store esp there for bounds checking in .pop
		push ebp
		mov ebp, esp
	.loop:
		xor edx, edx
		mov ecx, 10
		div ecx
		push edx

		; end loop if dividend = 0
		test eax, eax
		jne .loop

	.pop:
		pop eax
		add eax, '0'
		mov [ebx], al
		inc ebx
		cmp ebp, esp
		jne .pop

	.end:
		pop ebp

	push size_output
	push 0xb80a2
	call print_vga
	add esp, 8

	push kernel_size
	push 0xb80d4
	call print_vga
	add esp, 8

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

	; prints characters to screen using vga text mode with white on black color
	; first arg - address of string to print;
	; second arg - address of vga at which to start printing
	print_vga:
		push ebp
		mov ebp, esp
		mov ebx, [ebp+12]
		mov eax, [ebp+8]
	.loop:
		mov cl, [ebx]
		mov [eax], cl
		inc eax
		mov byte [eax], 0x0f
		inc eax

		inc ebx
		cmp byte [ebx], 0
		jne .loop

		; epilogue
		pop ebp
		ret

section .bss
kernel_size:
	resb 5
alignb 16
stack_bottom:
	resb 16384
stack_top:

alignb 4096
pml4:
	resb 4096
pdpt:
	resb 4096
pd:
	resb 4096
pt:
	resb 4096
