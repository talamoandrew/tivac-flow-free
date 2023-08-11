GPIO_TOP: 	.equ 0x4002
GPIO_BOT: 	.equ 0x5000
TIMER_TOP:	.equ 0x4003
TIMER_BOT:	.equ 0x0000
GPIOIS:		.equ 0x404
GPIOIBE:	.equ 0x408
GPIOIEV:	.equ 0x40C
GPIOIM: 	.equ 0x410
GPIOICR:	.equ 0x41C
GPTMCR:		.equ 0x00C

	.text
	; library
	.global read_character
	.global output_character
	.global output_string

	; lab6
	.global Switch_Handler
	.global Timer_Handler
	.global UART0_Handler
	.global gpio_init
	.global interrupt_init
	.global timer_init

	; events
	.global timr_event
	.global uart_event
	.global gpio_event




interrupt_init:
	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

	mov r0, #0xC038
	movt r0, #0x4000		;r0 = address of UART Interrupt Mask Register
	ldr r1, [r0]
	orr r1, r1, #0x10		;bit mask to change bit 5 to a 1
	str r1, [r0]			;Set Recieve Interrupt Mask

	mov r0, #0xE100
	movt r0, #0xE000		;r0 = address of Interrupt 0-31 Set Enable Register
	ldr r1, [r0]
	orr r1, r1, #0x20
	str r1, [r0]			;Allow UART to interrupt processor

	mov r0, #GPIO_BOT
	movt r0, #GPIO_TOP

	ldr r1, [r0, #GPIOIS]	; r0 = GPIO Interrupt Sense Register
	and r1, r1, #0xEF
	str r1, [r0, #GPIOIS]	; configure port f for edge sensitive triggering

	ldr r1, [r0, #GPIOIBE]	; r0 = GPIO Interrupt Both Edges Register
	and r1, r1, #0xEF
	str r1, [r0, #GPIOIBE]	; allow GPIOIEV to determine edge

	ldr r1, [r0, #GPIOIEV]	; r0 = GPIO Interrupt Event Register
	orr r1, r1, #0x10
	str r1, [r0, #GPIOIEV]	; trigger interrupt on button release

	ldr r1, [r0, #GPIOIM]	; r0 = GPIO Interrupt Mask Register
	orr r1, r1, #0x10
	str r1, [r0, #GPIOIM]	; enable GPIO to interrupt

	mov r0, #0xE100
	movt r0, #0xE000		; r0 = Interrupt Set Enable Register
	ldr r1, [r0]
	mov r2, #0x0000
	movt r2, #0x4008		; load bit mask into r2 to write a 1 into bit 30 and bit 19
	orr r1, r1, r2
	str r1, [r0]			; enable GPIO and Timer to interrupt processor

 	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr




UART0_Handler:
 	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	mov r0, #0xC044
 	movt r0, #0x4000		;r0 = address of UART Interrupt Clear Register
 	ldr r1, [r0]
 	orr r1, r1, #0x10
 	str r1, [r0]			;clear interrupt

	bl uart_event

	LDMFD sp!, {r0-r12,lr}
 	BX lr




gpio_init:
DIR:	.equ	0x400	; 0 is input, 1 is output
DEN:	.equ	0x51C	; 0 is disable, 1 is digital
PUR:	.equ	0x510

	STMFD sp!,{r0-r12,lr}

	mov r0, #0xE608
	movt r0, #0x400F
	ldr r1, [r0]			; r0 = base addr to enable GPIO port f clock
	orr r1, r1, #0x20		; set bit 5 to 1
	str r1, [r0]			; set port clock info

	mov r0, #GPIO_BOT
	movt r0, #GPIO_TOP

	ldr r1, [r0, #DIR]		; r0 = GPIO Direction Register
	and r1, r1, #0xEF		; set bit 4 as input	preserves all bits but ands bit 4 with 0 => EF == 11101111
	orr r1, r1, #0xE		; set bits 1, 2, 3 as output
	str r1, [r0, #DIR]

	ldr r1, [r0, #DEN]		; r0 = GPIO Digital Enable Register
	orr r1, r1, #0x1E
	str r1, [r0, #DEN]		; enable pins 1-4 as digital

	ldr r1, [r0, #PUR]		; r0 = GPIO Pull Up Register
	orr r1, r1, #0x10		; enable pull up resistor for pin 4
	str r1, [r0, #PUR]


	LDMFD sp!,{r0-r12,lr}
	MOV pc, lr




Switch_Handler:
GPIOIC:	.equ 0x41C

 	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	mov r0, #GPIO_BOT
 	movt r0, #GPIO_TOP
 	ldr r1, [r0,  #GPIOIC]	;r0 = address of GPIO Clear Register
 	orr r1, r1, #0x10		;clear interrupt
 	str r1, [r0, #GPIOIC]

	bl gpio_event
	LDMFD sp!, {r0-r12,lr}
 	BX lr




timer_init:
TAMR:		.equ 0x004
TILR:		.equ 0x028
TIMR:		.equ 0x018

	STMFD sp!,{r0-r12,lr}

	mov r0, #0xE604
	movt r0, #0x400F
	ldr r1, [r0]			;r0 = address of Timer Run Mode Clock Gating Control Register
	orr r1, r1, #0x1		;set a 1 in bit 0 => enable clock to Timer0
	str r1, [r0]

	mov r0, #TIMER_BOT
	movt r0, #TIMER_TOP
	ldr r1, [r0, #GPTMCR]	;r0 = address of General Purpose Timer Control Register
	bic r1, r1, #0x1		;set a 0 in bit 0 => set up timer while it is disabled
	str r1, [r0, #GPTMCR]

	ldr r1, [r0]			;r0 = address of Timer Configuration Register
	bic r1, r1, #0x7		; set bits 0-2 to 0 for 32-bit timer configuration
	str r1, [r0]

	ldr r1, [r0, #TAMR]		;r0 = address of Timer A Mode Register
	mov r2, #0x2
	bfi r1, r2, #0x0, #0x3 	;set mode to 2 (periodic)
	str r1, [r0, #TAMR]

	mov r1, #0x2400
	movt r1, #0x00F4		;r1 = 16,000,000 => 16MHz clock will tick 16M times in 1 second
	str r1, [r0, #TILR]

	ldr r1, [r0, #TIMR]		;r0 = address of Timer Interrupt Mask Register
	orr r1, r1, #0x1		;enable timer to interrupt by setting bit 0 to 1
	str r1, [r0, #TIMR]

	LDMFD sp!,{r0-r12,lr}
	MOV pc, lr




Timer_Handler:
GPTMICR:	.equ 0x24		;timer interrupt clear register offset

 	STMFD sp!, {r0-r12,lr}

	mov r0, #TIMER_BOT
	movt r0, #TIMER_TOP
	ldr r1, [r0, #GPTMICR]	;address of Timer Interrupt Clear Register
	orr r1, r1, #0x1		;clear interrupt
	str r1, [r0, #GPTMICR]

	bl timr_event

	LDMFD sp!, {r0-r12,lr}
	BX lr


	.end
