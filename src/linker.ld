ENTRY(_start)

PHDRS
{
	text PT_LOAD FLAGS(5);
	data PT_LOAD FLAGS(7);
}

MEMORY {
   ram (rwx) : ORIGIN = 0x80000000, LENGTH = 32M
}

SECTIONS
{
	. = ORIGIN(ram);

	.text : ALIGN(0x1000) {
		KEEP(*(.text._start))
		KEEP(*(.text.__gnat_last_chance_handler))
		*(.text .text.*)
		*(.rodata .rodata.*)
	} > ram :text

	.data : ALIGN(0x1000) {
		*(.data .data.*)
	} > ram :data
	
	.bss : ALIGN(0x1000) {
		PROVIDE(_bss_start = .);
		*(.bss .bss.* COMMON)
		PROVIDE(_bss_end = .);
	} > ram
	
	.heap (NOLOAD) : ALIGN(16) {
		_heap_start = .;
		. = . + 0x100000;
		_heap_end = .;
	} > ram

	.stack : ALIGN(16) {
		_stack_bottom = .;
		. = . + 0x100000;
		_stack_top = .;
	} > ram

	PROVIDE(_stack_limit = _stack_bottom);
   PROVIDE(_stack_base  = _stack_top);
	
	/DISCARD/ : {
		*(.note .note.*)
		*(.eh_frame*)
		*(.comment)
	}
}
