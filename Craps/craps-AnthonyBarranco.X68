*-----------------------------------------------------------
* Program    : Craps base code
* Written by : Anthony Barranco
* Date       : 14-Oct-2012
* Description:
* Implements the base to initialize the pit and shoot dice
*              
*-----------------------------------------------------------
	ORG	$1000
start:			
*------- 1. SET PITNO MANUALLY OR PROGRAMMATICALLY ---------
* If manually, scroll down and put a number between 0 & n
* where n is the number of pits. In this base code, n is 6.
* If programmatically, get input from the user with task #4,
* and do the following:
*
*                       lea pitno, a1
*                       move d1, (a1)
*
* Then you've set the pit number randomly.
*-----------------------------------------------------------

* This next statement MUST be invoked PRIOR to using invokig shoot.
*  needs to be invoked just ONCE. DO NOT INVOKE multiple times,
* although it wouldn't hurt to do so, it is unecessary to do so.
*	bsr	diceInit

*-----------------------------------------------------------
* Uncomment is next statement ONLY to test the dice. Otherwise leave
* it commented.
;	bsr	diceTest
*-----------------------------------------------------------

*---------- 2. PUT YOUR CODE HERE TO PLAY CRAPS ------------
* The game upon start will print welcome, set the bank to $100 to start, ask for a pit number,
* enter a bet amount, and then the game will ask to either shoot or quit.
*
* From here, the player will either lose (crapout), win (natural), or enter the point stage.
*
* If point stage, the dice total becomes the point number and the player will continue to roll
* unless either the point number is made from dice total again (win) or the player rolls a 7 (lose).
*
* A win or loss at any time will result in the game repeating itself.
* The game will end if the bank hits $0, or the player inputs q to quit the game.
*
* Key memory registers I have used:
*	D3 = die one (after shoot, set by displayDice)
*	D4 = die two (after shoot, set by displayDice)
*	D5 = player bank
*	D6 = player bet
*	A7 = stack will have point total (set by pointstart)
*------------------------------------------------------------

	lea 	welcome,a1	;print the Welcome to Las Vegas Message
	move.b	#14,d0
	trap 	#15
	cmp	#0,d5		;if d5 (bank) is 0, then first time playing
	beq	firstplay	;if first time playing, go set bank to $100
	
*----Begin playing craps, program loops back here until bank is 0 or q is entered
craps:
	bsr 	pitset		;ask player to set the pit number
	bsr	diceInit	;initiate the dice AFTER the pit number is set
	
	bsr	bank		;display bank
	
	bsr	bet		;ask player for a bet
	bsr	response	;ask player to either shoot or quit, then proceeds to shoot
	
	bsr	displayDice	;displays both dice to the player
	move 	d1,d2		;move second dice # to d2
	swap 	d1		;swap hi and lo dice memory
	add  	d1,d2		;add the first dice # to second dice # in d2
	
	
	*---Win by 7 or 11
	cmp 	#7,d2		;if dice is 7, then win
	beq	win
	cmp 	#11,d2		;if dice is 11, also win
	beq	win
	
	*---Lose by crapout
	cmp	#2,d2		;lose if crap out
	beq	crapout
	cmp	#3,d2
	beq	crapout
	cmp	#12,d2
	beq	crapout
	
	*---Point stage
	bsr	pointstart	;if not win or lose, establish point and start point phase
	
*---Branch here to GameOver
end:
	bsr	bank		;print bank statement, should be 0
	lea	gameover,a1	;print Game Over
	move.b	#14,d0
	trap	#15
	move.b	#9,d0		;Halt the simulator
	trap	#15
	
*---Branch here to set the pit number
pitSet:
	lea	pitm,a1		;print ask for pit number
	move.b	#14,d0
	trap	#15
	move.l	#0,d1		;clearing d1
	move.b	#4,d0		;ask user for number
	trap	#15
	cmp	#6,d1		;make sure number is NOT greater than 6
	bhi	pitset		;if greater than 6, then repeat
	move.w	d1, pitno	;setting pit number
	rts
	
*---Gives player $100 bank to start with, only occurs if first execution of program
firstPlay:
	move.l	#100,d5		;Gives player a starting account of $100
	bra	craps
	
*---Display the player's bank amount
bank:
	lea	bankm,a1	;print bank message
	move.b	#14,d0
	trap	#15
	move.l	d5,d1		;moving bank from d5 to d1 to print
	move.b	#3,d0		;print bank number
	trap	#15
	rts
	
*---Branch here to ask user for a bet
bet:
	clr	d1		;clear d1 just incase
	lea	betm,a1		;ask player for a bet
	move.b	#14,d0
	trap	#15
	move.b	#4,d0		;number input
	trap	#15
	cmp	d5,d1		;compare bet to bank account
	bgt	bethigh		;make sure player doesnt bet too high
	move	d1,d6		;bet located in d6 if not too high
	rts
	
*---If bet is too high, continue to ask for bet
betHigh:
	lea	bet2high,a1 	;inform player bet too high
	move.b	#14,d0
	trap	#15
	bra	bet		;return to bet
	
*---Branch here to ask player to either shoot the dice or quit the game
response:
	lea	signIn,a1	;ask player to either enter to shoot or q to quit
	move.b	#14,d0
	trap	#15
	move.b	#5,d0		;have player enter a single ASCII char
	trap	#15
	cmp	#113,d1		;if q, then quit and GameOver
	beq	end
	cmp	#13,d1		;if enter (or CR), then shoot
	beq	shoot
	bne 	response	;if neither, then repeat
	
*---Branch here to print the outcome of shoot
displayDice:
	*---Remember dice numbers are reversed, not critical but helps to know
	move.l	d1,-(a7)	;push to stack to save
	move	d1,d4		;move second dice # to d2
	swap	d1		;swap the hi and lo dice
	move	d1,d3		;move first die # to d3
	move.l 	d4,d1		;move second die # to d1 to print
	lea	die1,a1		;print die message
	move	#14,d0
	trap	#15
	move 	#3,d0		;print the second die
	trap 	#15
	move.l 	d3,d1		;move first die # to d1 to print
	lea	die2,a1		;print the die 2 message
	move	#14,d0
	trap	#15
	move	#3,d0		;print the first die #
	trap 	#15
	move.l	(a7)+,d1	;pop to d1 to restore original dice numbers
	rts
	
*---If crapout occurs, branch here
crapout:
	lea	crapoutm,a1	;print crapout message
	move	#14,d0
	trap	#15
	move.l	d4,d1		;moving the first die to d1
	add	d3,d1		;adding the second die to the first die, into d1
	move	#3,d0
	trap 	#15		;print the dice total number
	bra	lose		;always continue to lose
	
*---Branch here to start the point stage, sets the point and continues to point stage
pointStart:
	lea	pointm,a1	;print the point message
	move	#14,d0
	trap	#15
	move.l	d4,d1		;moving the second dice # to d1 to print
	add	d3,d1		;adding d3 to d1 to make point
	move	d1,-(a7)	;pushing point to stack so I dont lose it
	move	#3,d0		;printing point total
	trap	#15
	bra point		;always continue to point stage
	
*---This is the point stage, will loop over until either 7 or point is achieved
point:
	bsr	response	;shoot or quit
	bsr	displayDice	;display new dice roll if shoot
	move 	d1,d2		;move new second die # to d2
	swap 	d1		;swap hi and lo new dice memory
	add  	d1,d2		;add the first new die # to second new die # in d2
	move.l	(a7),d1		;replace old die point count
	swap	d1
	cmp	d1,d2		;if point equals the new total dice, then win
	beq	pointwin
	cmp	#7,d2		;if new point is 7, then lose
	beq	crapout
	bra	point		;otherwise, do it again!
	
*---If point is achieved, branch here to win
pointWin:
	lea	pointwinm,a1	;print point win message
	move	#14,d0
	trap	#15
	move.l	(a7),d1		;move the point total off the stack, ie:6000000 is point total of 6
	swap	d1		;swapping around so it makes sense, ie:000006 is the real point total of 6
	move	#3,d0		;print the point total
	trap	#15
	bra	win		;always continue to win
	
*---If any winning condition achieved, branch here
win:
	lea	winm,a1		;print win message
	move.B	#14,d0
	trap	#15
	add	d6,d5		;reward player with bet amount
	move.l	d6,d1		;move bet amount to d1 so that it prints
	move	#3,d0
	trap	#15		;print bet amount: you won x amount
	bra	craps		;always continue the game, it will loop until bank is 0 or q is entered
	
*---If any losing condition achieved, branch here. Game Over if bank is $0!!!
lose:
	lea	losem,a1	;print lose message
	move.b	#14,d0
	trap	#15
	sub	d6,d5		;remove bet from player bank
	move.l	d6,d1		;move bet amount to d1 so that it prints
	move	#3,d0
	trap	#15		;print bet amount: you lose x amount
	cmp	#0,d5		;make sure bank is not 0, if no, then Game Over!
	beq	end
	bra	craps		;always continue the game, it will loop until bank is 0 or q is entered

* Returns dice in upper and lower words of d1.
* NOTE: Returns d1 = 0, when there are not more throws in the sequece
shoot:
	movem.l	d2/a1-a2,-(a7)
	lea	pitptr, a1
	move.l	(a1), a2
	move.w	(a2)+, d1
	swap	d1
	move.w	(a2)+, d1
	move.l	a2, (a1)
	movem.l	(a7)+,d2/a1-a2
	rts
	
* Initializes the dice based on the pit number
diceInit:
	movem.l	d0/a1-a2, -(a7)	;Save the registers we'll use
	lea	pitno, a1	;Get the pit number into d0
	move	(a1), d0	
	
	cmp	#0, d0		;If pitno zero, intialize random dice
	beq	rand_
	
	sub	#1, d0		;Else use d0 as offset into pit table
	
	lea	pittab, a1
	mulu	#4, d0		;Convert pit number into to 32-bit offset
	add	d0, a1		;Compute <ea> of pit table
	move.l	(a1), a1	;get actual pit address into a1
	
	lea	pitptr, a2	;Store pit address into pit pointer variable
	move.l	a1, (a2)
done:
	movem.l	(a7)+, d0/a1-a2
	rts

* Uses TOD as index into random sequence
rand_:
	move.b	#8,d0		;Get into d1 time in 100s seconds since midnight
	trap	#15
	and.l	#$5FFFFF,d1
	divu	#100, d1
	swap	d1
	and.l	#$FFFF, d1	;Clear the upper words of d1
	mulu	#2, d1		;Convert d1 to word-offset	
	lea	pit00, a1	;Compute <ea> into pit00
	add	d1, a1	
	lea	pitptr, a2	;Store <ea> into pit pointer variable
	move.l	a1, (a2)
	bra	done		

diceTest:	
	move	#100, d5
loop_:
	bsr	shoot
	sub	#1, d5
	dbeq	d5, loop_
	rts
	
* Pit number: modify this to 0 - 6
* 0: random throws
* >0: test cases with known behaviors (see below)
pitno	dc.w	0

* Pit pointer variable DO NOT MODIFY
pitptr	dc.l	0
	
* Pit table DO NOT MODIFY unless additing more pits
pittab	dc.l	pit01, pit02, pit03, pit04, pit05, pit06

* s on first throw (7) DO NOT MODIFY
pit01	dc.w	3, 4
	dc.w	0, 0

* Wins on first throw (11) DO NOT MODIFY
pit02	dc.w	6, 5
	dc.w	0, 0

* Craps out on 1st throw (2) DO NOT MODIFY
pit03	dc.w	1, 1	;snake eyes!
	dc.w	0, 0

* Craps out on 1st throw (12) DO NOT MODIFY
pit04	dc.w	6, 6
	dc.w	0, 0
	
* Establishes point 9 and craps out on 3rd throw (7) DO NOT MODIFY
pit05	dc.w	4, 5	;establishes point of 9
	dc.w	2, 4
	dc.w	3, 4	;crap-out here with 7
	dc.w	0, 0

; Establishes point 5 and wins on 5th throw DO NOT MODIFY
pit06	dc.w	2, 3
	dc.w	5, 4
	dc.w	5, 5
	dc.w	6, 5
	dc.w	1, 4
	dc.w	0, 0

* Random throws table DO NOT MODIFY
pit00	dc.w 	6,2,6,1,3,1,4,2,6,4,3,2,3,1,6,5,4,4,1,5,3,5,6,6,4,3,5,5,1,1,5,2,5,5,4,5,4,6,1,6,5,4,3,3,2,5,2,2,1,1
	dc.w 	3,6,1,3,2,1,3,5,6,5,2,3,4,2,3,3,1,5,5,4,3,6,2,3,1,6,1,4,4,6,1,3,6,1,4,2,4,2,2,2,3,3,5,6,2,4,2,2,5,6
	dc.w 	4,5,3,3,2,2,6,4,2,2,6,4,6,3,2,1,6,2,3,3,4,3,4,4,5,4,4,1,6,3,3,1,3,2,1,2,1,4,6,3,6,4,2,5,2,5,1,1,4,5
	dc.w 	4,3,6,4,4,6,4,6,4,1,6,3,3,5,6,3,2,1,6,5,5,5,3,2,6,4,5,5,3,3,6,5,1,3,3,2,3,5,6,2,4,4,2,1,4,3,6,5,3,4
	dc.w 	4,3,3,2,5,1,5,5,2,4,6,5,4,4,1,3,3,4,1,4,1,6,6,1,4,5,2,4,5,6,1,2,2,3,2,1,4,1,3,2,1,5,1,1,6,6,1,5,3,3
	dc.w 	1,6,6,4,2,1,3,3,2,5,3,1,1,6,2,1,2,3,3,4,5,2,4,1,2,6,2,5,4,4,2,4,3,5,1,6,3,6,2,2,3,4,3,2,5,4,4,4,2,4
	dc.w 	5,6,4,2,6,6,5,5,1,1,5,3,2,6,4,1,2,2,3,1,1,1,5,4,3,2,2,3,2,6,2,1,5,3,3,3,6,3,2,6,6,6,3,6,2,6,1,6,2,6
	dc.w 	3,1,5,1,2,2,6,5,3,6,5,6,6,4,1,3,5,1,1,1,3,5,6,6,3,3,4,1,5,3,1,2,2,6,1,3,5,1,2,1,5,5,1,6,1,5,6,6,2,2
	dc.w 	1,1,6,6,5,4,3,5,1,4,3,5,5,6,3,1,4,5,4,2,3,2,1,2,2,5,2,1,1,2,3,5,5,1,6,2,3,6,2,5,6,6,1,4,6,4,5,2,3,1
	dc.w 	3,4,2,1,2,4,5,1,3,6,4,3,5,6,4,6,5,4,4,5,3,6,5,4,2,6,1,6,2,1,6,6,2,6,4,2,2,6,3,4,1,3,3,2,2,4,2,2,5,6
	dc.w 	1,3,2,4,6,4,2,2,2,6,5,4,4,3,3,1,2,2,6,6,1,1,4,2,4,4,5,6,4,6,5,3,5,5,2,3,1,5,5,5,1,4,3,3,1,5,2,6,5,5
	dc.w 	5,1,1,1,6,1,1,5,4,2,5,1,4,5,3,1,3,4,2,1,3,3,5,1,2,2,6,6,1,3,2,4,1,6,6,3,2,1,3,4,2,5,6,4,6,6,3,2,2,2
	dc.w 	1,3,3,6,2,1,1,2,6,1,5,3,6,1,2,1,5,6,4,3,3,3,5,5,3,2,4,5,3,1,1,1,2,5,1,2,5,1,2,4,1,5,4,4,5,2,5,6,4,6
	dc.w 	5,5,3,3,1,3,6,1,4,4,1,6,2,1,3,4,2,6,6,6,2,4,2,3,6,6,1,5,2,6,2,3,2,1,1,4,1,2,2,3,5,2,6,3,6,6,2,5,5,1
	dc.w 	3,4,5,4,4,1,2,2,1,4,2,2,2,4,1,2,1,5,3,6,5,1,1,5,4,2,5,2,6,1,5,3,2,4,6,4,2,3,3,4,1,3,4,2,5,4,4,4,1,6
	dc.w 	6,3,3,1,5,3,5,3,1,1,3,5,1,2,5,5,6,6,6,2,3,1,6,4,2,3,3,6,6,4,2,1,4,4,4,1,2,5,4,2,5,6,3,6,5,1,5,5,1,6
	dc.w 	1,6,5,2,4,1,1,5,3,2,1,2,6,6,5,6,4,6,2,6,3,5,6,6,5,1,2,5,3,4,2,1,2,1,1,5,1,2,4,2,5,5,5,4,1,3,3,3,3,4
	dc.w 	3,2,4,5,6,4,4,5,2,4,3,4,2,4,3,1,6,4,4,2,4,2,6,3,2,1,6,4,3,4,1,4,3,1,6,1,5,5,6,5,3,6,1,1,2,3,5,4,2,5
	dc.w 	1,2,2,1,5,1,4,3,6,5,1,3,3,1,2,6,3,5,4,4,4,4,5,5,1,3,5,4,3,1,2,3,4,2,1,1,4,3,1,1,6,2,4,3,2,2,3,3,5,2
	dc.w 	5,4,1,1,3,2,3,6,1,1,3,2,1,4,5,3,2,5,1,6,6,2,6,1,3,1,1,1,2,2,1,2,6,5,2,1,3,2,6,1,5,6,2,5,1,1,2,1,3,2
	dc.w	0,0
	
	
CR	EQU	$0D	ASCII Code for Carriage Return
LF	EQU	$0A	ASCII code for Line Feed
welcome DC.B  	'Welcome to the world famous Paris Las Vegas on The Strip',CR,LF,0
bankm	DC.B  	CR,LF,'Your bankroll is currently $',0	;needs CR,LF before next print
pitm	DC.B	CR,LF,CR,LF,'Please enter a pit number 0 to 6:',CR,LF,0
betm	DC.B	CR,LF,'Please enter bet amount: ',0
bet2high DC.B	'Your bet was too high! Not enough funds.',0
bet0	DC.B	'You bet 0!',0
signIn	DC.B	CR,LF,'Press <enter> to shoot or q to quit.',CR,LF,0
die1	DC.B	'You threw: ',0	
die2	DC.B	' and ',0	;needs CR,LF before next print
crapoutm DC.B	CR,LF,'You crapped out with ',0
pointm	DC.B	CR,LF,'The point is ',0
pointwinm DC.B	CR,LF,'You made the point ',0
winm	DC.B	CR,LF,'You won $',0
losem	DC.B	CR,LF,'You lost $',0
gameover DC.B	CR,LF,'Game Over.',0

	end	start		; last line of source











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
