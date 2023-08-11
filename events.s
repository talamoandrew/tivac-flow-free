	.text
	; global
	.global uart_event
	.global timr_event
	.global swch_event
	.global gpio_event

	; lab6
	.global print_at_pos
	.global hide_cur
	.global show_cur
	.global mov_cur_to_user
	.global set_cur_pos
	.global print_board
	.global paused

	; lab6library
	.global int2str
	.global strlen
	.global read_character_v2
	.global output_character
	.global output_enter

	; movement.s
	.global movement_interpreter

	; coloring.s
	.global space_pressed
	.global color_line

	.data
time: 		.short	0x0000			; int value for the time
paused:		.short	0x0000			; 0 for unpaused, 1 for paused
time_str:	.string "0000", 0x0

ptr_to_time:	.word	time
ptr_to_paused:	.word	paused
ptr_time_str:	.word	time_str

uart_event:
	STMFD sp!, {r4-r12, lr}

	bl read_character_v2

	ldr r1, ptr_to_paused	;is the game currently paused?
	ldrh r1, [r1]
	cmp r1, #0x0001
	beq is_paused		;if it is not, do not care what other keys were pressed

	cmp r0, #0x20			;is char == space?
	beq space
	cmp r0, #0x77			; is char w, a, s, d
	beq pressed_w

	cmp r0, #0x61
	beq pressed_a

	cmp r0, #0x73
	beq pressed_s

	cmp r0, #0x64
	beq pressed_d

	b uart_event_end

space:
	bl space_pressed
	b uart_event_end

pressed_w:
	bl movement_interpreter
	mov r0, #0x1
	b uart_event_color
	;reprint board after movement while drawing

pressed_a:
	bl movement_interpreter
	mov r0, #0x3
	b uart_event_color
	;reprint board after movement while drawing

pressed_s:
	bl movement_interpreter
	mov r0, #0x2
	b uart_event_color
	;reprint board after movement while drawing

pressed_d:
	bl movement_interpreter
	mov r0, #0x4
	b uart_event_color
	;reprint board after movement while drawing

is_paused:
	cmp r0, #0x7A			;is char == z (z => restart new puzzle when paused)
	;clear current puzzle
	;reset time
	;pick new board
	;print new board and start game

	cmp r0, #0x78			;is char == x (x => restart current puzzle when paused)
	;clear current board
	;reset time
	;start game

	cmp r0, #0x63			;is char == c (c => resume when paused)
	mov r0, #0x0000
	ldr r1, ptr_to_paused
	strh r0, [r1]			;unpause game => write 0 in paused flag
	mov r0, #0xC			;ascii for clear

	;;janky unpausing code;;
;	bl output_character
;
;	mov r0, #0x0101
;	ldr r1, ptr_to_complete
;	bl print_at_pos
;
;	mov r0, #0x0202
;	ldr r1, ptr_to_solved
;	bl print_at_pos
;
;	mov r0, #0x0403
;	ldr r1, ptr_to_time_text
;	bl print_at_pos
;
;	bl output_enter
;
;	ldr r1, ptr_to_cur_board
;	ldr r0, [r1]
;	bl print_board
;	bl enable_timer
;
;	ldr r2, ptr_user_pos
;	mov r0, #0x0205
;	mov r1, #0x0101
;	strh r1, [r2]
;	bl set_cur_pos
;	bl show_cur
	;resume timer

uart_event_color:
	bl color_line

uart_event_end:

	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




gpio_event:
	STMFD sp!, {r4-r12, lr}

	ldr r1, ptr_to_paused
	strh r0, [r1]				;write 1 into paused flag to indicate
	ldrh r0, [r1]
	eor r0, r0, #0x1
	strh r0, [r1]


	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




timr_event:
	STMFD sp!, {r0-r12, lr}

	; increments timer on UI by 1 with a 4 digit display
	; cursor remains visibly at where user left it

	ldr r2, ptr_to_paused
	ldrb r2, [r2]
	cmp r2, #0x1
	beq end_timr_event

	bl hide_cur				; hide cursor during system ops

	ldr r3, ptr_to_time		; fetch ptr to time
	ldr r1, ptr_time_str	; fetch ptr to string

	ldr r0, [r3]
	add r0, r0, #0x1		; increment time value
	str r0, [r3]
	mov r2, #4
	bl int2str

	ldr r1, ptr_time_str
	mov r0, #0x0A03

	bl print_at_pos			; overwrite time value on board

	bl mov_cur_to_user		; bring cursor back
	bl show_cur				; unhide cursor

end_timr_event:
	LDMFD sp!, {r0-r12, lr}
	mov pc, lr




swch_event:
