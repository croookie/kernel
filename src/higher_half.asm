[bits 64]

section .higher_half.asm progbits alloc exec nowrite

extern data64_descriptor
extern GDT_start
extern stack_top
extern kmain

global enter_higher_half

%define VIRTUAL(addr) (addr + 0xffff800000000000)

enter_higher_half:

	mov rax, data64_descriptor
	sub rax, GDT_start
	mov ds, ax
	mov ss, ax
	mov es, ax

	xor rax, rax
	mov rbx, rax
	mov rcx, rax
	mov rdx, rax
	
	mov rsp, VIRTUAL(stack_top)
	call kmain

	hlt
	jmp $
