*-----------------------------------------------------------
* Program Number: 2.0
* Written by    : Anthony Barranco
* Date Created  : 12/2/12
* Description   : Pellet Eater (Snake) WITH SOUNDS
*
*-----------------------------------------------------------


*-----------------------------------------------------------
* Two methods of playing sound:
* Standard player uses task 71 to load, task 72 to play, and task 76 to control.
* DirectX player uses task 74 to load , task 75 to play, and task 77 to control.
* DirectX player was added to Easy68k in 2009 v4.7.0
*
* Differece is that the DirectX player allows !MULTIPLE! sound files to be played at !ONCE!
* Whereas the standard player does not and needs additional code, which can break things easily
*
* In this program I have added 6 sounds.
* A movement, direction change, pellet eat, lose wall, lose self, and the optional theme sounds.
* All sounds except the two lose sounds use the DX player to ensure seperate control states.
*-----------------------------------------------------------



START	ORG	$1000

	move.l	#$0000FF00,d1	Make the pen green
	move.b	#80,d0
	trap	#15
	move.l	#10,d1	Set pen width to 10
	move.b	#93,d0
	trap	#15

*Loading Sound into memory
	lea	 move,a1	load the "move" wav for character
	move 	#0,d1		sound will be #0
	move 	#74,d0		trap number 74 to load the wav file in DX
	trap	#15
	lea 	change,a1	load the "change" wav for changing direction
	move 	#1,d1		sound will be #1
	move 	#74,d0		trap number 74 to load the wav file in DX
	trap	#15
	lea 	eat,a1		load the "eat" wav for eating pellets
	move 	#2,d1		sound will be #2
	move 	#74,d0		trap number 74 to load the wav file in DX
	trap	#15
	lea 	loseyou,a1	load the "loseyou" wav for when you collide w/ yourself
	move 	#3,d1		sound will be #3
	move 	#71,d0		trap number 71 to load the wav file in Regular Player
	trap	#15
	lea 	losew,a1	load the "losew" wav for when you collide w/ wall
	move 	#4,d1		sound will be #4
	move 	#71,d0		trap number 71 to load the wav file
	trap	#15
	lea 	theme,a1	load the "theme" wav for bg music
	move 	#5,d1		sound will be #5
	move 	#74,d0		trap number 74 to load the wav file in DX
	trap	#15
	
*Start the theme and loop it
	move	#5,d1		use theme music
	bsr	play_soundDX	use DirectX player to play music
	move	#1,d2		make music loop
	move	#77,d0		trap number to control the DirectX player
	trap	#15

*Draw green border around the edge of the screen
	move.w	#0,d1	Draw a line from 0,0 to 0,480 (top to bottom of screen)
	move.w	#0,d2
	move.w	#0,d3
	move.w	#480,d4
	move.b	#84,d0
	trap	#15
	move.w	#640,d1	Draw a line from wherever the pen is to 640,480 (bottom right)
	move.w	#480,d2
	move.b	#85,d0
	trap	#15
	move.w	#640,d1	Draw a line to 640,0 (top right)
	move.w	#0,d2
	move.b	#85,d0
	trap	#15
	move.w	#0,d1	Draw a line back to 0,0 (top left)
	move.w	#0,d2
	move.b	#85,d0
	trap	#15

*Make the blue background
	move.l	#$00FF0000,d1	Make the fill color blue
	move.b	#81,d0
	trap	#15
	move.l	#15,d1	Move to a point inside the border
	move.w	#15,d2
	move.b	#89,d0	Fill in with fill color
	trap	#15

*Set the pen color to red and the fill color to yellow (for the snake) and put the pen back to 1 pixel
	move.l	#$000000FF,d1
	move.b	#80,d0
	trap	#15
	move.l	#$0000FFFF,d1
	move.b	#81,d0
	trap	#15
	move.w	#1,d1
	move.b	#93,d0
	trap	#15

*Loop to fill the snake memory with offscreen co-ordinates
	clr.b	d0
	move.b	#40,d0
	lea	midSquares,a0
fill
	move.w	#700,(a0)+
	sub.b	#1,d0
	bne	fill
	move.b	#4,size	Set the snake size (to 2)

*Put the first square of the snake into memory
	lea	curSquare,a0
	move.w	#5,(a0)+
	move.w	#5,(a0)
	lea	curSquare,a0	Reload the starting point into memory
	bsr	draw_square	Subroutine to draw a square at given co-ordinates

*Load the starting point into the beginning of the middle squares
	lea	midSquares,a0
	move.w	#5,(a0)+
	move.w	#5,(a0)

*Find the first pellet
	bsr	find_pellet

*Set the snake moving
	move.w	#0,d6
	move.w	#10,d7


*Set the number of game loops that have passed
	move.w	#0,numLoops

*Set the beginning game speed
	move.l	#15,speed

*Turn keyboard echo off
	move.b	#0,d1
	move.b	#12,d0
	trap	#15
*Get the time and store it in d5, this is used to slow the game down some
	move.b	#8,d0
	trap	#15
	move.l	d1,d5

*Main game loop
LOOP
	move.b	#8,d0	Re-get the time
	trap	#15
	sub.l	d5,d1	Subtract the old time from this new time
	cmp.l	speed,d1	If less than <speed> hundredths of a second has passed
	blo	LOOP	Loop again until it has
	move.b	#8,d0	Now that enough time has passed
	trap	#15
	move.l	d1,d5	Put the current time in memory for the next loop

	cmp.w	#910,numLoops	If the game isn't speeding up anymore
	bhi	skip	skip the following code
	add.w	#1,numLoops	Increment the number of game loops passed since the last speed change
	move.l	speed,d4
	mulu	numLoops,d4	Find out how much time has passed since the last speed change
	cmp.l	#900,d4	If about 900 hundredths of a second hasn't passed
	blo	skip	skip the speed increase code
	sub.l	#1,speed	Increase the speed
	move.w	#0,numLoops	Reset the number of loops

skip
*Copy the last position into memory so that it can be erased later
	lea	oldSquare,a0
	lea	midSquares,a1
	clr.l	d4
	move.b	size,d4
	sub.b	#4,d4
	adda.l	d4,a1
	move.w	(a1)+,(a0)+
	move.w	(a1),(a0)

*Load the middle squares into memory
	lea	midSquares,a0
	lea	midSquares,a1
	adda.l	#80,a0
	adda.l	#76,a1
	clr.l	d4
	move.b	#38,d4

*Move the squares back one
copy
	move.w	-(a1),-(a0)
	sub.b	#1,d4
	bne	copy

*Load the current front of the snake into the memory for the middle squares, because the front will change soon
	lea	midSquares,a0
	lea	curSquare,a1
	move.w	(a1)+,(a0)+
	move.w	(a1),(a0)

*Check to see if a key has been pressed
	clr.l	d1
	move.b	#7,d0
	trap	#15
	tst.l	d1
	beq	continue	If a key wasn't pressed, continue moving the snake

*Read the key that was pressed and find out which key it was
	move.b	#5,d0
	trap	#15
	cmp.b	#$35,d1	Key pressed: 5 (down)
	beq	move_down
	cmp.b	#$38,d1	Key pressed: 8 (up)
	beq	move_up
	cmp.b	#$34,d1	Key pressed: 4 (left)
	beq	move_left
	cmp.b	#$36,d1	Key pressed: 6 (right)
	beq	move_right
	
*The part of the main loop that moves the snake
continue
	lea	curSquare,a0	Load the current position
	add.w	d6,(a0)+	Modify the current position by whats in the movement memory
	add.w	d7,(a0)	this will give the co-ordinates of the new square
	move	#0,d1	load movement sound file
	bsr 	play_soundDX	play sound using DirectX player
	

*curSquare and curSquare+2 should never be < 5
*curSquare+4 should never be > 635
*curSquare+6 should never be > 475
*If they are, then a wall was hit
	lea	curSquare,a0	Reload the starting address of the current position
	cmp.w	#5,(a0)
	blt	WALL
	cmp.w	#625,(a0)+
	bhi	WALL
	cmp.w	#5,(a0)
	blt	WALL
	cmp	#465,(a0)
	bhi	WALL

*Check to see if you hit yourself
	clr.l	d4
	move.b	size,d4
hit
	cmp	#0,d4	If we have already checked all the parts of the snake
	ble	skip2	continue with the game loop
	sub.l	#4,d4
	lea	midSquares,a1	Load the beginning of the middle squares
	lea	curSquare,a0	Load the starting address of the current position
	adda.l	d4,a1	Start checking at the end of the snake and move up from there
	cmp.w	(a1)+,(a0)+	If the x co-ordinates don't match
	bne	hit	move on to the next square
	cmp.w	(a1)+,(a0)+	If the y co-ordinates don't match
	bne	hit	move on to the next square
	bra	SELF	Otherwise, they both match. That means you hit yourself

skip2
*Check to see if a pellet was eaten
	lea	curSquare,a0	Load the address of the current position
	lea	pellet,a1	Load the address of the pellet position
	cmp.w	(a0)+,(a1)+	If the x co-ordinates don't match
	bne	skip3	continue with the game loop
	cmp.w	(a0)+,(a1)+	If the y co-ordinates don't match
	bne	skip3	continue with the game loop
	bsr	find_pellet	Otherwise a pellet was eaten, so find a draw a new one
	move	#2,d1	load eat sound file
	bsr	play_soundDX	play sound file using DirectX player
	cmp.b	#79,size	If the snake is at it's largest
	bhi	skip3	don't make it larger, continue with the game loop
	add.b	#4,size	Otherwise, make the snake another square longer

skip3
	move.l	#$000000FF,d1	Make the pen red and the fill yellow to draw the snake
	move.b	#80,d0
	trap	#15
	move.l	#$0000FFFF,d1
	move.b	#81,d0
	trap	#15

	lea	curSquare,a0	Reload the starting address of the current position
	bsr	draw_square	Draw the new front of the snake

	move.l	#$00FF0000,d1	Make the pen and fill blue to erase part of the snake
	move.b	#80,d0
	trap	#15
	move.l	#$00FF0000,d1
	move.b	#81,d0
	trap	#15
	lea	oldSquare,a0	Load the part of the snake to be erased
	bsr	draw_square	Draw a blue square over it to erase it

	bra	LOOP	Start the main game loop over again

WALL
*stop theme music
	move	#3,d2  stop all DirectX music being played
	move	#77,d0	trap number to control DirectX player
	trap	#15

*Change the fill color to black
	move.l	#$00000000,d1
	move.b	#81,d0
	trap	#15

*Move the cursor to the middle of the screen
	clr.l	d1
	move.w	#$1E0F,d1
	move.b	#11,d0
	trap	#15

*play the lose sound
	move	#4,d1	select the losew sound
	bsr	play_sound	play sound using regular player
	
*Display the hit wall message and end the program
	move.b	#14,d0
	lea	wallMsg,a1
	trap	#15
	bra	DONE

SELF

*stop theme music
	move	#3,d2	stop all DirectX music being played	
	move	#77,d0	trap number to control DirectX player
	trap	#15
	
*play lose sound
	move	#3,d1	select the losew sound
	bsr	play_sound	play sound using regular player
	
*Change the fill color to black
	move.l	#$00000000,d1
	move.b	#81,d0
	trap	#15

*Move the cursor to the middle of the screen
	clr.l	d1
	move.w	#$1E0F,d1
	move.b	#11,d0
	trap	#15

*Display the hit self message and end the program
	move.b	#14,d0
	lea	selfMsg,a1
	trap	#15
	bra	DONE

DONE
	STOP	#$2000

*If the down key(5) was pressed modify the movement memory
move_down
	move.w	#0,d6	These numbers will be added to the front of the snake
	move.w	#10,d7	to figure out where the next square should be
	move	#1,d1	select the change sound file
	bsr	play_soundDX	play the sound using DirectX player
	bra	continue

*If the up key(8) was pressed
move_up
	move.w	#0,d6
	move.w	#-10,d7
	move	#1,d1	select the change sound file
	bsr	play_soundDX	play the sound using DirectX player
	bra	continue

*If the left key(4) was pressed
move_left
	move.w	#-10,d6
	move.w	#0,d7
	move	#1,d1	select the change sound file
	bsr	play_soundDX	play the sound using DirectX player
	bra	continue

*If the right key(6) was pressed
move_right
	move.w	#10,d6
	move.w	#0,d7
	move	#1,d1	select the change sound file
	bsr	play_soundDX	play the sound using DirectX player
	bra	continue

*Draw a square at the co-ordinates in a0
draw_square
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	move.w	(a0)+,d1
	move.w	(a0),d2
	move.w	d1,d3
	add.w	#10,d3
	move.w	d2,d4
	add.w	#10,d4
	move.b	#87,d0
	trap	#15
	rts

find_pellet
	clr.l	d1
	clr.l	d2
	clr.l	d3
	move.b	#8,d0	Put the time in d1
	trap	#15
	and.l	#$FFFF,d1	Clear out the upper word
	divu	#62,d1	Divide by 62 to get x1 (almost)
	swap	d1
	move.w	d1,d2
	mulu	#10,d2	Multiply x1 by 10
	add.w	#5,d2	Add 5, now the x1 co-ordinate is done
	move.b	#8,d0	Put the time in d1 again
	trap	#15
	and.l	#$FFFF,d1	Clear out the upper word
	divu	#46,d1	Divide by 46 to get y1 (almost)
	swap	d1
	move.w	d1,d3
	mulu	#10,d3	Multiply y1 by 10
	add.w	#5,d3	Add 5, now the y1 co-ordinate is done
	lea	pellet,a2	Move x1 and y1 into the memory for the pellet
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.l	#$00FFFF80,d1	Make the pen and fill grey to draw the pellet
	move.b	#80,d0
	trap	#15
	move.l	#$00FFFF80,d1
	move.b	#81,d0
	trap	#15
	lea	pellet,a0	Load the pellet
	bsr	draw_square	Subroutine to draw a square at given co-ordinates
	rts
	
play_sound
	move	#72,d0	trap number to use standard player
	trap	#15
	rts
	
play_soundDX
	move	#75,d0	trap number to use DX player
	trap	#15
	rts

*Memory to hold the front of the snake, the part to be erased and the rest of the snake
curSquare	ds.w	2
oldSquare	ds.w	2
midSquares	ds.w	40

*Memory to hold the location of the pellet
pellet	ds.w	2

*Size of the snake, Number of loops since the last speed increase, Speed each loop will be
size	ds.b	1
numLoops	ds.w	1
speed	ds.l	1

wallMsg
	dc.b	'You',$60,'ve Hit A Wall!',0
selfMsg
	dc.b	'You',$60,'ve Hit Yourself!',0
	
*The sound files to load into memory
move	dc.b	'move.wav',0
change	dc.b	'change.wav',0
eat	dc.b	'eat.wav',0
loseyou	dc.b	'loseyou.wav',0
losew	dc.b	'losew.wav',0
theme	dc.b	'theme.wav',0

	END	START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
