	.text
	.global boards
	.global select_board	; assumes timer is active
	.global board
	.global ptr_to_board
	.global check_if_completed
	.global overwrite_board

	.data
boards:
		.string "101010101010101010",0xA,0xD	;board 1
		.string "102300000000222110",0xA,0xD
		.string "100027230027000010",0xA,0xD
		.string "100022000000002110",0xA,0xD
		.string "100000000000002410",0xA,0xD
		.string "102400000000002610",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "102500002526000010",0xA,0xD
		.string "101010101010101010",0x0,0x0	;extra 0 at the end is a completeded flag 0 => not completed, 1 => completed
		
		.string "101010101010101010",0xA,0xD	;board 2
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 3
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 4
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 5
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 6
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 7
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 8
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0

		.string "101010101010101010",0xA,0xD	;board 9
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 10
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 11
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 12
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 13
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 14
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 15
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0
		
		.string "101010101010101010",0xA,0xD	;board 16
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "100000000000000010",0xA,0xD
		.string "101010101010101010",0x0,0x0


ptr_to_boards:	.word	boards
ptr_to_board:	.word	0x0
TIMER_TOP:	.equ 0x4003
TIMER_BOT:	.equ 0x0000
BOARDSIZE:	.equ 0xB4




overwrite_board:
	STMFD sp!, {r4-r12, lr}
	; writes to board string, does not rewrite serial monitor
	; r0 = position 0xXXYY, r1 = character/color code (2 char string)
	ldr r4, ptr_to_board
	and r2, r0, #0xFF00
	lsr r2, r2, #0x7			; shift right by 8, multiply by 2.
	and r3, r0, #0x00FF
	mov r0, #20			; mult by board width
	mult r3, r3, r0
	add r3, r3, r2		; offset to specific color/character code

	strh r1, [r4, r3]
	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




fetch_value:
	STMFD sp!, {r4-r12, lr}
	; fetches halfword character/color code from board
	; r0 = position 0xXXYY
	; return r0 = halfword character color code
	ldr r4, ptr_to_board
	and r2, r0, #0xFF00
	lsl r2, r2, #0x1
	and r3, r0, #0x00FF
	mov r0, #20			; mult by board width
	mult r3, r3, r0
	add r3, r3, r4		; offset to specific color/character code

	ldrh r0, [r4, r3]
	LDMFD sp!, {r4-r12, lr}
	mov pc, lr




select_board:
	STMFD sp!, {r4-r12, lr}

	mov r0, #TIMER_BOT
	movt r0, #TIMER_TOP
	add r0, r0, #0x048		;r0 = timer value

	; ldrh r6, [r0]			;load halfword into r1 as a "random" value

	mov r0, #0x0	; mov r1
	mov r6, #15
	mov r8, r6		; validator to check if all are completed
try_new_board:
	add r6, r6, #0x1		; increment board selection
	and r6, r6, #0xF		; r0 = offset for board to be selected

	mov r5, #BOARDSIZE		;r1 = board size for multiplication
	mul r5, r6, r5			;r0 = offset amount for board

	ldr r4, ptr_to_boards
	add r0, r4, r5			;r0 = base addr of respective board

	bl check_if_completed
	cmp r8, r6
	beq all_boards_solved
	cmp r0, #1
	beq try_new_board		;if board is completed, branch to beginning of loop to select different board

	add r0, r4, r5			; r0 contains board pointer
	adr r1, ptr_to_board
	str r0, [r1]

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr

all_boards_solved:
	mov r0, #0x0

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr




check_if_completed:
	STMFD sp!, {r4-r12, lr}

	add r0, r0, #BOARDSIZE
	sub r0, r0, #2		;r0 =  offset for completed bit

	ldrb r1, [r0]		;r1 = 0x0X	=> null terminator and completed bit

	cmp r1, #0x00
	ite eq
	moveq r0, #0x0		;if not completed, return 0
	movne r0, #0x1 		;else return 1

	LDMFD sp!, {r4-r12, lr}
	MOV pc, lr
