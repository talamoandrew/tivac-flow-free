	.text
	; self -> global
	.global movement_interpreter

	; lab6.s
	.global user_pos
	.global ptr_to_board

	; lab6library.s
	.global output_string

	; coloring.s
	.global is_drawing
	.global delete_line
	.global last_drawing_dir

	.data
left:			.string 27,"[1D", 0x0
right:			.string 27,"[1C", 0x0
up:				.string 27,"[1A", 0x0
down:			.string 27,"[1B", 0x0

ptr_to_left:	.word left
ptr_to_right:	.word right
ptr_to_up:		.word up
ptr_to_down:	.word down

ptr_user_pos:	.word user_pos
ptr_ptr_board:	.word ptr_to_board

ptr_is_drawing: .word is_drawing

movement_interpreter:

	STMFD sp!, {r4-r12,lr}
	; TODO:
	;-read last_drawing_dir from coloring.s to draw line accordingly
	;-restrict movement over colored Os when drawing

	;r0 =  ascii code of key pressed
	cmp r0, #0x77
	bne checkA
	ldr r0, ptr_user_pos		; update y position
	ldrh r1, [r0]				; r1 = XXYY
	and r2, r1, #0x00FF			; r2 = yy
	and r1, r1, #0xFF00			; r1 = xx(o)
	cmp r2, #0x0001				; if y <= 1

	beq mov_end					; go to end, else decrement y val
	push {r2}

;```````````````````````````````````````````````````````````````````````````````````
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r6, #0
	beq moveW					;if not drawing, no need to do subsequent checks

	;check location of desired movement
	ldr r3, ptr_ptr_board
	ldr r3, [r3]				; r3 = base addr of current board

	mov r4, #20					; byte length of one board row
	sub r2, r2, #1				; y - 1 to check position above current position
	mul r2, r2, r4				; (y-1) * r4
	lsr r5, r1, #8
	lsl r5, r5, #1				; x * 2
	add r2, r2, r5				; byte offset for pos (x,y-1) = r4(y-1) + 2x
	add r3, r3, r2				; r3 = base addr of desired position

	;check if line of same color, if so restrict movement
	ldrh r4, [r3]
	and r5, r4, #0xFF00
	lsr r5, r5, #8
	sub r5, r5, #0x30			;r5 = color code only
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r5, r6					;if eq do not move
	itt eq
	popeq {r2}
	beq mov_end

	;check if line of different color, if so delete line
	and r6, r4, #0x00FF
	cmp r6, #0x33				;if position above current location is a line of a different color, cross it and delete old line
	blt moveW
	push {r0}
	mov r0, r5
	bl delete_line
	pop {r0}

moveW:
	pop{r2}
;`````````````````````````````````````````````````````````````````````````````````

	sub r2, r2, #0x0001			; y--
	orr r1, r1, r2				; r1 = XXYY
	strh r1, [r0]
	ldr r0, ptr_to_up
	bl output_string
	b mov_end
	;update y pos

checkA:
	cmp r0, #0x61
	bne checkS
	ldr r0, ptr_user_pos		;update x position
	ldrh r1, [r0]				;r1 = XXYY
	and r2, r1, #0xFF00			;r2 = xx
	and r1, r1, #0x00FF			;r1 = (0)yy
	cmp r2, #0x0100				;if x <= 1
	beq mov_end					;do not decrement, else decrement x val
	push {r1,r2}

	;```````````````````````````````````````````````````````````````````````````````````
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r6, #0
	beq moveA					;if not drawing, no need to do subsequent checks

	;check location of desired movement
	ldr r3, ptr_ptr_board
	ldr r3, [r3]				; r3 = base addr of current board

	mov r4, #20					; byte length of one board row
	mul r1, r1, r4				; y * r4

	lsr r5, r2, #8
	sub r5, r5, #1				; x  + 1 to check position to right of current position
	lsl r5, r5, #1				; (x+1) * 2
	add r2, r1, r5				; byte offset for pos (x + 1,y) = r4y + 2(x+1)
	add r3, r3, r2				; r3 = base addr of desired position

	;check if line of same color, if so restrict movement
	ldrh r4, [r3]
	and r5, r4, #0xFF00
	lsr r5, r5, #8
	sub r5, r5, #0x30			;r5 = color code only
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r5, r6					;if eq do not move
	itt eq
	popeq {r1,r2}
	beq mov_end

	;check if line of different color, if so delete line
	and r6, r4, #0x00FF
	cmp r6, #0x33				;if position to left of current location is a line of a different color, cross it and delete old line
	blt moveA
	push {r0}
	mov r0, r5
	bl delete_line
	pop {r0}

moveA:
	pop{r1,r2}
;`````````````````````````````````````````````````````````````````````````````````


	sub r2, r2, #0x0100
	orr r1, r1, r2				;r1 = XXYY
	strh r1, [r0]
	ldr r0, ptr_to_left
	bl output_string
	b mov_end
	;update x pos

checkS:
	cmp r0, #0x73
	bne checkD
	ldr r0, ptr_user_pos
	ldrh r1, [r0]
	and r2, r1, #0x00FF
	and r1, r1, #0xFF00
	cmp r2, #0x0007

	beq mov_end
	push {r2}

		;```````````````````````````````````````````````````````````````````````````````````
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r6, #0
	beq moveS					;if not drawing, no need to do subsequent checks

	;check location of desired movement
	ldr r3, ptr_ptr_board
	ldr r3, [r3]				; r3 = base addr of current board

	mov r4, #20					; byte length of one board row
	add r2, r2, #1				; y + 1 to check position below current position
	mul r2, r2, r4				; (y+1) * r4
	lsr r5, r1, #8
	lsl r5, r5, #1				; x * 2
	add r2, r2, r5				; byte offset for pos (x,y+1) = r4(y+1) + 2x
	add r3, r3, r2				; r3 = base addr of desired position

	;check if line of same color, if so restrict movement
	ldrh r4, [r3]
	and r5, r4, #0xFF00
	lsr r5, r5, #8
	sub r5, r5, #0x30			;r5 = color code only
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r5, r6					;if eq do not move
	itt eq
	popeq {r2}
	beq mov_end

	;check if line of different color, if so delete line
	and r6, r4, #0x00FF
	cmp r6, #0x33				;if position above current location is a line of a different color, cross it and delete old line
	blt moveS
	push {r0}
	mov r0, r5
	bl delete_line
	pop {r0}

moveS:
	pop{r2}
;`````````````````````````````````````````````````````````````````````````````````


	add r2, r2, #0x0001
	orr r1, r1, r2
	strh r1, [r0]
	ldr r0, ptr_to_down
	bl output_string
	b mov_end
	;update y pos

checkD:
	cmp r0, #0x64
	bne mov_end
	ldr r0, ptr_user_pos		;update x position
	ldrh r1, [r0]				;r1 = XXYY
	and r2, r1, #0xFF00			;r2 = xx
	and r1, r1, #0x00FF			;r1 = (0)yy
	cmp r2, #0x0700				;if x = 7
	beq mov_end					;do not increment, else increment x val
	push {r1,r2}


	;```````````````````````````````````````````````````````````````````````````````````
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r6, #0
	beq moveD					;if not drawing, no need to do subsequent checks

	;check location of desired movement
	ldr r3, ptr_ptr_board
	ldr r3, [r3]				; r3 = base addr of current board

	mov r4, #20					; byte length of one board row
	mul r1, r1, r4				; y * r4

	lsr r5, r2, #8
	add r5, r5, #1				; x  + 1 to check position to right of current position
	lsl r5, r5, #1				; (x+1) * 2
	add r2, r1, r5				; byte offset for pos (x + 1,y) = r4y + 2(x+1)
	add r3, r3, r2				; r3 = base addr of desired position

	;check if line of same color, if so restrict movement
	ldrh r4, [r3]
	and r5, r4, #0xFF00
	lsr r5, r5, #8
	sub r5, r5, #0x30			;r5 = color code only
	ldr r6, ptr_is_drawing
	ldrb r6, [r6]				;r6 = current drawing color code
	cmp r5, r6					;if eq do not move
	itt eq
	popeq {r1,r2}
	beq mov_end

	;check if line of different color, if so delete line
	and r6, r4, #0x00FF
	cmp r6, #0x33				;if position to left of current location is a line of a different color, cross it and delete old line
	blt moveD
	push {r0}
	mov r0, r5
	bl delete_line
	pop {r0}

moveD:
	pop{r1,r2}
;`````````````````````````````````````````````````````````````````````````````````

	add r2, r2, #0x0100
	orr r1, r1, r2				;r1 = XXYY
	strh r1, [r0]
	ldr r0, ptr_to_right
	bl output_string

	;update x pos

mov_end:

	LDMFD sp!, {r4-r12,lr}
 	MOV pc, lr
