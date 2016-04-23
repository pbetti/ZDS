;;
;; ZDS - parallel link binary image loader
;;

; link to monitor and bios symbols
rsym bios.sym
rsym parload1.sym

;; since this is a standard cp/m .com file we are loaded at TPA base address
;; (100H). This not so good since most probably the file we transfer from
;; remote are programs, so they too wants to stay in the same space!!
;; To solve the problem we move ourselves in the upper memory, just below
;; the ccp.
;; Now is not possible to specify absolute/relative segments with ZMAC
;; cross assembler. SO we assemble the program in two parts one at ORG'ed
;; at 100H and one below CCP, join the binaries togheter and voila': all done!
;; This is the 100H part or the relocator part...
;
include parload.inc
;
	ORG	TPA
PINIT:
	LD	HL,MYTOP
	LD	BC,RELADR		; minus offset
	SBC	HL,BC
	LD	C,L
	LD	B,H			; BC IS MY SIZE
	LD	HL,BEGIN		; FROM...
	LD	DE,RELADR		; ...TO
	LDIR				; MOVED
	JP	RELADR

	ORG	BEGIN
FILLER:
	END
