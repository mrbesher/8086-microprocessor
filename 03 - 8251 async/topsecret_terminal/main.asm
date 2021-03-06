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
SERIALDATA  DB 32 DUP (0)
COMSTART DB 'SR'
COMEND   DB 'ST'
PACKNUM EQU 10
ARRSIZE EQU 32
COMLENGTH EQU 2H
DATAREG EQU 109H
CONTREG EQU 10DH
DATA    ENDS

CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
START PROC FAR
    MOV AX, DATA
	MOV DS, AX
    
    MOV DX, CONTREG
	XOR DX, 1000B ; flip A3 to address terminal3
	CALL INIT_8251 ; initializes 8251, connected to terminal3
    
	MOV DX, CONTREG
	CALL INIT_8251 ; initializes main 8251
	
	CALL INIT_CONN ; initializes connection by handshaking
    XOR DI, DI
    
    MOV CX, PACKNUM
REQ_DATA:
    CALL SEND_DATARQ
    CALL GET_MSG_TO_ARR
    LOOP REQ_DATA
    CALL END_CONN
    
    
    MOV CX, DI
    XOR SI, SI
ME_LO:
    MOV AL, SERIALDATA[SI]
    CALL PRT_TO_BFR
    INC SI
    LOOP ME_LO
ENDLESS:
    
    JMP ENDLESS
    RETF
START ENDP

GET_MSG_TO_ARR PROC NEAR
    ; get a message pack in the format 'n??'
    ; where n is the number of chars
    PUSH CX
    CALL GET_CHAR
    XOR AH, AH
    SUB AX, '0' ; get the value of the number
    MOV CX, AX
NXT_CHAR_MSG:
    CALL GET_CHAR
    MOV SERIALDATA[DI], AL
    INC DI
    LOOP NXT_CHAR_MSG
    POP CX
    RET
GET_MSG_TO_ARR ENDP


SEND_DATARQ PROC NEAR
    ; sends 'D' strobing the other device
    MOV DX, DATAREG
    MOV AL, 'D'
    CALL WAIT_TRDY
    OUT DX, AL
    RET
SEND_DATARQ ENDP


INIT_CONN PROC NEAR
    ; send 'SR' and waits for 'A' as an answer
    ; repeats request if answer is not 'A'
REINIT:
    XOR SI, SI
    MOV DX, DATAREG
    MOV CX, COMLENGTH
SS_NEXT_CODE:
    CALL WAIT_TRDY
    MOV AL, COMSTART[SI]
	OUT DX, AL
    INC SI
    LOOP SS_NEXT_CODE
    CALL GET_CHAR
    CMP AL, 'A'
    JNZ REINIT
    RET
INIT_CONN ENDP


END_CONN PROC NEAR
    ; send 'ST' and waits for 'P' as an answer
    ; repeats request if answer is not 'P'
REEND:    
    XOR SI, SI
    MOV DX, DATAREG
    MOV CX, COMLENGTH
SE_NEXT_CODE:
    CALL WAIT_TRDY
    MOV AL, COMEND[SI]
	OUT DX, AL
    INC SI
    LOOP SE_NEXT_CODE
    CALL GET_CHAR
    CMP AL, 'P'
    JNZ REEND
    RET
END_CONN ENDP


GET_CHAR PROC NEAR
; returns a char read from DATAREG using AL
    PUSH DX
    CALL WAIT_RRDY
    MOV DX, DATAREG
    IN AL, DX
    SHR AL, 1
    POP DX
    RET
GET_CHAR ENDP


WAIT_TRDY PROC NEAR
    ; waits till receive ready bit is active
    PUSH DX
    PUSH AX
    MOV DX, CONTREG
NOT_TREADY:
	IN AL, DX
	AND AL, 1B ; check D0 in status register
	JZ NOT_TREADY
    POP AX
    POP DX
	RET
WAIT_TRDY ENDP


WAIT_RRDY PROC NEAR
    ; waits till receive ready bit is active
    PUSH DX
    PUSH AX
    MOV DX, CONTREG
NOT_RREADY:
	IN AL, DX
	AND AL, 10B ; check D1 in status register
	JZ NOT_RREADY
    POP AX
    POP DX
	RET
WAIT_RRDY ENDP

INIT_8251 PROC NEAR
    ; input: DX (address of control/mod register)
    ; initializes 8251 for settings: 1 stop bit, no parity, 8 data bits, baudrate factor of 1
    ; mod set to async
	MOV AL, 01001101B ; 1 stop bit, no parity, 8 data bits, baudrate factor of 1
	OUT DX, AL
	
	MOV AL, 01000000B ; software reset
	OUT DX, AL
	
	MOV AL, 01001101B ; 1 stop bit, no parity, 8 data bits, baudrate factor of 1
	OUT DX, AL
	
	MOV AL, 00010101B ; clear error, receive and transmit enable
	OUT DX, AL
    
    RET
INIT_8251 ENDP

PRT_TO_BFR PROC NEAR
    ; input: AL (char to be printed)
    ; prints char sent by AL in terminal3
    PUSH DX
    PUSH AX
    MOV DX, CONTREG
    XOR DX, 1000B ; flip A3 to address terminal3
BF_NOT_TREADY:
	IN AL, DX
	AND AL, 1B ; check D0 in status register
	JZ BF_NOT_TREADY
    POP AX
    MOV DX, DATAREG
    XOR DX, 1000B ; flip A3 to address terminal3
    OUT DX, AL
    POP DX
    RET
PRT_TO_BFR ENDP


CODE    ENDS
        END START
