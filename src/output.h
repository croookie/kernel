#pragma once

#include <stdint.h>

#define WHITE  0xf
#define BLACK  0x0
#define YELLOW 0xe

void kputc(char c);
void scroll(void);
void kputs(const char *c);
void set_color(uint8_t fg, uint8_t bg);
