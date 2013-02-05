*-----------------------------------------------------------
* Program    : ECHO	
* Written by : Anthony Barranco
* Date       : 9/24/12
* Description: Takes user input, outputs it, and length
*-----------------------------------------------------------
	
START:	ORG	$1000			; first instruction of program

	*-----Ask for the number input-----
	LEA MESSAGE,A1 		;Loads MESSAGE into
	Move.B  #14,D0		;Moves the number 14 into data register D0
	TRAP	#15
	
	
	*------INPUT-----
	LEA 	BUFFER, A1	;Take input into BUFFER
	Move.B  #2,D0
	TRAP	#15
	
	MOVE.L A1, D5
	MOVE.W D1, D4
	
	*-----Repeat message-----
	LEA MESSAGEIN,A1 	;Loads MESSAGE into
	Move.B  #14,D0		;Moves the number 14 into data register D0
	TRAP	#15
	
	CLR D1
	MOVE.L D5, A1
	MOVE.W D4, D1
	
	*-----OUTPUT BUFFER-----
	MOVE.B  #14, D0
	TRAP	#15
	
	*-----OUTPUT LENGTH---
	LEA 	TOTAL, A1 ;Display TOTAL for information
	TRAP	#15
	Move.B #10, D2  ;Setting the base
	Move.B #15, D0
	TRAP #15
	
	*----TERMINATE---
	MOVE.B	#9,D0
	TRAP	#15

* Variables and Strings
CR	EQU	$0D	ASCII Code for Carriage Return
LF	EQU	$0A	ASCII code for Line Feed
MESSAGE DC.B	'Enter a string: ',0  Please ASCII string in memory at MESSAGE
MESSAGEIN DC.B	'Your input was: ',CR, LF, 0  Please ASCII string in memory at MESSAGE
TOTAL	DC.B	CR,LF,'Total number of characters: ',0
BUFFER	DS.B	80

	END	START		; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
