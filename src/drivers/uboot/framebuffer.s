.section .text

.equ FB_BASE,   0xfe000000
.equ FB_WIDTH,  2256
.equ FB_HEIGHT, 1504
.equ FB_DEPTH,  16
.equ FB_BPP,       2
.equ FB_STRIDE, FB_WIDTH * FB_BPP

.equ CC_BASE,   0x2010000
.equ CC_FLUSH,  0x200

.global uboot_fb_draw_pixel
.type uboot_fb_draw_pixel, @function
# void uboot_fb_draw_pixel (int x, int y, int color);
uboot_fb_draw_pixel:
   li   t2, FB_STRIDE
   mul  t0, a1, t2

   # x * bytes per pixel (2)
   slli t1, a0, 1
   add  t0, t0, t1

   li   t1, FB_BASE
   add  t0, t1, t0

   sh   a2, 0(t0)
   ret

.global uboot_fb_width
.type uboot_fb_width, @function
uboot_fb_width:
   li a0, FB_WIDTH
   ret

.global uboot_fb_height
.type uboot_fb_height, @function
uboot_fb_height:
   li a0, FB_HEIGHT
   ret

.global uboot_fb_stride
.type uboot_fb_stride, @function
uboot_fb_stride:
   li a0, FB_STRIDE
   ret

.global uboot_fb_bpp
.type uboot_fb_bpp, @function
uboot_fb_bpp:
   li a0, FB_BPP
   ret

.global uboot_fb_start
.type uboot_fb_start, @function
uboot_fb_start:
   li a0, FB_BASE
   ret