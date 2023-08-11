HORIZ:		.equ 0x0
VERT: 		.equ 0x1
LINE_STARVE:.equ 0xE	;value needed to move asterisk up one line -> opposite of line feed
CLEAR:		.equ 0xC
COLORSIZE:	.equ 0x7
TEST:		.equ 0x0	; set to 1 to test
TIMER_TOP:	.equ 0x4003
TIMER_BOT:	.equ 0x0000
GPTMCR:		.equ 0x00C

	.text
	; what files need what
	; self -> global
	.global print_at_pos
	.global print_at_pos_board
	.global hide_cur
	.global show_cur
	.global set_cur_pos
	.global mov_cur_to_user
	.global user_pos
	.global colors

	; boards.s
	.global select_board
	.global print_board
	.global ptr_to_board
	.global check_if_completed

	; init.s
	.global interrupt_init
	.global UART0_Handler
	.global gpio_init
	.global Switch_Handler
	.global timer_init
	.global Timer_Handler

	; library.s
	.global read_character
	.global output_character
	.global output_string
	.global uart_init
	.global illuminate_RGB_LED

	; startup.s
	.global lab6

	; unit testing.s
	.global test_lab_6

	; events.s
	.global timr_event
	.global ptr_to_cur_board
	.global paused
	.global cur_board
	.global enable_timer
	.global complete
	.global solved
	.global time_text
	.global user_pos

	;coloring.s
	.global light_LED
	.global is_drawing
	.global line_drawn
	.global line_deleted

	.global board
	.global colors
	.global characters


	.global left
	.global right
	.global up
	.global down

	.global boards_completed

	.data
colors: .string 27,"[30mX",0x0		; code for black
		.string 27,"[34mP",0x0		; code for blue
		.string 27,"[31mP",0x0		; red
		.string 27,"[32mP",0x0		; green
		.string 27,"[36mP",0x0		; cyan
		.string 27,"[37mP",0x0		; white
		.string 27,"[35mP",0x0		; magenta
		.string 27,"[33mP",0x0		; yellow

complete:	.string "Complete: 0/7", 0x0	; 0 is at position 10
solved:		.string "Solved: 0/16", 0x0		; 0 is at position 8
time_text:	.string "Time: 0000", 0x0

hide:	.string 27,"[?25l", 0x0
show:	.string 27,"[?25h", 0x0

characters:		.string " XO+-|", 0x0
integers:		.string "0123456789", 0x0


cur_set:		.string 27,"[YY;XXH", 0x0		; set position of system cursor
user_pos:		.short	0x0000			; xxyy position of user cursor, (0, 0) is top left X of board

paused_prompt:	.string "Game Paused",0xA,0xA,0xD
				.string "Press z to restart a new board.",0xA,0xA,0xD
				.string "Press x to restart current board.",0xA,0xA,0xD
				.string "Press c to resume game.", 0x0

ptr_to_colors:	.word colors
ptr_to_chars:	.word characters
ptr_to_hide:	.word hide
ptr_to_show:	.word show

ptr_to_ints:	.word integers
ptr_user_pos:	.word user_pos
ptr_to_cur_set:	.word cur_set

ptr_to_complete:	.word complete
ptr_to_solved:		.word solved
ptr_to_time_text:	.word time_text
ptr_to_paused:		.word paused
ptr_to_paused_prompt:.word paused_prompt

ptr_ptr_board:	.word ptr_to_board




lab6:
	STMFD sp!, {r0-r12,lr}

	mov r0, #TEST		; test flag
	cmp r0, #0x1
	beq test_lab_6
	bl uart_init
	bl gpio_init
	bl timer_init
	bl interrupt_init

game_init:

	bl hide_cur

	mov r0, #CLEAR
	bl output_character

	; position in format 0xXXYY: x is horizontal, y is vertical
	; setup text:
	; complete, solved, time, board
	mov r0, #0x0101
	ldr r1, ptr_to_complete
	bl print_at_pos

	mov r0, #0x0202
	ldr r1, ptr_to_solved
	bl print_at_pos

	mov r0, #0x0403
	ldr r1, ptr_to_time_text
	bl print_at_pos

	mov r0, #0x0004
	bl set_cur_pos
 	bl select_board
	bl print_board

	bl enable_timer

	ldr r2, ptr_user_pos
	mov r0, #0x0205
	mov r1, #0x0101
	strh r1, [r2]
	bl set_cur_pos
	bl show_cur


game_loop:



pause_loop:
	;check if game is paused
	;if so
	;disable timer
	;loop until z,x or c are pressed
	;z,x,c will set bit accordingly
	;branch based on what is set
	ldr r0, ptr_to_paused
	ldrb r0, [r0]				;load r0 with paused flag value
	cmp r0, #0					;if flag = 0
	beq pause_exit				;game is not paused, exit pause loop

	;paused to do 				;else do paused things mentioned above
	bl disable_timer			;disable timer
	mov r0, #CLEAR
	bl output_character			;hide screen
	ldr r0, ptr_to_paused_prompt
	bl output_string			;output paused prompt
	;wait for button presses

pause_loop_wait:
	;when z pressed
	;reset current board
	;reset timer
	;reset flows completed
	;select new board and begin

	;when x pressed
	;reset current board
	;reset timer
	;reset flows completed
	;do not select new board and begin

	;when c pressed
	;enable timer
	;continue game

	wfi
	b pause_loop_wait

pause_exit:
	ldr r0, ptr_ptr_board
	ldr r0, [r0]
	bl check_status_of_board
	cmp r0, #1					;1 => board is completed
	;if board is completed
	;write 1 into completed bit
	;increment num solved (bl board_solved)
	;reset timer?
	;branch to game_init to select new board and print screen

	b game_loop

infinite_loop:
;	bl timr_event
	;wfi
	ldr r1, ptr_to_paused
	ldrh r0, [r1]
	cmp r0, #0x0000
	beq infinite_loop		;is game paused
	mov r0, #CLEAR
	bl output_character
	ldr r0, ptr_to_paused_prompt
	bl output_string

	b infinite_loop

	LDMFD sp!, {r0-r12, lr}
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




print_board:
	STMFD sp!, {r4-r12, lr}

	; r0 = ptr to board

	mov r4, r0
	mov r5, #0
	ldrh r0, [r4],#2

print_board_char:
	bl color_interpreter
	bl output_string

	ldrh r0, [r4],#2
	cmp r0, #0
	bne print_board_char

	mov r0, r5

	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




color_interpreter:

	STMFD sp!, {r4-r12,lr}

	mov r1, #0x0D0A			;if r0 = line feed and carriage return
	cmp r0, r1				;output those characters and branch to end
	itttt eq
	moveq r0, #0xD
	bleq output_character
	moveq r0, #0xA
	bleq output_character
	beq end

	mov r1, #0x0000
	cmp r0, r1
	beq end

	rev16 r0, r0
	ldr r1, ptr_to_colors	;r1 = base addr of ANSI color codes
	and r2, r0, #0x0F		;r2 = color code only
	mov r3, #COLORSIZE		;r3 = size of one color string

	mul r2, r2, r3			;r2 = offset for respective color code
	add r1, r1, r2			;r1 = base addr of respective color code
	add r1, r1, #5			;r1 = location of char to be output in the color string

	;and r2, r0, #0xF0		;r2 = char code only
	lsr r0, r0, #0x8		;r2 = offset amount for respective char
	sub r0, r0, #0x30
	ldr r2, ptr_to_chars

	ldrb r3, [r2, r0]		;r4 = char to be written into color string
	strb r3, [r1]

	sub r0, r1, #5			;move base address of color string into return register

end:

	LDMFD sp!, {r4-r12,lr}
 	MOV pc, lr




enable_timer:
	STMFD sp!, {r0-r12,lr}

	mov r0, #TIMER_BOT
	movt r0, #TIMER_TOP
	ldr r1, [r0, #GPTMCR]	;r0 = address of General Purpose Timer Control Register
	orr r1, r1, #0x1		;set a 1 in bit 0 => enable timer
	str r1, [r0, #GPTMCR]

	LDMFD sp!, {r0-r12,lr}
	mov pc, lr




disable_timer:
	STMFD sp!, {r0-r12,lr}

	mov r0, #TIMER_BOT
	movt r0, #TIMER_TOP
	ldr r1, [r0, #GPTMCR]	;r0 = address of General Purpose Timer Control Register
	bic r1, r1, #0x1		;set a 0 in bit 0 => disable timer
	str r1, [r0, #GPTMCR]

	LDMFD sp!, {r0-r12,lr}
	mov pc, lr




print_at_pos_board:
	STMFD sp!, {r4-r12, lr}
	; r0 has cur position in format 0xXXYY, (0, 0) top left of game board
	; r1 has pointer to string

	add r4, r0, #0x0104		; adjust position to match system cursor position
	bl hide_cur				; have to hide cursor because
	mov r0, r4
	bl print_at_pos			; print at pos will shift it over by 1 spot
	bl mov_cur_to_user
	bl show_cur

	LDMFD sp!, {r4-r12, lr}
	mov pc, lr


print_at_pos:
	STMFD sp!, {r4-r12, lr}

	; r0 has cur position in format 0xXXYY
	; r1 has pointer to string

	mov r4, r1

	bl set_cur_pos

	mov r0, r4
	bl output_string

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr




hide_cur:
	STMFD sp!, {r4-r12, lr}

	ldr r0, ptr_to_hide
	bl output_string

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr




show_cur:
	STMFD sp!, {r4-r12, lr}

	ldr r0, ptr_to_show
	bl output_string

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr




mov_cur_to_user:
	STMFD sp!, {r4-r12, lr}

	ldr r1, ptr_user_pos
	ldrh r0, [r1]
	add r0, r0, #0x0104
	bl set_cur_pos

	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




set_cur_pos:
	; r0 contains position in format 0xXXYY
	STMFD sp!, {r4-r12, lr}

	and r2, r0, #0xFF	; fetch YY values
	mov r3, #0xA
	udiv r1, r2, r3		; r1 = tens place
	mul r3, r3, r1
	sub r2, r2, r3		; r2 = ones place

	ldr r3, ptr_to_ints
	ldrb r1, [r3, r1]
	ldrb r2, [r3, r2]

	ldr r4, ptr_to_cur_set
	strb r1, [r4, #2]	; set tens place
	strb r2, [r4, #3]	; set ones place

	and r2, r0, #0xFF00	; fetch XX values
	lsr r2, r2, #0x8
	mov r3, #0xA
	udiv r1, r2, r3		; r1 = tens place
	mul r3, r3, r1
	sub r2, r2, r3		; r2 = ones place

	mov r0, r4		; do this ahead of time
	ldr r3, ptr_to_ints
	ldrb r1, [r3, r1]
	ldrb r2, [r3, r2]

	strb r1, [r4, #5]	; set tens place
	strb r2, [r4, #6]	; set ones place

	bl output_string

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr

board_solved:
	STMFD sp!, {r0-r12, lr}

	ldr r0, ptr_to_solved
	add r0, r0, #8
	ldrb r1, [r0]
	add r1, r1, #1
	strb r1, [r0]

	LDMFD sp!, {r0-r12, lr}
	MOV pc, lr

line_drawn:
	STMFD sp!, {r0-r12, lr}

	ldr r0, ptr_to_complete
	add r0, r0, #10
	ldrb r1, [r0]
	add r1, r1, #1
	strb r1, [r0]

	LDMFD sp!, {r0-r12, lr}
	MOV pc, lr

line_deleted:
	STMFD sp!, {r0-r12, lr}

	ldr r0, ptr_to_complete
	add r0, r0, #10
	ldrb r1, [r0]
	sub r1, r1, #1
	strb r1, [r0]

	LDMFD sp!, {r0-r12, lr}
	MOV pc, lr

;infinite:
;	mov r0, #0
;	cmp r0, #0
;	beq infinite
;
;	LDMFD sp!, {r0-r12,lr}
; 	MOV pc, lr




;modulus:
;	STMFD sp!, {r4-r12, lr}
;
;	;r0 = dividend
;	;r1 = divisor
;	; r0 % r1 = remainder
;
;	UDIV r2, r0, r1		;r2 = r0/r1
;	MUL r1, r1, r2		;r1 = r1 * quotient rounded down
;	SUB r0, r1, r0		;r0 = divident - (r1 * quotient)
;
;	;r0 = remainder
;
;	LDMFD sp!, {r4-r12, lr}
;	MOV pc, lr





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; tested and validated below here ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




 	.end
