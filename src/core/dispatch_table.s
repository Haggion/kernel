.section .dispatch, "ax"

/* This file provides jumps to various kernel procedures
at predictable memory positions. The entries start at
0x85000000, and every entry takes up 0x8 bytes. */

/*
Address    Method
0x85000000 _put_cstring
0x85000008 _put_char
0x85000010 _put_int
0x85000018 _put_hex
0x85000020 _get_char
*/

.global dispatch_put_cstring
dispatch_put_cstring:
   la t0, _put_cstring
   jr  t0

.global dispatch_put_char
dispatch_put_char:
   la t0, _put_char
   jr t0

.global dispatch_put_int
dispatch_put_int:
   la t0, _put_int
   jr t0

.global dispatch_put_hex
dispatch_put_hex:
   la t0, _put_hex
   jr t0

.global dispatch_get_char
dispatch_get_char:
   la t0, _get_char
   jr t0