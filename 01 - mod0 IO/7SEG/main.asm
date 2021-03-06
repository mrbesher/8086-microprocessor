;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Cum Mar 11 2016
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
DIGITS  DB 0C0H
DATA    ENDS

CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
START:
        MOV AX, DATA
	MOV DS, AX
        MOV AL, 80H
	OUT 66H, AL
	MOV AL, 0FFH
	OUT 62H, AL
	MOV AL, 0FFH
	OUT 64H, AL
	MOV AL, DIGITS
	OUT 62H, AL
        ; Write your code here
ENDLESS:

        JMP ENDLESS
CODE    ENDS
        END START