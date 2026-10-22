[bits 32]

extern enter_higher_half
extern higher_half_offset
global data64_descriptor
global GDT_start
global stack_top

%define VIRTUAL(addr) (addr + higher_half_offset)

section .boot.data
boot_msg db "Booted", 0
size_output db "Kernel memory footprint: ", 0
bytes db "bytes", 0

section .multiboot
align 4
	dd 0x1BADB002
	dd 0x00000002
	dd -(0x1BADB002 + 0x00000002)

section .boot.text
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

	; map the first 2 MiB of physical address space (0x0 to 0x1fffff)
	; to the upper canonical half of the virtual address space
	; (0xffff800000000000 to 0xffff8000001fffff)
	setup_higher_half:
		; zero the three pages starting from higher_half.PDPT_table
		xor eax, eax
		mov edi, higher_half.PDPT_table
		mov ecx, 3072
		rep stosd

		; virtual address 0xffff800000000000 corresponds to
		; PML4[256], PDPT[0], PD[0] and PT[0]
		mov eax, higher_half.PDPT_table
		or eax, 0x3
		mov ecx, PML4_table + 256 * 8
		mov [ecx], eax
		
		mov eax, higher_half.PD_table
		or eax, 0x3
		mov ecx, higher_half.PDPT_table
		mov [ecx], eax

		mov eax, higher_half.PT_table
		or eax, 0x3
		mov ecx, higher_half.PD_table
		mov [ecx], eax

		mov edi, higher_half.PT_table
		mov eax, 0x3
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

	; entering long mode
	; setting cr0.pg to 0
	mov eax, cr0
	and eax, 0x7fffffff
	mov cr0, eax

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
		call setup_higher_half

		mov rax, enter_higher_half
		jmp rax

		hlt
		jmp $

section .boot.bss nobits
kernel_size:
	resb 5

alignb 16
global stack_top
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
higher_half:
.PDPT_table:
	resb 4096
.PD_table:
	resb 4096
.PT_table:
	resb 4096

section .boot.rodata
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

global GDT_descriptor
GDT_descriptor:
	dw GDT_end  - GDT_start - 1
	dq GDT_start
