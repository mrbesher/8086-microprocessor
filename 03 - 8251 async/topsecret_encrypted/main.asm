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
SERIALDATA  DB 200 DUP (?)
KEY DB 3 DUP (?)
; 8251 REGISTER ADDRESSES
CNTRL1 EQU 105H
DREG1 EQU 101H
CNTRL2 EQU 104H
DREG2 EQU 100H
DATA    ENDS
START PROC FAR
        MOV AX, DATA
        MOV DS, AX
        
        ; initialize 8251_1
        MOV DX, CNTRL1
        CALL INIT_8251
        
        ; initialize 8251_2
        MOV DX, CNTRL2
        CALL INIT_8251
        
        ; wait for 'S' from user
        MOV DX, DREG1
NOT_S:
        CALL GET_CHAR
        CMP AL, 'S'
        JNE NOT_S
        
        
        ; wait for '?' from TOPSECRET
        MOV DX, DREG2
NOT_?:
        CALL GET_CHAR
        CMP AL, '?'
        JNE NOT_?
        
        ; get key from user
        CALL GET_KEY
        
        XOR SI, SI
        
        MOV DX, DREG2
MSG_HEADER:
        CALL GET_CHAR
        CMP AL, 'E'
        JE PRINT_DATA
        SUB AL, '0' ; 'N'-'0'=N
        XOR AH, AH
        MOV CX, AX
MSG_BODY:
        CALL DELAY
        CALL GET_CHAR
        MOV SERIALDATA[SI], AL ; save data char
        INC SI
        LOOP MSG_BODY
        JMP MSG_HEADER
        
        
PRINT_DATA:
        CALL P_SERIAL_DATA
        
ENDLESS:
        JMP ENDLESS
RETF
START ENDP

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

P_SERIAL_DATA PROC NEAR
        ; input: SI (size of serialdata array)
        MOV CX, SI
        MOV DX, DREG1
        XOR SI, SI
PRINT_NCHAR:
        MOV AL, SERIALDATA[SI]
        INC SI
        CALL SEND_CHAR
        LOOP PRINT_NCHAR
        RET
P_SERIAL_DATA ENDP        
        

GET_KEY PROC NEAR
        PUSH SI
        MOV DX, DREG1
        MOV CX, 3
        XOR SI, SI
NCHAR_KEY:
        CALL GET_CHAR
        MOV KEY[SI], AL
        INC SI
        LOOP NCHAR_KEY
        POP SI
        RET
GET_KEY ENDP


GET_CHAR PROC NEAR
        ; input: DX (the address of datareg)
        ; returns a char using AL
        MOV BX, DX
        ADD BX, 4 ; control reg is `data reg + 4`
        CALL RXRDY
        IN AL, DX
        SHR AL, 1 ; proteus error
        RET
GET_CHAR ENDP

SEND_CHAR PROC NEAR
        ; input: DX (the address of datareg), AL (char to print)
        ; returns a char using AL
        MOV BX, DX
        ADD BX, 4 ; control reg is `data reg + 4`
        CALL TXRDY
        OUT DX, AL
        RET
SEND_CHAR ENDP


RXRDY PROC NEAR
        ; input: BX (the address of control reg)
        PUSH DX
        MOV DX, BX
NRRDY:        
        IN AL, DX
        TEST AL, 10B
        JZ NRRDY
        POP DX
        RET
RXRDY ENDP

TXRDY PROC NEAR
        ; input: BX (the address of control reg)
        PUSH DX
        PUSH AX
        MOV DX, BX
NTRDY:        
        IN AL, DX
        TEST AL, 1B
        JZ NTRDY
        POP AX
        POP DX
        RET
TXRDY ENDP


DELAY PROC NEAR
        PUSH CX
        MOV CX, 1FH
__DELAY_LABEL:
        LOOP __DELAY_LABEL
        POP CX
        RET
DELAY ENDP

CODE    ENDS
        END START