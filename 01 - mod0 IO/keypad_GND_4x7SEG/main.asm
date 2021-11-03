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
        MOV AL, 81H
	OUT 0AFH, AL
	MOV BX, 0AH
	MOV DX, 0AAAAH
	MOV CX, 4H
ENDLESS:
        PUSH BX
        CALL GDIGIT
	POP BX
	CMP BX, AX
	JZ  ENDLESS
	MOV BX, AX
	SHL DX, CL
	OR  DX, AX
	JMP ENDLESS
GDIGIT PROC
        ; reads a digit from keypad at 0ADH and prints current 4-digit num
	; returns it using AL
	; scan 3rd column
NODIG:	MOV AX, DX
	CALL LIGHT
        MOV AL, 1H
	OUT 0A9H, AL
	IN AL, 0ADH
	AND AL, 0FH
	MOV BX, 4
	CMP AL, 0H
	JNZ EXIT
	; scan 2nd column
	MOV AL, 2H
	OUT 0A9H, AL
	IN AL, 0ADH
	AND AL, 0FH
	MOV BX, -1
	CMP AL, 0H
	JNZ EXIT
	; scan 1st column
	MOV AL, 4H
	OUT 0A9H, AL
	IN AL, 0ADH
	AND AL, 0FH
	MOV BX, 8
	CMP AL, 8H
	JZ  STAR
	CMP AL, 0H
	JNZ EXIT
	JMP NODIG
STAR:   MOV AX, 0AAAAH
        MOV DX, 0AAAAH
        JMP RST
EXIT:	AND AX, 0FH
        MOV SI, AX
	MOV AL, KEYS[SI+BX]
RST:    RET
GDIGIT ENDP
LIGHT PROC
        ; Sends 4 digits (each 4 bits, total: 1 word) represented by AX
	; Assumes DIGITS arr is defined in DS
	PUSH AX
	PUSH CX
	PUSH BX
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
	POP BX
	POP CX
	POP AX
	RET
LIGHT ENDP
CODE    ENDS
        END START