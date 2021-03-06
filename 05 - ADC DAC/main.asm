CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
SAMPLES DB 100 DUP(?)

SAMPLEN EQU 100
ADR8255 EQU 0H
ADRADCS EQU 200H
ADRADCI EQU 400H
ADRDACS EQU 600H
ADR8254 EQU 800H
DATA    ENDS


START PROC
    MOV AX, DATA
    MOV DS, AX
	
    
    ; MOD SETTING FOR 8255
    MOV DX, ADR8255
    MOV AL, 10010000B ; mod0, PA input
    ADD DX, 110B ; control word
    OUT DX, AL
    
    MOV AL, 00010100B ; CNTR0, LSB, MOD2, BINARY
    MOV DX, ADR8254
    ADD DX, 110B ; control register
    OUT DX, AL
    
    ; SEND 4 TO 8254 (CLK IS 80) TO CNTR0
    MOV DX, ADR8254
    MOV AL, 4H
    OUT DX, AL
    
    XOR SI, SI

    MOV CX, SAMPLEN
    
READ_AGAIN:
    MOV DX, ADR8255
    ; WAIT FOR OUT 0 FROM 8254 CNTR0
    CALL WFOROUT
    
    
    ; TELL ADC TO SAMPLE SIGNAL
    MOV DX, ADRADCS
    OUT DX, AL
    
    MOV DX, ADRADCI
NOTDONE:
    IN AL, DX
    TEST AL, 10H ; IS INTR 0 (ACTIVE)
    JNZ NOTDONE
    
    ; READ SAMPLED DATA
    MOV DX, ADRADCS
    IN AL, DX
    
    MOV SAMPLES[SI], AL
    INC SI
    
    LOOP READ_AGAIN

RE_DISPLAY:    
    MOV CX, SAMPLEN
    XOR SI, SI
    
NEXT_SAMPLE:
    MOV DX, ADR8255
    CALL WFOROUT

    MOV DX, ADRDACS
    MOV AL, SAMPLES[SI]
    INC SI
    OUT DX, AL
    LOOP NEXT_SAMPLE
    
    JMP RE_DISPLAY
	RET
START ENDP

WFOROUT PROC NEAR
; INPUT: DX (address of 8255 where PA0 represents OUT of 8254)
; waits till out goes 0 and exits 0
COUNTING:
    IN AL, DX
    TEST AL, 1B
    JNZ COUNTING

EXITPULSE:
    IN AL, DX
    TEST AL, 1B
    JZ EXITPULSE
    
    RET
WFOROUT ENDP

	
CODE    ENDS
        END START