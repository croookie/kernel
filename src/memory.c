#include <stdint.h>
#include <stddef.h>
#include "memory.h"

void *kmemcpy(void *dst, const void *src, size_t n) {
	volatile uint8_t *d = dst;
	volatile const uint8_t *s = src;
	for (int i = 0; i < n; i++) {
		d[i] = s[i];
	}
	return d;
}
