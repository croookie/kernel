#include <stdint.h>
#include <stddef.h>
#include "output.h"
#include "memory.h"

__attribute__((section(".higher_half.c")))
void kmain(void) {
	set_color(YELLOW, BLACK);
	kputs("Switch to 64 bit mode and enter kmain\n");
}
