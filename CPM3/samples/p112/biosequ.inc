; D-X Designs Pty. Ltd.  4/12/95  D. R. Brooks
;
;========== Z180 Internal Interrupt Vectors ========

; The following vectors are offsets from the value 
; loaded in IL, the Interrupt Vector Low register.

VINT1	EQU	0	;External INT-1 pin
VINT2	EQU	2	;External INT-2 pin
VPRT0	EQU	4	;Timer 0
VPRT1	EQU	6	;Timer 1
VDMA0	EQU	8	;DMA Ch-0
VDMA1	EQU	0AH	;DMA Ch-1
VCSIO	EQU	0CH	;Clocked serial I/O
VASC0	EQU	0EH	;Asynch. comms. Ch-0
VASC1	EQU	10H	;Asynch. comms. Ch-1

;========== Z180 System Control Registers ==========
;NB These registers may be relocated to multiples of
; 40H, by setting the IO Control Register (ICR = 3FH)
; The addresses below are valid with ICR=0 (else they
; are offsets from the ICR base value).

; ASCI Registers

CNTLA0	EQU	00H	; ASCI Control Reg A Ch0
CNTLA1	EQU	01H	; ASCI Control Reg A Ch1
CNTLB0	EQU	02H	; ASCI Control Reg B Ch0
CNTLB1	EQU	03H	; ASCI Control Reg B Ch1
STAT0	EQU	04H	; ASCI Status Reg Ch0
STAT1	EQU	05H	; ASCI Status Reg Ch1
TDR0	EQU	06H	; ASCI TX Data Reg Ch0
TDR1	EQU	07H	; ASCI TX Data Reg Ch1
RDR0	EQU	08H	; ASCI RX Data Reg Ch0
RDR1	EQU	09H	; ASCI RX Data Reg Ch1
BRK0	EQU	12H	; Break Control Reg Ch0
BRK1	EQU	13H	; Break Control reg Ch1

; CSI/O Registers

CNTR	EQU	0AH	; CSI/O Control Reg
TRDR	EQU	0BH	; CSI/O TX/RX Data Reg

; Timer Registers

TMDR0L	EQU	0CH	; Timer Data Reg Ch0-Low
TMDR0H	EQU	0DH	; Timer Data Reg Ch0-High
RLDR0L	EQU	0EH	; Timer Reload Reg Ch0-Low
RLDR0H	EQU	0FH	; Timer Reload Reg Ch0-High
TCR	EQU	10H	; Timer Control Reg
TMDR1L	EQU	14H	; Timer Data Reg Ch1-Low
TMDR1H	EQU	15H	; Timer Data Reg Ch1-High
RLDR1L	EQU	16H	; Timer Reload Reg Ch1-Low
RLDR1H	EQU	17H	; Timer Reload Reg Ch1-High
FRC	EQU	18H	; Free-Running Counter

; DMA Registers

SAR0L	EQU	20H	; DMA Source Addr Reg Ch0-Low
SAR0H	EQU	21H	; DMA Source Addr Reg Ch0-High
SAR0B	EQU	22H	; DMA Source Addr Reg Ch0-B
DAR0L	EQU	23H	; DMA Destn  Addr Reg Ch0-Low
DAR0H	EQU	24H	; DMA Destn  Addr Reg Ch0-High
DAR0B	EQU	25H	; DMA Destn  Addr Reg Ch0-B
BCR0L	EQU	26H	; DMA Byte Count Reg Ch0-Low
BCR0H	EQU	27H	; DMA Byte Count Reg Ch0-High
MAR1L	EQU	28H	; DMA Memory Addr Reg Ch1-Low
MAR1H	EQU	29H	; DMA Memory Addr Reg Ch1-High
MAR1B	EQU	2AH	; DMA Memory Addr Reg Ch1-B
IAR1L	EQU	2BH	; DMA I/O Addr Reg Ch1-Low
IAR1H	EQU	2CH	; DMA I/O Addr Reg Ch1-High
BCR1L	EQU	2EH	; DMA Byte Count Reg Ch1-Low
BCR1H	EQU	2FH	; DMA Byte Count Reg Ch1-High
DSTAT	EQU	30H	; DMA Status Reg
DMODE	EQU	31H	; DMA Mode Reg
DCNTL	EQU	32H	; DMA/WAIT Control Reg

; System Control Registers

CCR	EQU	1FH	; CPU control reg.
IL	EQU	33H	; INT Vector Low Reg
ITC	EQU	34H	; INT/TRAP Control Reg
RCR	EQU	36H	; Refresh Control Reg
CBR	EQU	38H	; MMU Common Base Reg
BBR	EQU	39H	; MMU Bank Base Reg
CBAR	EQU	3AH	; MMU Common/Bank Area Reg
OMCR	EQU	3EH	; Operation Mode Control Reg
ICR	EQU	3FH	; I/O Control Reg

; Features unique to Z80182

INTYPE	EQU	0DFH	; Interrupt edge/pin mux reg.
WSGCS	EQU	0D8H	; Wait-State Generator CS
ENH182	EQU	0D9H	; Z80182 Enhancements Reg
PINMUX	EQU	0DFH	; Interrupt Edge/Pin Mux Reg
RAMUBR	EQU	0E6H	; RAM End Boundary
RAMLBR	EQU	0E7H	; RAM Start Boundary
ROMBR	EQU	0E8H	; ROM Boundary
FIFOCTL	EQU	0E9H	; FIFO Control Reg
RTOTC	EQU	0EAH	; RX Time-Out Time Const
TTOTC	EQU	0EBH	; TX Time-Out Time Const
FCR	EQU	0ECH	; FIFO Register
SCR	EQU	0EFH	; System Pin Control
RBR	EQU	0F0H	; MIMIC RX Buffer Reg
THR	EQU	0F0H	; MIMIC TX Holding Reg
IER	EQU	0F1H	; Interrupt Enable Reg
LCR	EQU	0F3H	; Line Control Reg
MCR	EQU	0F4H	; Modem Control Reg
LSR	EQU	0F5H	; Line Status Reg
MSR	EQU	0F6H	; Modem Status Reg
MSCR	EQU	0F7H	; MIMIC Scratch Reg
DLATL	EQU	0F8H	; Divisor latch LS
DLATM	EQU	0F9H	; Divisor latch MS
TTCR	EQU	0FAH	; TX Time Constant
RTCR	EQU	0FBH	; RX Time Constant
IVEC	EQU	0FCH	; MIMIC Interrupt Vector
MIMIE	EQU	0FDH	; MIMIC Interrupt Enable Reg
IUSIP	EQU	0FEH	; MIMIC Interrupt Under-Service Reg
MMCR	EQU	0FFH	; MIMIC Master Control Reg

; Z80182 PIO Registers

DDRA	EQU	0EDH	; Data Direction Reg A
DRA	EQU	0EEH	; Port A Data
DDRB	EQU	0E4H	; Data Direction Reg B
DRB	EQU	0E5H	; Port B Data
DDRC	EQU	0DDH	; Data Direction Reg C
DRC	EQU	0DEH	; Port C data

; ESCC Registers

SCCACNT	EQU	0E0H	; ESCC Control Channel A
SCCAD	EQU	0E1H	; ESCC Data Channel A
SCCBCNT	EQU	0E2H	; ESCC Control Channel B
SCCBD	EQU	0E3H	; ESCC Data Channel B

; [E]SCC Internal Register Definitions

RR0	EQU	00H
RR1	EQU	01H
RR2	EQU	02H
RR3	EQU	03H
RR6	EQU	06H
RR7	EQU	07H
RR10	EQU	0AH
RR12	EQU	0CH
RR13	EQU	0DH
RR15	EQU	0FH

WR0	EQU	00H
WR1	EQU	01H
WR2	EQU	02H
WR3	EQU	03H
WR4	EQU	04H
WR5	EQU	05H
WR6	EQU	06H
WR7	EQU	07H
WR9	EQU	09H
WR10	EQU	0AH
WR11	EQU	0BH
WR12	EQU	0CH
WR13	EQU	0DH
WR14	EQU	0EH
WR15	EQU	0FH

; Port definitions for the FDC37C665/6 combo chips
; Prefix a "_" as some names clash with Z180 names

; Diskette controller

_DOR	EQU	92H	; Digital Output
_MSR	EQU	94H	; Main Status
_DSR	EQU	94H	; Data-rate Select
_DATA	EQU	95H	; Data & commands I/O
_DIR	EQU	97H	; Digital Input
_CCR	EQU	97H	; Confign. Control

_DMA	EQU	0A0H	; Diskette DMA address

; Serial port		; RD/WR

_RBR	EQU	98H	;R	Receiver buffer
_THR	EQU	98H	;W	Transmit holding reg.
_IER	EQU	99H	;RW	Interrupt-enable reg.
_IIR	EQU	9AH	;R	Interrupt ident. reg.
_FCR	EQU	9AH	;W	FIFO control reg.
_LCR	EQU	9BH	;RW	Line control reg.
_MCR	EQU	9CH	;RW	Modem control reg.
_LSR	EQU	9DH	;RW	Line status reg.
_MMSR	EQU	9EH	;RW	Modem status reg. (name clash w. FDC)
_SCR	EQU	9FH	;N/A	Scratch reg. (not avail. in XT)
_DDL	EQU	98H	;RW	Divisor LSB | with DLAB
_DLM	EQU	99H	;RW	Divisor MSB | set high

; Parallel Port IO Addresses

DPORT	EQU	8CH	; Data port
SPORT	EQU	8DH	; Status port
CPORT	EQU	8EH	; Control port

;--- Standard drive-type identifiers --- P112 Definitions ---

NTYPES	EQU	5	; No. of defined types

D5_360	EQU	0	; 5", 360kB
Am_800	EQU	1	; 3/5", 800kB
BP_176	EQU	2	; 3", 1.76MB
D3_144	EQU	3	; 3", 1.44MB
D3_288	EQU	4	; 3", 2.88MB

; Standard drive-parameter block.  Format is same as MS-DOS BIOS.

SPEC_1	EQU	 0	; "Specify" byte 1
SPEC_2	EQU	 1	; "Specify" byte 2
MTROFF	EQU	 2	; Wait before stop motor
SECSZE	EQU	 3	; Bytes/sector (must be > 0)
EOT	EQU	 4	; Final sector no.
GPL	EQU	 5	; Gap length
DTL	EQU	 6	; Data transfer length
GAPFMT	EQU	 7	; Gap-3 length: Format
DATFMT	EQU	 8	; Data fill: Format
SETTLE	EQU	 9	; Head-settle time (mS)
MTRON	EQU	10	; Motor-start (* 1/8 sec.)
MAXCYL	EQU	11	; Max. cylinder no.
DRATE	EQU	12	; Data rate
SCTR_1	EQU	13	; 1st Physical Sector Number

; Ascii Character Equates

LF	EQU	0AH	; Line Feed
CR	EQU	0DH	; Carriage Return
