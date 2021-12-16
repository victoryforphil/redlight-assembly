@----------------------------------

.data

@ See /usr/include/arm-linux-gnueabihf/asm/unistd.h
@ See /usr/include/arm-linux-gnueabihf/bits/fcntl-linux.h
    .equ open,       5
         .equ Rd,   00
    .equ read,       3
    .equ close,      6
    .equ exit,       1

@----------------------------------

welcome_mesage:
    .asciz "Welcome to Redlight in ARM ASM!\nTest\n"
len = . - welcome_mesage
.balign 4
dir_file:
    .asciz "/dev/urandom"

.balign 4
Buf:
    .word 0 


.balign 4
format:
    .asciz "%3d\n"

@----------------------------------

.text

.global main, printf

main:

    push   {r4, r5, r7, lr}     @ folowing AAPCS

    bl      _print_welcome
    mov     r0, #0               @ 0 = success
    mov     r7, #1
    svc     #0


_print_welcome:
    push {lr}
    ldr      r0, =welcome_mesage
    bl      printf
    ldr r2, =len
    pop {pc}

/* Generates a random 1 byte number and stores the result in the address in R1 */
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
    #mov    r5, lr
    bx     lr
exit:

     pop    {r4, r5, r7, lr}     @ folowing AAPCS
     bx     lr                   @ Exit if use gcc as linker
