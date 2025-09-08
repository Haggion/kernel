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