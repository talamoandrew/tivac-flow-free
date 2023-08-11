	.text
	.global read_character
	.global read_character_v2
	.global output_character
	.global output_character_v2
	.global output_string
	.global read_string
	.global uart_init
	.global read_from_push_btn
	.global illuminate_RGB_LED
	.global num_digits
	.global strlen
	.global int2str
	.global str2int
	.global output_enter
	.global check_status_of_board 
	

	; Your routines go here
	; Required routines are shown in the global declarations above




read_character:
	STMFD SP!,{lr}	; Store register lr on stack

		; Your code for your read_character routine is placed here
LOOPC:	MOV r1, #0xC018			;load lower address for UART Flag Regs
		MOVT r1, #0x4000		;load upper half of address
		LDRB r2, [r1]			;load byte into r2  RXFE = offset for RxFE

		AND r3, r2, #0x10		;if RxFE == 0
		CMP r3, #0x10
		BEQ LOOPC				;restart loop

		MOV r1, #0xC000			;load lower half of address for UART Data Reg
		MOVT r1, #0x4000		;load upper half of address
		LDRB r0, [r1]			;load into r0, byte from UART Data Reg Data Field (reading char)


 	LDMFD sp!, {lr}
	mov pc, lr




read_character_v2:
	STMFD sp!, {r1-r12,lr}

	MOV r1, #0xC000			;load lower half of address for UART Data Reg
	MOVT r1, #0x4000		;load upper half of address
	LDRB r0, [r1]			;load into r0, byte from UART Data Reg Data Field (reading char)

	LDMFD sp!, {r1-r12,lr}
	mov pc, lr




output_character:
	STMFD SP!,{r0-r12,lr}	; Store register lr on stack

		; Your code for your output_character routine is placed here
L4:	MOV r1, #0xC018				;load lower half of address for UART F
 	MOVT r1, #0x4000			;load upper half of address

 	LDRB r2, [r1]				;load into r2, the value in UARTFR
	AND r3, r2, #0x20			;if TXFF == 0
 	CMP r3, #0x00
 	BNE L4						;then restart loop

	MOV r1, #0xC000				;load lower half of address for UART Data Reg
	MOVT r1, #0x4000			;load upper half of address
	STRB r0, [r1]				;store byte into data reg

 	LDMFD sp!, {r0-r12,lr}
	mov pc, lr




output_character_v2:
	STMFD sp!, {r0-r12,lr}

	mov r1, #0xC000
	movt r1, #0x4000
	strb r0, [r1]

	LDMFD sp!, {r0-r12,lr}
	mov pc, lr




output_string:
	STMFD SP!,{lr}	; Store register lr on stack
	STMFD sp!, {lr, r0-r12}


		; Your code for your output_string routine is placed here

		;r0 = pointer to string base address
		MOV r9, r0				;move into r9, the str pointer

L2:		LDRB r2, [r9]			;load into r2, the character from memory
		CMP r2, #0				;Compare char to NULL
		BEQ E2					;if eq, branch to end
								;else call output_character
		MOV r0, r2				;move char into r0
		BL output_character
		ADD r9, r9, #1			;increment ptr
		B L2

E2:
	LDMFD sp!, {lr, r0-r12}
 	LDMFD sp!, {lr}
	mov pc, lr




read_string:
	STMFD SP!,{lr}	; Store register lr on stack

		; Your code for your read_string routine is placed here
		;base address of string is in r0
		MOV r12, r0				;move ptr to r12
L10:	BL read_character		;read character
		CMP r0, #0xD			;check if eq to ENTER
		BEQ E10					;if so go to end
		STRB r0, [r12]			;store char in string
		BL output_character
		ADD r12, r12, #1		;increment pointer
		B L10

E10:	MOV r0, #0
		STRB r0, [r12]			;store NULL

		MOV r0, r12				;move pointer back into r0


 	LDMFD sp!, {lr}
	mov pc, lr




uart_init:
	STMFD SP!,{lr}	; Store register lr on stack

; Your code for your uart_init routine is placed here

	MOV r0, #0xE618
	MOVT r0, #0x400F			;r0 = 0x400FE618
	LDR r1, [r0]
	ORR r1, r1, #0x1			;r1 |= 1
	STR r1, [r0]				;Provide clock to UART0

	MOV r0, #0xE608
	MOVT r0, #0x400F			;r0 = 0x400FE608
	LDR r1, [r0]
	ORR r1, r1, #0x1			;r1 |= 1
	STR r1, [r0]				;Enable clock to PortA

	MOV r0, #0xC030
	MOVT r0, #0x4000			;r0 = 0x4000C030
	LDR r1, [r0]
	BIC r1, r1, #0x1			;r1[0] = 0
	STR r1, [r0]				;Disable UART0 control

	MOV r0, #0xC024
	MOVT r0, #0x4000			;r0 = 0x4000C024
	LDR r1, [r0]
	ORR r1, r1, #0x8			;r1 |= 8
	STR r1, [r0]				;Set UART0_IBRD_R for 115,200 baud

	MOV r0, #0xC028
	MOVT r0, #0x4000			;r0 = 0x4000C028
	LDR r1, [r0]
	ORR r1, r1, #0x2C			;r1 |= 44
	STR r1, [r0]				;Set UART0_FBRD_R for 115,200 baud

	MOV r0, #0xCFC8
	MOVT r0, #0x4000			;r0 = 0x4000CFC8
	LDR r1, [r0]
	BIC r1, r1, #0x1			;r1[0] = 0
	STR r1, [r0]				;Use System Clock

	MOV r0, #0xC02C
	MOVT r0, #0x4000			;r0 = 0x4000C02C
	LDR r1, [r0]
	ORR r1, r1, #0x60			;r1 |= 0x60
	STR r1, [r0]				;Use 8-bit word length, 1 stop bit, no parity

	MOV r0, #0xC030
	MOVT r0, #0x4000			;r0 = 0x4000C030
	LDR r1, [r0]
	MOV r2, #0x0301
	ORR r1, r1, r2				;r1 |= 0x301
	STR r1, [r0]				;Enable UART0 Control

	MOV r0, #0x451C
	MOVT r0, #0x4000			;r0 = 0x4000451C
	LDR r1, [r0]
	ORR r1, r1, #0x03			;r1 |= 0x03
	STR r1, [r0]				;Make PA0 and PA1 as digital ports

	MOV r0, #0x4420
	MOVT r0, #0x4000			;r0 = 0x40004420
	LDR r1, [r0]
	ORR r1, r1, #0x03			;r1 |= 0x03
	STR r1, [r0]				;Change PA0,PA1 to Use an Alternate Function

	MOV r0, #0x452C
	MOVT r0, #0x4000			;r0 = 0x4000452C
	LDR r1, [r0]
	ORR r1, r1, #0x11			;r1 |= 0x11
	STR r1, [r0]				;Configure PA0 and PA1 for UART


 	LDMFD sp!, {lr}
	mov pc, lr




gpio_init:
PORTFt:	.equ	0x4002
PORTFb:	.equ	0x5000
CLOCK:	.equ	0x608	; set bit corresponding to port
DIR:	.equ	0x400	; 0 is input, 1 is output
DEN:	.equ	0x51C	; 0 is disable, 1 is digital
PUP:	.equ	0x510
DATA:	.equ	0x3FC

	STMFD sp!, {lr}
	STMFD sp!, {lr, r4-r11}


	mov r0, #0xE608			; base addr to enable GPIO clock
	movt r0, #0x400F

	mov r4, #PORTFb
	movt r4, #PORTFt

	mov r1, #0x20			; port f
	ldr r2, [r0]
	orr r2, r2, r1
	str r2, [r0]	; enable port f clock

	mov r1, #0xE			; bits to set 1 for gpio
	strb r1, [r4, #DIR]		; set gpio register value

	mov r1, #0x1E			; enables pins 1 - 4 as digital
	strb r1, [r4, #DEN]		; place altered byte back

	mov r1, #0x18			; set pins 3, 4 to 1
	strb r1, [r4, #PUP]

	LDMFD sp!, {lr, r4-r11}
	LDMFD sp!, {lr}
	mov pc, lr




read_from_push_btn:
	STMFD SP!,{lr}	; Store register lr on stack

	; Your code is placed here
	MOV r0, #0x5000
	MOVT r0, #0x4002		; r0 = port f data

    LDRB r1, [r0, #DATA]
    ubfx r0, r1, #4, #1
	eor r0, r0, #0x1		; negate bit 0
	LDMFD sp!, {lr}
	MOV pc, lr




illuminate_RGB_LED:
	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

							; r0 contains rbg values to set
	lsl r0, r0, #1			; shift left to prep to store in pins 1, 2, 3

	MOV r1, #0x5000
	MOVT r1, #0x4002		; r1 = port f data
	strb r0, [r1, #DATA]

	LDMFD sp!,{r0-r12,lr}
	MOV pc, lr




str2int:
	STMFD r13!, {r14}
	STMFD sp!, {lr, r4-r11}


		MOV r1, #0				; int i = 0
		MOV r2, #10				; load r2 with 10 for multiplication

LOAD:	LDRB r3, [r0]			; load character from string ptr

		CMP r3, #0				; is char == 0 ?
		BEQ RETURN				; if c == 0 branch to end
		MUL r1, r1, r2			; i *= 10
		SUB r4, r3, #0x30		; dig = char - 0x30
		ADD r1, r1, r4			; i += dig
		ADD r0, r0, #1			; add one to pointer
		B LOAD					; restart loop

RETURN:	MOV r0, r1

	LDMFD sp!, {lr, r4-r11}
	LDMFD r13!, {r14}
	MOV pc, lr




num_digits:
	STMFD r13!, {r14}

		MOV r1, #0 			; num digits, n (r1) = 0
		MOV r2, #10			; load 10 into r2 for dividing

DIVIDE:	UDIV r0, r0, r2		; integer = integer / 10 (r2)
		ADD r1, r1, #1		; ++n

		CMP r0, #0			; r0 == 0 ?
		BEQ DONE 			; if eq, branch to done
		B DIVIDE			; else divide integer by 10
DONE:
		MOV r0, r1

	LDMFD r13!, {r14}
	MOV pc, lr



strlen:
	STMFD sp!, {r4-r12, lr}

	mov r1, #0x0

increment_len:
	ldrb r2, [r0, r1]
	add r1, r1, #1
	cmp r2, #0x0
	bne increment_len

	mov r0, #1
	subu r0, r1, r0

	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




int2str:
	STMFD r13!, {r14}
	STMFD sp!, {lr, r4-r11}

		MOV r3, #0				;r3 = NULL
		MOV r8, #1				; 1 => positive, 0 => negative

		CMP r0, #0				;if the integer is positive
		BGE I1					;branch to start
		MOV r8, #0				;r8 = negative
		RSB r0, r0, #0			;r0 = 0 - (-i)
		ADD r2, r2, #1			;increment num_digits to accomodate for minus sign in memory

I1:		ADD r1, r1, r2			;add num_digits to pointer
		STRB r3, [r1]			;store NULL at pointer location
		SUB r1, r1, #1			;r1 -= 1
		MOV r3, #10				;store 10 into r3 for div and mul

L1:		UDIV r4, r0, r3			;divide integer by 10
		MUL r5, r4, r3			;multiply quotient by 10
		SUB r6, r0, r5			;dig = integer - quotient
		ADD r6, r6, #0x30		;ASCII val = digit + 0x30
		STRB r6, [r1]			;store at location pointed to, the ascii value of the digit
		MOV r0, r4				;eliminating least significant digit
		CMP r0, #0				;if r0 == 0
		BEQ E1					;then branch to stop
		SUB r1, r1, #1			;else subtract 1 from pointer in r1
		B L1

E1:		CMP r8, #1				;if positive branch to return
		BEQ RET
		MOV r3, #0x2D			;0x2D = ASCII value of '-'
		SUB r1, r1, #1			;ptr -= 1
		STRB r3, [r1]			;store '-' at beginning of str

RET: 	MOV r0, r1				;move the pointer to the return register

	LDMFD sp!, {lr, r4-r11}
	LDMFD r13!, {r14}
	MOV pc, lr




output_enter:
	STMFD sp!, {lr}

	mov r0, #0xA				;ascii for newline
	bl output_character

	mov r0, #0xD				;ascii for carriage return
	bl output_character

	LDMFD sp!, {lr}
	mov pc, lr
	
check_status_of_board:
	STMFD sp!, {r4-r12, lr}
	;r0 = base addr of board
	add r0, r0, #22		;move pointer to first location in game board
	mov r1, #1			;return value 0=> not done, 1 => done
	mov r2, #0			;loop counter
	mov r4, #0x3030

board_loop:
	ldrh r3, [r0]
	cmp r3, r4
	it eq
	moveq r1, #0
	add r0, r0, #2
	add r2, r2, #1
	cmp r2, #0x8C
	blt board_loop

	mov r0, r1

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr
delete_line:
	STMFD sp!, {r4-r12,lr}

	;r0 =  base addr of board
	;r1 =  code of color O
	
	add r0, r0, #22
	rev16 r1, r1
	
	and r2, r1, #0x0F		;r2 = color code
	lsr r3, r1, #0x8 		;r3 = char code
	
delete_loop:
	ldrh r4, [r0]			;load board piece
	
	and r5, r4, #0x0F		;first check color
	cmp r5, r2
	itt ne					;if not equal
	addne r0, r0, #2		;increment pointer
	bne delete_loop			;and branch to beginning of loop
							;else, color must be equal, move on
							
	lsr r4, r4, #0x8		;r4 = char code
	cmp r3, r4				;check character
	itt ne 					;if not equal (if char is not the 'O')
	movne r5, #0x3030		;load r5 with code for empty game board space
	strhne r5,[r0]			;overwrite char with empty space
	add r0, r0, #2			;increment pointer
	b delete_loop
	
	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr
	.end
