.section .dispatch, "ax"
.option norelax

/* This file provides jumps to various kernel procedures
at predictable memory positions. The entries start at
0x85000000, and every entry takes up 0xC bytes. */

/*
Address    Method
0x85000000 _put_cstring
0x8500000C _put_char
0x85000018 _put_int
0x85000024 _put_hex
0x85000030 _get_char
0x8500003C _get_string
0x85000048 _make_buffer
0x85000054 _draw_pixel
0x85000060 _move_buffer
0x8500006C _rerender_buffer
0x85000078 _rerender_buffer_section
0x85000084 _delay
0x85000090 _allocate_memory
0x8500009C _free_memory
0x850000A8 _create_file
0x850000B4 _read_file
0x850000C0 _write_file
0x850000CC _memcpy
0x850000D8
0x850000E4
0x850000F0
0x850000FC
0x85000108
*/

.macro make_jump fn_name
.global dispatch_\fn_name
dispatch_\fn_name:
   la t0, \fn_name
   jr t0
.endm

make_jump _put_cstring
make_jump _put_char
make_jump _put_int
make_jump _put_hex
make_jump _get_char
make_jump _get_string
make_jump _register_new_buffer
make_jump _draw_pixel
make_jump _move_buffer
make_jump _render_buffer
make_jump _render_buffer_section
make_jump delay_us
make_jump malloc
make_jump free
