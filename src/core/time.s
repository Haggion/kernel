.section .text

.global tick_time
.type tick_time, @function
tick_time:
   rdtime a0
   ret

.global cycle_time
.type cycle_time, @function
cycle_time:
   rdcycle a0
   ret
