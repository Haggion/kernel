.section .text

.equ FB_BASE,   0xfe000000
.equ FB_WIDTH,  2256
.equ FB_HEIGHT, 1504
.equ FB_DEPTH,  16

.global uboot_fb_draw_pixel
.type uboot_fb_draw_pixel, @function
# void uboot_fb_draw_pixel (int x, int y, int color);
uboot_fb_draw_pixel:
   # t0 = y * FB_WIDTH
   li   t2, FB_WIDTH
   mul  t0, a1, t2

   # t0 = (y * width) + x
   add  t0, t0, a0

   # t0 = offset in bytes = pixel_index * 2
   slli t0, t0, 1       # multiply by 2 using shift left

   # t0 = address = FB_BASE + offset
   li   t1, FB_BASE
   add  t0, t1, t0

   # store halfword (color) at calculated address
   sh   a2, 0(t0)

   ret