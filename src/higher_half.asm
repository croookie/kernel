[bits 64]

section .higher_half.asm progbits alloc exec nowrite

extern higher_stack_top
extern kmain

global enter_higher_half

enter_higher_half:

	;mov ax, DATA64_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax

	xor rax, rax
	mov rbx, rax
	mov rcx, rax
	mov rdx, rax
	
	mov rsp, higher_stack_top
	call kmain

	hlt
	jmp $
