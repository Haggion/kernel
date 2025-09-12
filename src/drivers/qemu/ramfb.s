.section .text

.extern ramfb_stride
.extern ramfb_bytes_per_pixel
.extern ramfb_fb_base
.extern _put_int

.global ramfb_draw_pixel
.type   ramfb_draw_pixel, @function
# void ramfb_draw_pixel(x, y, color)
ramfb_draw_pixel:
   lw  t0, ramfb_stride
   lw  t1, ramfb_bytes_per_pixel
   ld  t2, ramfb_fb_base

   mul t0, t0, a1
   mul t1, t1, a0
   add t0, t0, t1
   add t0, t0, t2
   
   sw  a2, 0(t0)
   ret

.global ramfb_draw_2_pixels
.type   ramfb_draw_2_pixels, @function
# void ramfb_draw2_pixels(x_start, y, color1, color2)
ramfb_draw_2_pixels:
   lw   t0, ramfb_stride
   lw   t1, ramfb_bytes_per_pixel
   ld   t2, ramfb_fb_base

   mul  t0, t0, a1
   mul  t1, t1, a0
   add  t0, t0, t1
   add  t0, t0, t2
   
   slli t3, a3, 32
   add  t3, t3, a2

   sd   t3, 0(t0)
   ret

.global ramfb_draw_2_pixels_raw
.type   ramfb_draw_2_pixels_raw, @function
# void ramfb_draw_2_pixels_raw(pos, color1, color2)
ramfb_draw_2_pixels_raw:
   ld   t1, ramfb_fb_base
   lw   t0, ramfb_bytes_per_pixel

   mul  t0, t0, a0
   add  t0, t0, t1

   slli t1, a2, 32
   add  t1, t1, a1

   sd   t1, 0(t0)
   ret