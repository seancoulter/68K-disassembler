*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Sean Coulter, Corin Ennis, Antony Mbugua
* Date       : Winter 2017
* Description: A disassembler for the EASy68K Assembler
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A

START   ORG     $1000   ; first instruction of program

* Output
LOOP    LEA     MSG,A1  ; comment
        MOVE.B  #14,D0  ; comment
        TRAP    #15     ; comment

* Input
        MOVE.B  #4,D0   ; comment
        TRAP    #15     ; comment
        CMP.L   #0,D1   ; compares D1 to the number 0
        BEQ     DONE    ; branch to DONE if D1 == 0

        BRA     LOOP    ; branch to LOOP

DONE    MOVE.B  #9,D0
        SIMHALT         ; halt simulator could use TRAP #15

* Put variables and constants here
MSG     DC.B    'Enter the starting memory address, (0 to exit): ',0
        END     START   ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
