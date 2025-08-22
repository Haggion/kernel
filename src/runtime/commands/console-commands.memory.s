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
