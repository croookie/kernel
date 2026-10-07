[bits 32]

section .data
boot_msg db "Booted", 0
size_output db "Kernel memory footprint: ", 0
bytes db "bytes", 0

section .multiboot
align 4
	dd 0x1BADB002
	dd 0x00000002
	dd -(0x1BADB002 + 0x00000002)

section .text
global _start

	; identity-maps the first 2M of address space
	setup_paging:
		; zeroing page tables
		xor eax, eax
		xor edi, edi
		mov edi, PML4_table
		xor ecx, ecx
		mov ecx, 4096
		rep stosd

		mov eax, PDPT_table
		or eax, 0b11
		mov [PML4_table], eax

		mov eax, PD_table
		or eax, 0b11
		mov [PDPT_table], eax

		mov eax, PT_table
		or eax, 0b11
		mov [PD_table], eax

		; map every page table in the PD entry
		mov edi, PT_table
		mov eax, 0b11
		mov ecx, 512

		.map_pt:
			mov [edi], eax
			add edi, 8
			add eax, 0x1000
			loop .map_pt

		ret
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
_start:
	mov esp, stack_top

	push boot_msg
	push 0xb8000
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
	push 0xb80a0
	call print_vga
	add esp, 8

	push kernel_size
	push 0xb80d2
	call print_vga
	add esp, 8

	push bytes
	push 0xb80e6
	call print_vga
	add esp, 8

	; entering long mode
	; setting cr0.pg to 0
	mov eax, cr0
	and eax, 0x7fffffff
	mov cr0, eax
;
	; enabling PAE
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	call setup_paging

	; loading paging structure base address into cr3
	xor eax, eax
	mov eax, PML4_table
	mov cr3, eax

	; enabling 64 bit mode
	xor edx, edx
	mov ecx, 0xc0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	; enabling paging
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax

	lgdt [GDT_descriptor]
	jmp CODE64_SEG:long_mode_entry

	[bits 64]
	long_mode_entry:
	extern kmain
		mov ax, DATA64_SEG
		mov ds, ax
		mov ss, ax
		mov es, ax

		xor rax, rax
		mov rbx, rax
		mov rcx, rax
		mov rdx, rax

		mov rsp, stack_top

		call kmain

		hlt
		jmp $

section .bss
kernel_size:
	resb 5

alignb 16
stack_bottom:
	resb 16384
stack_top:

alignb 4096
PML4_table:
	resb 4096
PDPT_table:
	resb 4096
PD_table:
	resb 4096
PT_table:
	resb 4096

section .rodata
GDT_start:
	null:
		dq 0
	code64_descriptor:
		dd 0
		dw (1010b << 8) | (1 << 12) | (1 << 15) ; set type, S and P fields
		dw (1 << 5)
	data64_descriptor:
		dd 0
		dw (0010b << 8) | (1 << 12) | (1 << 15)
		dw 0
GDT_end:

CODE64_SEG equ code64_descriptor - GDT_start
DATA64_SEG equ data64_descriptor - GDT_start

GDT_descriptor:
	dw GDT_end  - GDT_start - 1
	dq GDT_start
