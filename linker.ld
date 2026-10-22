ENTRY(_start)

SECTIONS
{
	higher_half_offset = 0xffff800000000000;

	. = 1M;

	kernel_start = .;

	.multiboot ALIGN(4K) :
	{
		*(.multiboot)
	}

	.boot.text ALIGN(4K) :
	{
		KEEP(*(.boot.text))
	}

	.boot.rodata ALIGN(4K) :
    {
        *(.boot.rodata)
    }

    .boot.data ALIGN(4K) :
    {
        *(.boot.data)
    }

    .boot.bss ALIGN(4K) :
    {
        *(.boot.bss)
    }

	/* TODO
	 * cnange that to give an actual kernel memory footprint,
	 * counting higher half asm and kernel c as well
	 */
	kernel_end = .;
	
	. += higher_half_offset;
	higher_stack_top = stack_top + higher_half_offset;

	.higher_half.text ALIGN(4K) : AT(ADDR(.higher_half.text) - higher_half_offset)
	{
		*(.higher_half.asm)
		*(.higher_half.c)
	}

	.rodata ALIGN(4K) : AT(ADDR(.rodata) - higher_half_offset)
	{
        *(.rodata .rodata.*)
    }

    .data ALIGN(4K) : AT(ADDR(.data) - higher_half_offset)
	{
        *(.data .data.*)
    }

    .bss ALIGN(4K) : AT(ADDR(.bss) - higher_half_offset)
	{
        *(COMMON)
        *(.bss .bss.*)
    }
}
