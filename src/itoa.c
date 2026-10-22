#include "itoa.h"

char *itoa(long value, char *buf, unsigned short base) {
	if (value == 0)  {
		buf[0] = 0;
		buf[1] = '\0';
		return buf;
	}

	int count = 0;
	int i = 0;

	switch (base) {
		case DECIMAL: {
			for (; value != 0; count++) {
				unsigned int digit = value % base;
				buf[count] = (char)digit + '0';
				value /= base;
			}

			buf[count] = '\0';
			--count;
			break;
		}
		case HEX: {
			buf[0] = '0';
			buf[1] = 'x';
			count = 2;
			i = 2;

			for (; value != 0; count++) {
				unsigned int digit = value % base;
				if (digit > 9) {
					buf[count] = digit - 10 + 'A';
				}
				else {
					buf[count] = (char)digit + '0';
				}
				value /= base;
			}
			buf[count] = '\0';
			--count;
			break;
		}
		default:
			/* TODO: add proper error handling */
			return buf;
			break;
	}


	for (; i < count; ++i, --count) {
		char temp = buf[i];
		buf[i] = buf[count];
		buf[count] = temp;
	}

	return buf;
}
