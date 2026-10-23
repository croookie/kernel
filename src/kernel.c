#include <stdint.h>
#include <stddef.h>
#include "output.h"
#include "memory.h"
#include "itoa.h"

extern char kernel_load_addr[];
extern char bootstrap_end_addr[];
extern char higher_half_lma[];
extern char higher_half_vma[];
extern char kernel_end[];

__attribute__((section(".higher_half.c")))
void kmain(void) {
	set_color(YELLOW, BLACK);
	kputs("Switch to 64 bit mode and enter kmain\n");

	char kmem_buf[10];
	kputs("Kernel physical load address: ");
	kputs(itoa((unsigned long)(uintptr_t)kernel_load_addr, kmem_buf, HEX));
	kputc('\n');

	kputs("Bootstrap lower half end: ");
	kputs(itoa((unsigned long)(uintptr_t)bootstrap_end_addr, kmem_buf, HEX));
	kputc('\n');

	kputs("Higher half LMA: ");
	kputs(itoa((unsigned long)(uintptr_t)higher_half_lma, kmem_buf, HEX));
	kputc('\n');

	kputs("Higher half VMA: ");
	kputs(itoa((unsigned long)(uintptr_t)higher_half_vma, kmem_buf, HEX));
	kputc('\n');

	kputs("Kernel end (virtual): ");
	kputs(itoa((unsigned long)(uintptr_t)kernel_end, kmem_buf, HEX));
	kputc('\n');

}
