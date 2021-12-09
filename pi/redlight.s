
.data

    .equ open,       5
         .equ Rd,   00
    .equ read,       3
    .equ close,      6
    .equ exit,       1

@----------------------------------

.balign 4
dir_file:
    .asciz "/dev/urandom"

.balign 4
Open:
    .word dir_file, Rd, open

.balign 4
Buf:
    .word 0 

.balign 4
Read:
    .word Buf, 1, read

.balign 4
format:
    .asciz "%3d\n"

@----------------------------------

.text

.global main, printf, sleep

main:

    push   {r4, r5, r7, lr}     @ folowing AAPCS
    #mov r0, #5
   # bl      sleep
    bal    _genradom

    mov r0, r1
    bal _delay
                   @ C() print byte
    mov    r0, #0               @ 0 = success

/* Delays Seconds in R0 */
_delay:
    bl sleep

/* Generates a random 1 byte number and stores the result  in R1 */
_genradom:
    ldr     r0, =dir_file           @ Save the pointer to the path (/dev/urandom) into R0
    mov     r7, #5                  @ Save the sycall 5 (open) to R7 for SVC Call
    mov     r1, #0                  @ Set flags (0=read)
    svc     #0                  @ Call Open SysCall
    mov     r4, r0 @ Save file descriptor in R4

    ldr     r1, =Buf    @ Save buffer pointer to R1
    mov     r2, #1      @ Set R2 (len) to 1 for 1 byte
    mov     r7, #3      @ Set R7 (syscal) to 3 for read
    svc     #0          @ Execute SysCall for Open

    mov    r0, r4               @ move fd in r0
    mov    r7, #close           @ num for close
    svc    #0                   @ OS closes file

    ldr    r0, =format          @ adress of format
    ldr    r1, =Buf             @ addr of byte red
    ldr    r1, [r1]             @ load byte
    
exit:

     pop    {r4, r5, r7, lr}     @ folowing AAPCS
     bx     lr                   @ Exit if use gcc as linker
