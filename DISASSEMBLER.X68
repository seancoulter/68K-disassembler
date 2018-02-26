*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Sean Coulter, Corin Ennis, Antony Mbugua
* Date       : Winter 2018
* Description: A disassembler program for Motorola 68K source files
*-----------------------------------------------------------

              
              ***************************************
              * TODO for initial user input for start/end addresses:
              *   check if the starting address is odd
              *   check if first line of data S file contains 36384B50524F47202020323043524541544544204259204541535936384B6D (68kprog created by easy68k in ASCII) so its not x86 or something
              *   check if user- inputted end address is after program is loaded (ENDed) ?
              ****************************************
                     
            *D1: sentinel exit value
            *D2: index of MSB
            *D3: length of user input string
            *D4: index of pointer to string table
            *D6: ascii value holding MSB
            *D7: max valid input
            
            
CR         EQU   $0D
LF         EQU   $0A
stack_addr EQU   $7000
start_addr EQU   $1000

              
start         ORG     start_addr             
              MOVE.B  #$46,D7  *max valid input byte in ascii
              MOVE.B  #$30,D6
              
              *ascii string 4646464646464646 == hex FFFFFFFF
              *for each ascii character the user enters, if that character is outside [30,40) (40,46], its an invalid character
              
******************************************************************************************
*display starting information for user, capture start and end addresses, error check on addresses
    *A2: points to starting address
    *A3: points to ending address
    *A4: points to ascii/hex string table
    
    *D3: holds the next byte of the user starting address
    *D3: holds length of user input
    *D4: offset of string table value
    
              LEA     stack_addr, SP
              
disp_msg      LEA     display_start,A1  *load intro msg to A1
              MOVE.B  #14,D0            *indicate output
              TRAP    #15
              
              LEA     string_tbl,A4 *load A4 with the string table
              
              LEA     user_start,A1 *load user input variable address to A1
              MOVE.B  #2,D0         *indicate saving user input to loaded variable in A1
              TRAP    #15
              
              CMP.W   #exit_val,A1   *did the user want to quit?
              BEQ     done          * yes-quit
              
              CMP.L   #8,D1         *is the starting address 8 hex digits?
              BGT     err           * no-invalid
              
              MOVE.B  D1,D3         *store length of start address (task #2) in D3
              
              
              
*********************MAKE THIS A SUBROUTINE*************
get_next_byte MOVE.B (A1)+,D2      *move next byte of input address to D2
              CLR    D4            *reset index offset in string table
              SUBI.B #1,D3         *decrement the loop counter (length of user string)
              CMP.B  #-1,D3        *have we converted the whole address?
              BEQ    end_addr      * yes-get the end address
              BRA    char_convert
              
char_convert  CMP.B   (A4,D4.W),D2 *compare this byte with the next value in string table
              BEQ     save_byte      *we found the corresponding hex
              ADDI    #2,D4          *Next index of string table
              CMP.B   #31,D4         *check if we're outside the table (indicates invalid hex input)
              BGT     err
              BRA     char_convert

save_byte     MOVE.B  1(A4,D4.W),-1(A1)              
              BRA     get_next_byte
***********************************************************      
      
************* by this point, the starting address is valid and stored in A2.*-*********************
              
end_addr      MOVEA.L A1,A2            *move starting address to A2
              LEA     display_end,A1
              MOVE.B  #14,D0   ; comment
              TRAP    #15      ; comment
              
              LEA     user_end,A1
              MOVE.B  #2,D0    * trap user ending address   
              TRAP    #15
              
              CMP.W   #exit_val,A1   *did the user want to quit?
              BEQ     done          * yes-quit
              
              CMP.L   #8,D1         *is the starting address 8 hex digits?
              BGT     err           * no-invalid
              
              MOVE.B  D1,D3         *store length of start address (task #2) in D3

        
*********************MAKE THIS A SUBROUTINE*************
get_next_byte_e MOVE.B (A1)+,D2      *move next byte of input address to D2
              CLR    D4            *reset index offset in string table
              SUBI.B #1,D3         *decrement the loop counter (length of user string)
              CMP.B  #-1,D3        *have we converted the whole address?
              BEQ    data_parse      * yes-get the end address
              BRA    char_convert_e
              
char_convert_e  CMP.B   (A4,D4.W),D2 *compare this byte with the next value in string table
              BEQ     save_byte_e      *we found the corresponding hex
              ADDI    #2,D4          *Next index of string table
              CMP.B   #31,D4         *check if we're outside the table (indicates invalid hex input)
              BGT     err
              BRA     char_convert_e

save_byte_e     MOVE.B  1(A4,D4.W),-1(A1)              
              BRA     get_next_byte_e
***********************************************************      
            


data_parse   *sht gets real 









      
done          MOVE.B  #9,D0         *indicate end of simulation
              TRAP    #15
              
err           LEA     bad_addr,A1   *load the error msg into A1
              MOVE.B  #14,D0       *indicate output
              TRAP    #15
              LEA     nl,A1        *load new line into A1
              MOVE.B  #14,D0        *indicate output
              TRAP    #15
              CLR.L   D2            *reset msb index for further iterations
              BRA     disp_msg      *go back to welcome msg
              
              
data          ORG     $3000
        
*string table for converting user input addresses from ascii to hex      
string_tbl    DC.B    $30,$0      *{hex,ascii}
              DC.B    $31,$1          
              DC.B    $32,$2 
              DC.B    $33,$3
              DC.B    $34,$4
              DC.B    $35,$5
              DC.B    $36,$6
              DC.B    $37,$7
              DC.B    $38,$8
              DC.B    $39,$9            
              DC.B    $41,$A
              DC.B    $42,$B
              DC.B    $43,$C
              DC.B    $44,$D
              DC.B    $45,$E
              DC.B    $46,$F
                
*opcode_tbl   DC.B    $6,        *{opcode,destination EA}

size_tbl      DC.B    1,1        *byte
              DC.B    2,2        *word
              DC.B    3,4        *long
                
                
nl            DC.B    '',CR,LF,0
display_start DC.B    'Enter the starting 32-bit memory address in hex (-1 to quit): ',0
display_end   DC.B    'Enter ending 32-bit memory address in hex (-1 to quit): ',0
bad_addr      DC.B    'Please enter a valid address',CR,LF,0

exit_val      DC.W    $2D31  *sentinel exit value

user_start    DS.L    0
user_end      DS.L    0



              END     start







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
