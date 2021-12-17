@----------------------------------
.data
@ See /usr/include/arm-linux-gnueabihf/asm/unistd.h
@ See /usr/include/arm-linux-gnueabihf/bits/fcntl-linux.h
    .equ open,       5
         .equ Rd,   02
    .equ read,       3
    
    .equ close,      6
    .equ exit,       1
.equ INPUT, 0
.equ OUTPUT, 1
.equ LOW, 0
.equ HIGH, 1
.equ WPI_SENSE_PIN, 7
@----------------------------------

welcome_mesage:
    .asciz "Welcome to Redlight in ARM ASM!\nTest\n"
len = . - welcome_mesage


msg_new_round:
    .asciz "New Round!\n"
len_new_round = . - msg_new_round

dir_file:
    .asciz "/dev/urandom"

/* 
GPIO SYS FS PATHS
GPIO 3 - Red Light
GPIO 2 - Green Light
GPIO 0 - Motion Sensor
 */
.balign 4
path_gpio_export:
    .asciz "/sys/class/gpio/export"
    @.asciz "/home/alex/redlight-assembly/test.txt"

.balign 4
path_gpio_dir_green:
    .asciz "/sys/class/gpio/gpio2/direction"
.balign 4
path_gpio_dir_red:
    .asciz "/sys/class/gpio/gpio3/direction"

.balign 4
path_gpio_dir_input:
    .asciz "/sys/class/gpio/gpio4/direction"

.balign 4
val_gpio_dir_in:
    .asciz "in"

.balign 4
val_gpio_dir_out:
    .asciz "out"

.balign 4
path_gpio_val_green:
    .asciz "/sys/class/gpio/gpio2/value"

.balign 4
path_gpio_val_red:
    .asciz "/sys/class/gpio/gpio3/value"

.balign 4
path_gpio_val_input:
    .asciz "/sys/class/gpio/gpio4/value"

.balign 4
Buf:
    .word 0 
.balign 4
format:
    .asciz "%3d\n"
.balign 4
rounds_left:
    .word 0
@----------------------------------

.text

.global main, printf

main:

    push   {r4, r5, r7, lr}     @ folowing AAPCS
    
    bl      _print_welcome
    bl      wiringPiSetup

    bl      _export_sensor
    bl      _export_green
    bl      _export_red
    bl      _direction_green
    bl      _direction_red
    bl      _direction_input
  
    mov R1, #0
    bl      _set_red



    bl      _game_loop

    mov     r0, #0               @ 0 = success
    mov     r7, #1
    svc     #0

    pop {pc}
   

_game_loop:
    push {lr}
    mov  R10, #10 @ play 5 rounds
_game_loop_tick:
    cmp R10, #0
    ble _game_loop_exit
    bl _print_new_round
    mov R0, #1
    bl _set_green
    mov R0, #0
    bl _set_red

    bl _genradom
   
    subs    R10, R10, #1
    orr     r1, r1, #2 @ Ensures 1s at min
    and     r1, r1, #6 @ Cap at 6s (remove first bits)
    mov     r1, r1, LSL #6 @Multipel by 1024 (s)
    mov     r0, r1
    bl      delay
    bal     _game_loop_tick

_game_loop_exit:
    pop {pc}


_check_movement:
    push    {lr}
    mov      R0, #1
    bl      _set_red
    mov     R8, #50   @ Check for 5s (50 * 100)
    mov     R9, #0
_check_movement_loop:
    cmp     R9, R8
    bge     _check_exit
    bl      _read_input
    bl      _set_red
   
    ldr     R0, =#100
    bl      delay
    add     R9, R9, #1
    bal     _check_movement_loop
    
_check_exit:
    pop {pc} 


   

_print_welcome:
    push    {lr}
    ldr     r0, =welcome_mesage
    bl      printf
    ldr     r2, =len
    pop     {pc}
_print_new_round:
    push    {lr}
    ldr     r0, =msg_new_round
    bl      printf
    ldr     r2, =len
    pop     {pc}

/* --- EXPORT FUNCTIONS --- */
_fs_open_export:
    push    {lr}
    /* Open gpio export path file */
    ldr     r0, =path_gpio_export
    mov     r7, #5
    mov     r1, #777      @ Set flags to 2 (RW)
    svc     #0
    mov     r4,r0
    pop     {pc}

_export_sensor:
    push {lr}

    bl _fs_open_export
    /* write pins to export init */
    mov     r6, #52      @load value of pin to export
    ldr     r1, =Buf
    str     r6, [r1]
    mov     r2, #1      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0
    bl      _fs_close
    pop     {pc}

_export_green:
    push {lr}
    
    bl _fs_open_export

    /* write pins to export init */
    mov     r6, #50      @load value of pin to export
    ldr     r1, =Buf
    str     r6, [r1]
    mov     r2, #1      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0

    bl      _fs_close
    pop     {pc}

_export_red:
    push {lr}
    
    bl _fs_open_export
    /* write pins to export init */
    mov     r6, #51      @load value of pin to export
    ldr     r1, =Buf
    str     r6, [r1]
    mov     r2, #1      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0

    bl      _fs_close
    pop     {pc}
    
/* --- END OF EXPORT FUNCTIONS */

/* --- DIRECTION FUNCTIONS */
_direction_green:
    push    {lr}
    /* Open gpio export path file */
    ldr     r0, =path_gpio_dir_green
    mov     r7, #5
    mov     r1, #777      @ Set flags to 2 (RW)
    svc     #0
    mov     r4,r0

    ldr     r1, =val_gpio_dir_out
    mov     r2, #3      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0

    bl      _fs_close
    pop     {pc}

_direction_red:
    push    {lr}
    /* Open gpio export path file */
    ldr     r0, =path_gpio_dir_red
    mov     r7, #5
    mov     r1, #777      @ Set flags to 2 (RW)
    svc     #0
    mov     r4,r0

    ldr     r1, =val_gpio_dir_out
    mov     r2, #3      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0

    bl      _fs_close
    pop     {pc}

_direction_input:
    push    {lr}

    @Wiring pi as well since reaidng from sysfs isnt working, time is money

    /* Open gpio export path file */
    ldr     r0, =path_gpio_dir_input
    mov     r7, #5
    mov     r1, #777      @ Set flags to 2 (RW)
    svc     #0
    mov     r4,r0

    ldr     r1, =val_gpio_dir_in
    mov     r2, #2      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0

    bl      _fs_close

    mov R0, #WPI_SENSE_PIN
    mov R1, #INPUT
    bl      pinMode

    pop     {pc}

/* --- END OF DIRECTION FUNCTIONS */

/* --- GPIO SET/READ FUNCTIONS */
@ R0 = 0/1 for on / off
_set_green:
    push    {lr}
    /* Open gpio export path file */
    mov     r6, r0      @ Unload paramter in R0 into R6
    ldr     r0, =path_gpio_val_green
    mov     r7, #5
    mov     r1, #777      @ Set flags to 2 (RW)
    svc     #0
    mov     r4,r0
    
    /* Write to GPIO file  */
    add     r6, #48     @Convert 0/1 to "0/1"
    ldr     r1, =Buf
    str     r6, [r1]
    mov     r2, #1      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0
    bl      _fs_close
    pop     {pc}

_set_red:
    push    {lr}
    /* Open gpio export path file */
    mov     r6, r0      @ Unload paramter in R0 into R6
    ldr     r0, =path_gpio_val_red
    mov     r7, #5
    mov     r1, #777      @ Set flags to 2 (RW)
    svc     #0
    mov     r4,r0
    
    /* Write to GPIO file  */
    add     r6, #48     @Convert 0/1 to "0/1"
    ldr     r1, =Buf
    str     r6, [r1]
    mov     r2, #1      @ Set len to 1 byte
    mov     r7, #4      @ Syscal 4, write
    svc     #0
    bl      _fs_close
    pop     {pc}

/* R0 hold result */
_read_input:
    push    {lr}
	mov     r0, #WPI_SENSE_PIN
	bl      digitalRead
    pop     {pc}

// --- END OF SET/READ FUNCTIONS ---- ///


/* Generates a random 1 byte number and stores the result in the address in R1 */
_genradom:
    ldr     r0, =dir_file   @ Save the pointer to the path (/dev/urandom) into R0
    mov     r7, #5      @ Save the sycall 5 (open) to R7 for SVC Call
    mov     r1, #0       @ Set flags (0=read)
    svc     #0          @ Call Open SysCall
    mov     r4, r0      @ Save file descriptor in R4

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

_fs_close:
    push {lr}
    mov    r0, r4               @ move fd in r0
    mov    r7, #close           @ num for close
    svc    #0                   @ OS closes file
    pop {pc}
exit:

     pop    {r4, r5, r7, lr}     @ folowing AAPCS
     bx     lr                   @ Exit if use gcc as linker


addr_ : .word Buf

