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
CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
; 8254 REGISTER ADDRESSES
CNTR0 EQU 81H
CNTR1 EQU 83H
CNTR2 EQU 85H
CW EQU 87H
; 8259 REGISTER ADDRESSES
A08259 EQU 80H
A18259 EQU 82H
DATA    ENDS

STEPAX PROC FAR
        INC AX
        IRET
STEPAX ENDP

START PROC FAR
        MOV AX, DATA
        MOV DS, AX
        
        XOR AX, AX
        MOV ES, AX
        ; 08H is the type of the interrupt we will be setting
        MOV AL, 08H
        MOV AH, 4 ; each interrupt proc takes 4 bytes in the IVT
        MUL AH ; AH*AL -> AX
        MOV BX, AX ; will be used as an offest
        
        LEA AX, STEPAX
        MOV WORD PTR ES:[BX], AX
        MOV AX, CS
        MOV WORD PTR ES:[BX+2], AX
        
        ; ICW1
        MOV AL, 00010011B
        OUT A08259, AL
        
        ; ICW2
        MOV AL, 00001000B ; INTR type
        OUT A18259, AL
        
        ; ICW4
        MOV AL, 00000011B
        OUT A18259, AL
        
        MOV AL, 00110110B ; CNTR0, LSb then MSb,  mod3, binary
        OUT CW, AL
        
        MOV AL, 01010100B ; CNTR1, LSb,  mod2, binary
        OUT CW, AL
        
        ; set the counters to output a pulse every 5s (clk is 10KHz)
        MOV AX, 4999 ; dividing by 5000 effectively read the datasheet of 8253A
        OUT CNTR0, AL
        MOV AL, AH
        OUT CNTR0, AL
        
        MOV AL, 9 ; effectively dividing by 10 read the 8253A datasheet
        OUT CNTR1, AL
        
        
        STI
        XOR AX, AX
ENDLESS:
        JMP ENDLESS
RETF
START ENDP

CODE    ENDS
        END START