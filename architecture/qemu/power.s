.section .text

.global shutdown
.type shutdown, @function
shutdown:
   # can't do this in an emulator (I think)
   ret

.global reboot
.type reboot, @function
reboot:
   ret
