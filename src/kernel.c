#include <stdint.h>
#include <stddef.h>
#include "output.h"
#include "memory.h"
#include "itoa.h"

extern char kernel_start;
extern char kernel_end;

__attribute__((section(".higher_half.c")))
void kmain(void) {
	set_color(YELLOW, BLACK);
	kputs("Switch to 64 bit mode and enter kmain\n");

	char ksize_buf[10];
	uintptr_t kernel_size = (uintptr_t)&kernel_end - (uintptr_t)&kernel_start;
	kputs("Kernel memory footprint: ");
	kputs(itoa((long)kernel_size, ksize_buf, HEX));
	kputs(" bytes\n");

}
