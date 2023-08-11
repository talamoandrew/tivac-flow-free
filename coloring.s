	.text
	; self -> global
	.global space_pressed
	.global color_line

	; boards.s
	.global ptr_to_board
	.global overwrite_board

	; lab6.s
	.global user_pos
	.global light_LED
	.global is_drawing
	.global line_drawn
	.global line_deleted
	.global colors
	.global print_at_pos_board

	;library
	.global illuminate_RGB_LED
	.global output_string

	; movement.s
	.global is_drawing
	.global delete_line
	.global last_drawing_dir

	.data
is_drawing:			.short	0x0000			; 0 if not drawing, 1-7 for corresponding colors
last_drawing_dir:	.short	0x0000			; 0 if not drawing or no priors, 1-4 for up, down, left, right (in that order)
last_user_pos:		.short	0x0000			; store previous user position

ptr_is_drawing:	.word	is_drawing
ptr_ptr_board:	.word	ptr_to_board
ptr_user_pos:	.word	user_pos
ptr_to_colors:	.word	colors

char_dir:		.string "+||--", 0x0
ptr_char_dir:	.word char_dir
COLORSIZE:		.equ	0x7


color_line:
	STMFD sp!, {r4-r12, lr}
	; r0 contains current direction, 1-4 for up, down, left, right.
	ldrh r1, is_drawing
	cmp r1, #0
	beq color_end				; only perform coloring if drawing mode is active

	mov r6, r0					; store direction for later
	ldrh r1, last_drawing_dir
	ldr r2, ptr_to_colors
	mov r3, #COLORSIZE
	ldr r4, ptr_is_drawing		; fetch color code
	ldrh r5, [r4]
	mul r4, r5, r3				; find offset to color string
	add r4, r4, r2				; set r4 to corresponding color string pointer

	cmp r0, r1
	bne color_dir_mismatch
	b write_line_at_user

color_dir_mismatch:
	; branch to if last drawing direction =/= current drawing direction
	; will check if prior direction is 0 (indicates prior location was an O
	; and will create line if that is the case,
	; also updates last_user_pos and last drawing dir

	; if prior direction is not 0, it will first create a corner at the prior position
	; and then perform above actions

	cmp r1, #0
	beq write_line_at_user

cross_detected:
	; create cross at previous position
	ldr r2, ptr_char_dir
	ldrb r1, [r2]				; fetch cross to use

	strb r1, [r4, #5]			; write cross to string for printing color

	mov r1, r4					; fetch string to write to monitor
	ldrh r0, last_user_pos
	bl print_at_pos_board		; write cross to serial monitor

	mov r1, #0x3300
	add r1, r1, #0x30
	add r1, r1, r5				; string to place in board. converted int to ascii

	ldr r0, last_user_pos		; overwrite board string with cross
	bl overwrite_board



write_line_at_user:
	; create line at current position
	mov r0, r6				; fetch current drawing direction
	ldr r2, ptr_char_dir
	ldrb r1, [r2, r0]		; fetch line to use

	strb r1, [r4, #5]		; write line to string for printing color

	mov r1, r4				; fetch string to write to monitor
	ldr r0, ptr_user_pos
	ldrh r0, [r0]
	bl print_at_pos_board	; write line to serial monitor


	mov r1, #0x3300
	add r1, r1, #0x30
	add r1, r1, r5			; string to place in board. converted int to ascii

	ldr r0, ptr_user_pos	; overwrite board string with line
	ldrh r0, [r0]
	adr r3, last_user_pos
	strh r0, [r3]			; update last_user_pos
	bl overwrite_board

	adr r3, last_drawing_dir
	strh r6, [r3]				; update last_drawing_dir

color_end:
	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




space_pressed:
    STMFD sp!, {r0-r12, lr}

    ; when space is pressed:
    ; will overwrite is_drawing to match color of O underneath
    ; will overwrite is_drawing to 0 if no O underneath
    ; if O underneath is part of completed line, delete line..
    ; .. and overwrite is_drawing to match color of O underneath

    ldr r5, ptr_ptr_board    ; load pointer to pointer to board
    ldr r5, [r5]            ; load the actual pointer to the board
    ldr r3, ptr_user_pos
    ldrh r2, [r3]

    and r3, r2, #0x00FF        ; yy value
    and r4, r2, #0xFF00        ; xx value
    lsr r4, r4, #0x8           ; shift xx value

    mov r6, #20                ; byte length of board line
    mul r3, r3, r6
    lsl r4, r4, #1
    add r4, r4, r3            ; byte offset of characters
    add r6, r5, r4

    ldrh r0, [r6]
    and r2, r0, #0xFF
    cmp r2, #0x32
    bne space_stop_drawing

    ; r5 contains pointer to board
    ; r2 contains 16b color/character code

store_color:

    ; store color of O underneath
    ldr r1, ptr_is_drawing
    and r0, r0, #0xFF00
    lsr r0, r0, #0x8
    mov r2, #0x30
    sub r0, r0, r2
    strh r0, [r1]

	bl light_LED				;light up led according to color being drawn (or off if no color is being drawn)

	;procedure inline for checking if line is already drawn for the O

	sub r8, r6, #2				;r6 = one location to the left of the O
	ldrh r7, [r8]
	and r7, r7, #0xFF			;r7 = char code at r6
	cmp r7, #0x33
	itt ge						;if char > 33 (if char == +, - or |)
	movge r0, #0
	blge delete_line			;if line drawn for given color, clear the line

	add r8, r6, #2				;r6 = one location to the right of the O
	ldrh r7, [r8]
	and r7, r7, #0xFF			;r7 = char code at r6
	cmp r7, #0x33
	itt ge						;if char > 33 (if char == +, - or |)
	movge r0, #0
	blge delete_line			;if line drawn for given color, clear the line

	add r8, r6, #20				;r6 = one location down from the O
	ldrh r7, [r8]
	and r7, r7, #0xFF			;r7 = char code at r6
	cmp r7, #0x33
	itt ge						;if char > 33 (if char == +, - or |)
	movge r0, #0
	blge delete_line			;if line drawn for given color, clear the line

	sub r8, r6, #20				;r6 = one location up from the O
	ldrh r7, [r8]
	and r7, r7, #0xFF			;r7 = char code at r6
	cmp r7, #0x33
	itt ge						;if char > 33 (if char == +, - or |)
	movge r0, #0
	blge delete_line			;if line drawn for given color, clear the line


    LDMFD sp!, {r0-r12, lr}
    mov pc, lr

space_stop_drawing:
	ldr r1, ptr_is_drawing		; turn off drawing

	mov r0, #0x0
	strh r0, [r1]

	adr r1, last_drawing_dir	; clear drawing direction so color_line knows it starts on an O
	strh r0, [r1]
	bl light_LED				; light up led according to color being drawn (or off if no color is being drawn)

	LDMFD sp!, {r0-r12,lr}
	mov pc, lr


delete_line:
	STMFD sp!, {r1-r12,lr}


	;pass value into r0
	;if r0 = 0 -> delete color of line being drawn
	;else r0 = color of line to be deleted

	cmp r0, #0
	itt gt							;if r0 != 0, load r1 with color to be deleted
	movgt r1, r0
	bgt delete_start

	ldr r0, ptr_is_drawing
	ldrb r1, [r0]					;r1 = color of current drawing

delete_start:
	ldr r0, ptr_ptr_board
	ldr r2, [r0]					;r2 = base addr of current board
	add r2, r2, #22					;r2 = base addr of first position in game space

delete_loop:
	ldrh r0, [r2]					;r0 = char at r2
	cmp r0, #0x0000					;is char == 0x0, 0x0 (end of board string)
	beq delete_end					;if so go to end

	add r2, r2, #2					;increment ptr
	and r3, r0, #0xFF00				;mask r0 to get color code
	lsr r3, r3, #8					;shift and subtract 30 to convert from ascii val
	sub r3, r3, #0x30					;r3 = color code only
	cmp r1, r3						;is char's color the same as being drawn?
	bne delete_loop					;if no, move on to next char

	and r3, r0, #0x00FF				;r3 = char code only
	cmp r3, #0x32					;is char == O
	beq delete_loop					;if it is, move on to next char
	mov r3, #0x3030					;else overwrite with empty space
	sub r2, r2, #2
	strh r3, [r2]
	add r2, r2, #2

	b delete_loop

delete_end:
	LDMFD sp!, {r1-r12, lr}
	mov pc, lr




light_LED:
	STMFD sp!, {r0,r12,lr}

	ldr r0, ptr_is_drawing
	ldrb r1, [r0]					;r0 = color of current drawing

	cmp r1, #0x0
	ittt eq
	moveq r0, #0x0					;load r0 with color code for off
	bleq illuminate_RGB_LED			;turn led off
	beq led_end

	cmp r1, #0x1					;if color == blue
	ittt eq
	moveq r0, #0x2					;load r0 with color code for blue
	bleq illuminate_RGB_LED			;illuminate with blue
	beq led_end						;go to end

	cmp r1, #0x2					;if color == red
	ittt eq
	moveq r0, #0x1					;load r0 with color code for red
	bleq illuminate_RGB_LED			;illuminate with red
	beq led_end						;go to end

	cmp r1, #0x3					;if color == green
	ittt eq
	moveq r0, #0x4					;load r0 with color code for green
	bleq illuminate_RGB_LED			;illuminate with green
	beq led_end						;go to end

	cmp r1, #0x4					;if color == cyan
	ittt eq
	moveq r0, #0x6					;load r0 with color code for cyan
	bleq illuminate_RGB_LED			;illuminate with cyan
	beq led_end						;go to end

	cmp r1, #0x5					;if color == white
	ittt eq
	moveq r0, #0x7					;load r0 with color code for white
	bleq illuminate_RGB_LED			;illuminate with white
	beq led_end						;go to end

	cmp r1, #0x6					;if color == magenta
	ittt eq
	moveq r0, #0x3					;load r0 with color code for magenta
	bleq illuminate_RGB_LED			;illuminate with magenta
	beq led_end						;go to end

	cmp r1, #0x7					;if color == yellow
	ittt eq
	moveq r0, #0x5					;load r0 with color code for yellow
	bleq illuminate_RGB_LED			;illuminate with yellow
	beq led_end						;go to end

led_end:

	LDMFD sp!, {r0,r12,lr}
	mov pc, lr
