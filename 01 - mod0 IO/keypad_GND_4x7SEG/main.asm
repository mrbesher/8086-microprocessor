;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Pzt Eki 7 2019
; Processor: 8086
; Compiler:  MASM32
;
; Before starting simulation set Internal Memory Size 
; in the 8086 model properties to 0x10000
;====================================================================

STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
DIGITS  DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 98H, 0FFH
KEYS    DB 2H, 5H, 0AH, 8H, 0AH, 3H, 6H, 0H, 9H, 1H, 4H, 0AH, 7H, 0AH, 0AH, 0AH, 0AH
; 2nd row  2   5       8                 0 (OFFSET: -1)
; 3rd row                        3   6       9                #[NULL]  (OFFSET: 4)
; 1st row                                         1  4         7                  *[EMPTY] (OFFSET: 8)
DATA    ENDS


CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
START:
        MOV AX, DATA
	MOV DS, AX
        MOV AL, 81H ; CW output: PA, PB, PCU. input: PCL
	OUT 0AFH, AL ; set CW
	MOV DX, 0AAAAH ; set DX to 0AH corresponding to empty 7SEG
ENDLESS:
        CALL GDIGIND ; doesn't exit until a key is read
	MOV SI, AX
	MOV AL, KEYS[SI+BX] ; Get the digit corresponding to AL[0..3]
	MOV CL, 4H
	SHL DX, CL
	OR  DX, AX
	CALL WKEYUP
	JMP ENDLESS
	

GDIGIND PROC
        ; reads port from keypad at 0ADH and prints current 4-digit num in DX
	; returns port value using AL, its offset in KEYS using BX
NODIG:	MOV AX, DX ; mov current 4-digit number from DX
	CALL LIGHT
	; scan 3rd column
        MOV AL, 1H
	OUT 0A9H, AL
	IN AL, 0ADH
	MOV BX, 4 ; set offset for keys arr
	AND AL, 0FH ; mask LS 4-bits (PCL) also set flags
	JNZ EXIT ; key detected
	; scan 2nd column
	MOV AL, 2H
	OUT 0A9H, AL
	IN AL, 0ADH
	MOV BX, -1
	AND AL, 0FH
	JNZ EXIT
	; scan 1st column
	MOV AL, 4H
	OUT 0A9H, AL
	IN AL, 0ADH
	MOV BX, 8
	AND AL, 0FH
	CMP AL, 8H
	JZ SDET
	TEST AL, 0FH
	JNZ EXIT
	JMP NODIG
SDET:	CALL STAR
        JMP NODIG
EXIT:   RET
GDIGIND ENDP

STAR PROC
        ; sets AX and DX to 0AAAAH if '*' is detected for a long time
        MOV CX, 02FFH ; delay to make sure '*' is held down
STILL:	IN AL, 0ADH ; read the key again (1st column is selected already)
	AND AL, 0FH
	TEST AL, 8H
	JZ RST ; star is not pressed for a long (enough) time
	MOV AX, DX
	CALL LIGHT ; send digits stored in ax copied from dx
	LOOP STILL
	MOV AX, 0AAAAH ; set to off if survived the loop
        MOV DX, 0AAAAH
RST:	XOR AL, AL
        RET
STAR ENDP	
	

WKEYUP PROC
        ; scans 0ADH until getting 0
LO1:	MOV AX, DX
        CALL LIGHT
        IN AL, 0ADH
	TEST AL, 0FH
	JNZ LO1
	RET
WKEYUP ENDP


LIGHT PROC
        ; lights 4 BCD digits (each 4 bits, total: 1 word) represented by AX
	; Assumes DIGITS arr is defined in DS and addresses are PC: 0ADH, PB: 0ABH
	PUSH CX
	PUSH DX
	MOV DL, 10H
	MOV CX, 4H
DIG:	MOV SI, AX
        AND SI, 000FH
	MOV BX, AX ; reserve AX
	MOV AL, 0FFH
	OUT 0ABH, AL
	MOV AL, DL
	OUT 0ADH, AL
	SHL DL, 1 ; set next bit in Port-C
	MOV AL, DIGITS[SI]
	OUT 0ABH, AL
	MOV AX, BX
	MOV BX, CX ; reserve CX for loop
	MOV CL, 4H
	SHR AX, CL ; get rid of the LS 4-bits
	MOV CX, BX ; restore CX
	LOOP DIG
	POP DX
	POP CX
	RET
LIGHT ENDP


CODE    ENDS
        END START