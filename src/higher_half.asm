[bits 64]

section .higher_half.asm progbits alloc exec nowrite

extern higher_stack_top
extern kmain

global enter_higher_half

enter_higher_half:

	mov rsp, higher_stack_top
	call kmain

	hlt
	jmp $
