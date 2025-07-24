ENTRY(_start)

PHDRS
{
	text PT_LOAD FLAGS(5);
	data PT_LOAD FLAGS(6);
}

MEMORY {
    ram (rwx) : ORIGIN = 0xffffffff80000000, LENGTH = 2M
}

SECTIONS
{
	_start = 0x80000000;

	. = 0xffffffff80000000;
	
	_kernel_start = .;

	.text : ALIGN(0x1000) {
		KEEP(*(.text.boot))
		*(.text .text.*)
		*(.rodata .rodata.*)
	} :text
	
	.data : ALIGN(0x1000) {
		*(.data .data.*)
	} :data
	
	.bss : ALIGN(0x1000) {
		__bss_start = .;
		*(.bss .bss.* COMMON)
		__bss_end = .;
	} :data

	.stack (NOLOAD) : {
		. = ALIGN(16);
		_stack_bottom = .;
		. = . + 0x4000; /* 16KB stack */
		_stack_top = .;
	} > ram
	
	_kernel_end = .;

	/DISCARD/ : {
		*(.note .note.*)
		*(.eh_frame*)
		*(.comment)
	}
}
