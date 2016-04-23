; this is by Andre Adrian
; http://www.andreadrian.de/oldcpu/Z80_number_cruncher.html
;==================================================
; MULTIPLY ROUTINE 32*32BIT=32BIT
; H'L'HL = B'C'BC * D'E'DE
; NEEDS REGISTER A, CHANGES FLAGS
;
MUL32:
	AND	A               ; reset carry flag
	SBC	HL,HL           ; lower result = 0
	EXX
	SBC	HL,HL           ; higher result = 0
	LD	A,B             ; mpr is ac'bc
	LD	B,32            ; initialize loop counter
MUL32LOOP:
	SRA	A               ; right shift mpr
	RR	C
	EXX
	RR	B
	RR	C               ; lowest bit into carry
	JR	NC,MUL32NOADD
	ADD	HL,DE           ; result += mpd
	EXX
	ADC	HL,DE
	EXX
MUL32NOADD:
	SLA	E               ; left shift mpd
	RL	D
	EXX
	RL	E
	RL	D
	DJNZ	MUL32LOOP
	EXX

; result in H'L'HL
	RET

;==================================================
; 1 BIT SHIFT RIGHT ARITHMETRIC ROUTINE 32BIT = 32BIT
; BCDE >>= 1
; CHANGES FLAGS
;
SRA32:
        SRA     B
        RR      C
        RR      D
        RR      E

; result is in BCDE.
; the lowest bit was shifted into carry.
        RET

;------------------------------------------------------------------------
