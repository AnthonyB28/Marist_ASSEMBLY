*-----------------------------------------------------------
* Program    : FACT	
* Written by : Anthony Barranco
* Date       : 10/1/12
* Description: Takes user input number, outputs factorial
*-----------------------------------------------------------
	
START:	ORG	$1000			; first instruction of program

	*-----Ask for the number input-----
	LEA MESSAGE,A1 		;Loads MESSAGE into
	Move.B  #14,D0		;Moves the number 14 into data register D0
	TRAP	#15
	
	*------INPUT-----
	Move.B  #4,D0
	TRAP	#15
	Move.B  #1,D7		 ;Putting 1 in D7 to start
	
	*----BSR--------
	BSR 	factorial	;n! = n * n-1
		
	*-----OUTPUT MESSAGE------
	LEA 	TOTAL, A1 	;Display TOTAL for information
	MOVE	#14,D0
	TRAP	#15
	
	*---OUTPUT FACTORIAL-----
	Move.L 	D7, D1		;Moving result into D1 to print
	Move.B 	#10, D2		;Setting base
	Move.B 	#15, D0
	TRAP #15
	
	*----TERMINATE---
	MOVE.B	#9,D0
	TRAP	#15

* Variables and Strings
CR	EQU	$0D	ASCII Code for Carriage Return
LF	EQU	$0A	ASCII code for Line Feed
MESSAGE DC.B	'Input number n for n! : ',0  Please ASCII string in memory at MESSAGE
TOTAL	DC.B	'n! =  ',0


*------SUBROUTINE------
factorial	MULU 	D1, D7
		SUB 	#1, D1
		BEQ	finish
		BSR 	factorial
		
finish		RTS

	END	START		; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
