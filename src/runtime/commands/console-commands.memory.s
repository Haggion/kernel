.section .text

.global poke_byte
.type   poke_byte, @function
poke_byte:
   lb a0, 0(a0)
   ret

.global poke_word
.type   poke_word, @function
poke_word:
   lw a0, 0(a0)
   ret

.global put_byte
.type   put_byte, @function
put_byte:
   sb a1, 0(a0)
   mv a0, a1
   ret

.global put_word
.type   put_word, @function
put_word:
   sw a1, 0(a0)
   mv a0, a1
   ret