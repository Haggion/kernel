.section .text

.equ FB_BASE,   0xfe000000
.equ FB_WIDTH,  2256
.equ FB_HEIGHT, 1504
.equ FB_DEPTH,  16
.equ FB_STRIDE, FB_WIDTH * 2

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

1: sh   a2, 0(t0)
   fence rw, rw
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