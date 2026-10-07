/* output functionality based aroung VGA text mode */
#include <stdint.h>
#include "output.h"
#include "memory.h"

#define ROWS 25
#define COLUMNS 80

static volatile uint16_t *const vga_buf = (volatile uint16_t *)0xb8000;

struct Cursor {
	uint8_t row;
	uint8_t column;
	uint8_t color;
};

static struct Cursor cursor = {
    .row = 2,
    .column = 0,
    .color = WHITE
};

void kputc(char c) {
	if (c == '\n') {
		if (cursor.row == ROWS - 1) {
			scroll();
			cursor.column = 0;
			return;
		}
		cursor.row++;
		cursor.column = 0;
		return;
	}

	uint16_t vga_pos = cursor.row * COLUMNS + cursor.column;
	vga_buf[vga_pos] = ((uint16_t)(cursor.color << 8)) | (uint8_t)c;

	if (cursor.column >= COLUMNS - 1) {
		if (cursor.row >= ROWS - 1) {
			scroll();
			cursor.row	  = ROWS - 1;
			cursor.column = 0;
			return;
		}

		cursor.row++;
		cursor.column = 0;
		return;
	}

	cursor.column++;
}

void scroll(void) {
	for (int i = 0; i < ROWS; i++) {
		kmemcpy(vga_buf + i * COLUMNS,
				vga_buf + (i + 1) * COLUMNS,
				COLUMNS * sizeof(uint16_t));
	}
}

void kputs(const char *c) {
	while (*c != 0) {
		kputc(*c);
		c++;
	}
}

void set_color(uint8_t fg, uint8_t bg) {
	cursor.color = (bg << 4) | fg;
}
