*-----------------------------------------------------------
* Title      :
* Written by : Nillohit Manna
* Date       :
* Description:
*-----------------------------------------------------------

PEN_COLOR                   EQU   80
DRAW_PIXEL                  EQU   82
SET_RESOULTION              EQU   33
OUTPUT_WIDTH                EQU   640
OUTPUT_HEIGHT               EQU   480

CHUNK_WIDTH                 EQU   640
CHUNK_HEIGHT                EQU   480
CHUNK_STARTX                EQU   0
CHUNK_STARTY                EQU   0
     
BALL_WIDTH		    EQU	15
BALL_HEIGHT		    EQU	15
BALL_Y_POS          EQU	100
BALL_SPEED          EQU	$6
DRAW_CIRCLE_COMMAND EQU 88
BALL_SHIFT          EQU $1

PADDLE_WIDTH   EQU $8
PADDLE_HEIGHT  EQU $50
PADDLE1_LX     EQU 0
PADDLE1_UY     EQU 50
PADDLE1_RX     EQU 8
PADDLE1_LY     EQU 0

PADDLE2_LX     EQU 632
PADDLE2_UY     EQU 50
PADDLE2_RX     EQU 640
PADDLE2_LY     EQU 0
PADDLE_SPEED   EQU 2

SCREEN_WIDTH                EQU 640
SCREEN_HEIGHT               EQU 480
FRAME_DELAY_TIME            EQU 1
RIGHT_SIDE_OF_SCREEN	    EQU	640
REPAINT_SCREEN_TRAP_CODE	EQU	94
DELAY_FRAME	                EQU	23
CURRENT_TIME_COMMAND        EQU 8

PADDLE_COLOR    EQU $00FFFFFF
RECT_FILL_COLOR EQU $00FFFFFF
SET_PIXEL_COLOR EQU 80
DRAW_RECTANGLE  EQU 87 
FILL_COLOR      EQU 81

KEY_UP_INPUT      EQU $26
KEY_DOWN_INPUT    EQU $28
KEY_SPACE_INPUT   EQU $20
KEY_CTR_INPUT     EQU $11
USER_INPUT        EQU 19
CLR_SCR           EQU 11
CLR_SCR_VAL       EQU $FF00
DRAWING_MODE      EQU 92
DOUBLE_BUFFERED   EQU 17
DISABLE_BUFFER    EQU 16
DRAW_LINE_COMMAND EQU 84
ALL_REG           REG D0-D7/A0-A6    
GET_TIME_COMMAND  EQU 8

    ORG    $1000   
        
START:   
                   
        *Draw the Paddle for Player 1
        
        move.l  #PADDLE_COLOR,d1
        move.b  #SET_PIXEL_COLOR,d0
        trap    #15
        
        move.l  #RECT_FILL_COLOR,d1
        move.l  #FILL_COLOR,d0
        trap    #15
        
        move.w  #PADDLE1_LX,d1
        move.w  #PADDLE1_UY,d2
        move.w  #PADDLE1_RX,d3
        move.w  #PADDLE1_LY,d4
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        
        *Draw the Paddle for Player 2
        
        move.l  #PADDLE_COLOR,d1
        move.b  #SET_PIXEL_COLOR,d0
        trap    #15
        
        move.l  #RECT_FILL_COLOR,d1
        move.l  #FILL_COLOR,d0
        trap    #15
        
        move.w  #PADDLE2_LX,d1
        move.w  #PADDLE2_UY,d2
        move.w  #PADDLE2_RX,d3
        move.w  #PADDLE2_LY,d4
        move.l  #DRAW_RECTANGLE,d0
        trap    #15    
        
        *Set initial ball speed and draw ball
        
        move.l  #BALL_SPEED,d6
        move.l  #0,(ball_left)
        
        move.l  #BALL_SHIFT,d5
        
        move.l  #BALL_Y_POS,d2
        move.l  d2,d4
        add.l   #BALL_HEIGHT,d4
        
        
        *Coordinates for original bitmap rendering
        move.l #CHUNK_WIDTH,(CHUNK_WIDTH1)
        move.l #CHUNK_HEIGHT,(CHUNK_HEIGHT1)
        move.l #CHUNK_STARTX,(CHUNK_STARTX1)
        move.l #CHUNK_STARTY,(CHUNK_STARTY1)
        
        *Store d5,d6,d7 (position trackers of ball) to temp variable for the bitmap renderer to use the registers
        *move.l  d5,(temp1)
        *move.l  d6,(temp2)
        *move.l  d7,(temp3)
              
        bra     Empty
        
*For drawing chunks of bitmap where the entities have displaced from        

BITDRAW
        SUB.W #4,SP             
        MOVE.W #15,D1           
        MOVE.W #15,D2           
        MOVE.W D1,(SP)          
        MOVE.W D1,2(SP)         
        JSR BITMAPDISPLAY       
        ADD.W #4,SP  
        rts 
                           
*LOAD THE WIDTH AND HEIGHT OF THE BITMAP
BITMAPDISPLAY       
        LEA BITMAP,A0           
        MOVE.L $A(A0),D6        
        MOVE.L $16(A0),D1       
        MOVE.L $12(A0),D3       
        ROL.W #8,D1             
        SWAP D1                 
        ROL.W #8,D1             
        ROL.W #8,D6             
        SWAP D6                 
        ROL.W #8,D6             
        ADD.L D6,A0             

*SET UP THE LOOP VARIABLES
        CLR D6                  
        CLR D7                  
        ROL.W #8,D3            
        SWAP D3                 
        ROL.W #8,D3             
        MOVE.L D3,D5            
        MULU #4,D5 
        move.l  d2,(temp4)
        clr     d2
        add.l   (CHUNK_HEIGHT1),d2
        add.l   (CHUNK_STARTY1),d2            
        SUB.L   d2,D1  
        move.l  (temp4),d2 
        MULU D1,D5              
        MOVE.L (CHUNK_STARTX1),D4 
        MULU #4,D4              
        ADD.L D4,D5             
        ADD.L D5,A0             
        SUB.L (CHUNK_WIDTH1),D3 
        MULU #4,D3              

*DISPLAY THE BITMAP ONE CHUNK AT A TIME
        CLR.L D0                
        CLR.L D1                
        CLR.L D2                
        MOVE.B #SET_RESOULTION,D0  
        MOVE.L #OUTPUT_WIDTH,D1 
        SWAP.W D1               
        MOVE.W #OUTPUT_HEIGHT,D1    
        TRAP  #15               
        CLR D0                  
        CLR D1                  
        ADD.L (CHUNK_HEIGHT1),D7  

*DRAW THE PIXEL
LOOP:
        MOVE.L (A0)+,D1         
        LSR.L #8,D1             
        MOVE.W #PEN_COLOR,D0    
        TRAP #15                
        CLR.L D1                
        MOVE.W 4(SP),D1         
        ADD.W  D6,D1            
        MOVE.W 6(SP),D2         
        ADD.W  D7,D2            
        MOVE.W #DRAW_PIXEL,D0   
        TRAP #15                


*INCREMENT THE LOOP VARIABLES
        ADDI.W #1,D6            
        CMP.L (CHUNK_WIDTH1),d6
        BNE   LOOP              

*CHECK IF WE HAVE REACHED THE END OF THE BITMAP
        SUBI.L #1,D7            
        CLR D6                  
        ADD.L D3,A0             
        CMPI.L #0,D7            
        BNE   LOOP    
        move.l  (temp1),d5
        move.l  (temp2),d6
        move.l  (temp3),d7    
        rts
        
*Initially for drawing the bitmap for buffer screen        

BITDRAW1
        SUB.W #4,SP             
        MOVE.W #15,D1           
        MOVE.W #15,D2           
        MOVE.W D1,(SP)          
        MOVE.W D1,2(SP)         
        JSR BITMAPDISPLAY1       
        ADD.W #4,SP   
                           
*LOAD THE WIDTH AND HEIGHT OF THE BITMAP
BITMAPDISPLAY1       
        LEA BITMAP,A0           
        MOVE.L $A(A0),D6        
        MOVE.L $16(A0),D1       
        MOVE.L $12(A0),D3       
        ROL.W #8,D1             
        SWAP D1                 
        ROL.W #8,D1             
        ROL.W #8,D6             
        SWAP D6                 
        ROL.W #8,D6             
        ADD.L D6,A0             

*SET UP THE LOOP VARIABLES
        CLR D6                  
        CLR D7                  
        ROL.W #8,D3            
        SWAP D3                 
        ROL.W #8,D3             
        MOVE.L D3,D5            
        MULU #4,D5 
        move.l  d2,(temp4)
        clr     d2
        add.l   (CHUNK_HEIGHT1),d2
        add.l   (CHUNK_STARTY1),d2            
        SUB.L   d2,D1  
        move.l  (temp4),d2 
        MULU D1,D5              
        MOVE.L (CHUNK_STARTX1),D4 
        MULU #4,D4              
        ADD.L D4,D5             
        ADD.L D5,A0             
        SUB.L (CHUNK_WIDTH1),D3 
        MULU #4,D3              

*DISPLAY THE BITMAP ONE CHUNK AT A TIME
        CLR.L D0                
        CLR.L D1                
        CLR.L D2                
        MOVE.B #SET_RESOULTION,D0  
        MOVE.L #OUTPUT_WIDTH,D1 
        SWAP.W D1               
        MOVE.W #OUTPUT_HEIGHT,D1    
        TRAP  #15               
        CLR D0                  
        CLR D1                  
        ADD.L (CHUNK_HEIGHT1),D7  

*DRAW THE PIXEL
LOOP1
        MOVE.L (A0)+,D1         
        LSR.L #8,D1             
        MOVE.W #PEN_COLOR,D0    
        TRAP #15                
        CLR.L D1                
        MOVE.W 4(SP),D1         
        ADD.W  D6,D1            
        MOVE.W 6(SP),D2         
        ADD.W  D7,D2            
        MOVE.W #DRAW_PIXEL,D0   
        TRAP #15                


*INCREMENT THE LOOP VARIABLES
        ADDI.W #1,D6            
        CMP.L (CHUNK_WIDTH1),d6
        BNE   LOOP1             

*CHECK IF WE HAVE REACHED THE END OF THE BITMAP
        SUBI.L #1,D7            
        CLR D6                  
        ADD.L D3,A0             
        CMPI.L #0,D7            
        BNE   LOOP1
        move.l  (temp1),d5
        move.l  (temp2),d6
        move.l  (temp3),d7  

Empty
        move.b	#DRAWING_MODE,d0       
        move.b	#DOUBLE_BUFFERED,d1
        trap    #15        
        
                                                 
*Start of the game loop before any collision with the player Paddles happens        
gameloop:
	    jsr	    clearScreen 
        jsr     PaddleLoop                        
        jsr     updateBall
        jsr     checkCollideDownP1
        jsr     checkCollideUpP1
        jsr     checkCollideMidP1
        jsr     checkCollideDownP2
        jsr     checkCollideUpP2
        jsr     checkCollideMidP2
        jsr     drawBall
        jsr	    swapBuffers
        jsr     delayFrame
        bra     gameloop
        
*GameLoop after a collision with a player paddle happens        
SubGame:
        jsr     clearScreen
        jsr     PaddleLoop
        
        *On every collision, the slope of the ball is random
        cmp.b   #2,(rand)
        ble     UpdateBall1
        
        cmp.b   #2,(rand)
        bge     UpdateBall2
           
*Delay Frame for pre-collision gameloop
delayFrame
        move.l  #DELAY_FRAME, d0
        move.l  #FRAME_DELAY_TIME, d1
        trap    #15
        rts
*Delay Frame for post-collision gameloop       
delayFrame1
        move.l  #DELAY_FRAME, d0
        move.l  #FRAME_DELAY_TIME, d1
        trap    #15
        bra     SubGame

*ClearScreen Function
clearScreen
        move.b  #CLR_SCR,d0
       	move.l  #CLR_SCR_VAL,d1
       	TRAP    #15
	    rts

*Swap Buffer for pre-collision gameloop 
swapBuffers


        *Draw the player 1 and player 2 paddle if there is no movement
        move.w  #$0,d1
        move.w  (PaddleY),d2
        move.w  #$8,d3
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        
        move.w  #632,d1
        move.w  (PaddleX),d2
        move.w  #640,d3
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
      

	    move.b  #REPAINT_SCREEN_TRAP_CODE,d0
      	trap    #15
      	
        rts 
    
*Swap Buffer for post-collision gameloop
swapBuffers1

        *Draw the player 1 and player 2 paddle if there is no movement
        move.w  #0,d1
        move.w  (PaddleY),d2
        move.w  #8,d3
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        
        move.w  #632,d1
        move.w  (PaddleX),d2
        move.w  #640,d3
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        
        *Display the current score of the Players
        move.b  (Score1),NUMBER_DISPLAY
        jsr     SevenSeg
        move.b  (Score2),NUMBER_DISPLAY2
        jsr     SevenSeg2

	    move.b  #REPAINT_SCREEN_TRAP_CODE,d0
      	trap    #15

	    bra     delayFrame1      


*Update Ball command for start of the game (checks bounds and updates the position)	    
updateBall
        *Move the d5,d6,d7, variables to a temporary var for the bitmap renderer to use registers
        *move.l  d5,(temp1)
        *move.l  d6,(temp2)
        *move.l  d7,(temp3)

        *move.l  (ball_left),(CHUNK_STARTX1)
        *move.l  #BALL_WIDTH,(CHUNK_WIDTH1)
        *move.l  #BALL_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (ball_y),(CHUNK_STARTY1)
        *jsr     Bitdraw
        
	    add.l	d6,(ball_left)
	    cmpi.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left)
	    ble	    noNegativeSet  
        move.l  #-BALL_SPEED,d6                         
	    move.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left)
	    bra	    noPositiveSet
	    
*Boundary limitations for the ball befor the game has started
noNegativeSet
	    cmpi.l	#0,(ball_left)                              
	    bgt	    noPositiveSet
	    move.l  #BALL_SPEED,d6
	
noPositiveSet:
        cmpi.l  #480-BALL_HEIGHT,(ball_y)  
        ble     noBottomCollision
        move.l  #-BALL_SHIFT,d5
        move.l  #480-BALL_HEIGHT,(ball_y)  
        bra     noTopCollision
        

noBottomCollision:
        cmpi.l   #0,(ball_y)
        bgt     noTopCollision
        move.l  #BALL_SHIFT,d5

noTopCollision:
        rts      


*Draw ball function before any collision with player paddles
drawBall
       
        
	    move.l	#RECT_FILL_COLOR,d1
	    move.b	#SET_PIXEL_COLOR,d0
	    trap    #15
	    move.b	#FILL_COLOR,d0
	    trap	#15
	
	    move.b	#DRAW_CIRCLE_COMMAND,d0
	    move.l	(ball_left),d1   
        move.l  (ball_y),d2
        move.l  d2,d4
        add.l   #BALL_HEIGHT,d4                    

	    move.l	d1,d3
	    add.l	#BALL_WIDTH,d3	
	    trap	#15

	    rts

*Check collisions with player paddles for the game to start	    

*Check collision for lower half of paddle (Player1)
checkCollideDownP1
        move.w  (PaddleY),d2
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        add.l   d4,d2
        divu    #2,d2

        cmp.l   d1,d2
        ble     CompareY_DownP1
        rts
        
CompareY_DownP1
        cmp.l   d3,d4
        bge     CompareX_DownP1
        rts
        
CompareX_DownP1
        cmpi.l   #8,(ball_left)
        ble      Player1Score
        rts

*Check collision for upper half of paddle (Player1)
CheckCollideUpP1
        move.w  (PaddleY),d2
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        add.l   d2,d4
        divu    #2,d4
        
        cmp.l   d1,d2
        ble     CompareY_UpP1

CompareY_UpP1
        cmp.l   d3,d4
        bge     CompareX_UpP1
        rts

CompareX_UpP1
        cmpi.l  #8,(ball_left)
        ble     Player1Score
        rts    

*Check collision for middle portion of paddle (Player1)
checkCOllideMidP1
        move.w  (PaddleY),d2
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        add.l   d2,d4
        divu    #2,d4
        move   d4,mid
        
        cmp.l   (mid),d1
        ble     CompareMid1_P1
        rts
        
CompareMid1_P1
        cmp.l   (mid),d3
        bge     CompareMid1X_P1
        rts
        
CompareMid1X_P1
        cmpi.l   #8,(ball_left)
        bge      Player1Score
        rts

*Check collision for lower half of paddle (Player2)
checkCollideDownP2
        move.w  (PaddleX),d2
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        add.l   d4,d2
        divu    #2,d2

        cmp.l   d1,d2
        ble     CompareY_DownP2
        rts
        
CompareY_DownP2
        cmp.l   d3,d4
        bge     CompareX_DownP2
        rts
        
CompareX_DownP2
        add.l    #BALL_WIDTH,(ball_left)
        cmpi.l   #632,(ball_left)
        bge      Player2Score
        sub.l    #BALL_WIDTH,(ball_left)
        rts
        
*Check collision for upper half of paddle (Player2)
CheckCollideUpP2
        move.w  (PaddleX),d2
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        add.l   d2,d4
        divu    #2,d4
        
        cmp.l   d1,d2
        ble     CompareY_UpP2
        rts

CompareY_UpP2
        cmp.l   d3,d4
        bge     CompareX_UpP2
        rts

CompareX_UpP2
        add.l    #BALL_WIDTH,(ball_left)
        cmpi.l   #632,(ball_left)
        bge      Player2Score
        sub.l    #BALL_WIDTH,(ball_left)
        rts

*Check collision for middle portion of paddle (Player1)
checkCollideMidP2
        move.w  (PaddleX),d2
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        
        add.w   d2,d4
        divu    #2,d4
        move.l   d4,mid
        
        
        cmp.l   (mid),d1
        ble     CompareMid1_P2
        rts
        
CompareMid1_P2
        cmp.l   (mid),d3
        bge     CompareMid1_X_P2
        rts
        
CompareMid1_X_P2
        add.l    #BALL_WIDTH,(ball_left)
        cmpi.l   #632,(ball_left)
        bge      Player2Score
        sub.l    #BALL_WIDTH,(ball_left)
        rts


*Check collision for player paddles after the game has started

*Check collision for lower half of paddle (Player1)
checkCollideDown1_P1
        move.w  (PaddleY),d2
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        add.l   d4,d2
        divu    #2,d2

        cmp.l   d1,d2
        ble     CompareY_Down1_P1
        bra     checkCollideUp1_P1
        
CompareY_Down1_P1
        cmp.l   d3,d4
        bge     CompareX_Down1_P1
        bra     checkCollideUp1_P1
        
CompareX_Down1_P1
        cmpi.l   #8,(ball_left)
        ble      Player1Score
        bra      checkCollideUp1_P1

*Check collision for upper half of paddle (Player1)
CheckCollideUp1_P1
        move.w  (PaddleY),d2
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        add.l   d2,d4
        divu    #2,d4
        
        cmp.l   d1,d2
        ble     CompareY_Up1_P1
        bra     checkCollideMid_P1

CompareY_Up1_P1
        cmp.l   d3,d4
        bge     CompareX_Up1_P1
        bra     checkCollideMid_P1

CompareX_Up1_P1
        cmpi.l  #8,(ball_left)
        ble     Player1Score
        bra     checkCollideMid_P1

*Check collision for middle portion of paddle (Player1)
checkCOllideMid_P1
        move.w  (PaddleY),d2
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        add.l   d2,d4
        divu    #2,d4
        move    d4,mid
        
        cmp.l   (mid),d1
        ble     CompareMid_1_P1
        bra     checkCollideDown1_P2
        
CompareMid_1_P1
        cmp.l   (mid),d3
        bge     CompareMid_1_X_P1
        bra     checkCollideDown1_P2
        
CompareMid_1_X_P1
        cmpi.l   #8,(ball_left)
        bge     Player1Score
        bra     checkCollideDown1_P2

*Check collision for lower half of paddle (Player2)
checkCollideDown1_P2
        move.w  (PaddleX),d2
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        add.l   d4,d2
        divu    #2,d2

        cmp.l   d1,d2
        ble     CompareY_Down1_P2
        bra     checkCollideUp1_P2
        
CompareY_Down1_P2
        cmp.l   d3,d4
        bge     CompareX_Down1_P2
        bra     checkCollideUp1_P2
        
CompareX_Down1_P2
        add.l    #BALL_WIDTH,(ball_left)
        cmpi.l   #632,(ball_left)
        bge      Player2Score
        sub.l   #BALL_WIDTH,(ball_left)
        bra      checkCollideUp1_P2

*Check collision for upper half of paddle (Player2)
CheckCollideUp1_P2
        move.w  (PaddleX),d2
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        add.l   d2,d4
        divu    #2,d4
        
        cmp.l   d1,d2
        ble     CompareY_Up1_P2
        bra     checkCollideMid_P2
        
CompareY_Up1_P2
        cmp.l   d3,d4
        bge     CompareX_Up1_P2
        bra     checkCollideMid_P2

CompareX_Up1_P2
        add.l    #BALL_WIDTH,(ball_left)
        cmpi.l   #632,(ball_left)
        bge     Player2Score
        sub.l    #BALL_WIDTH,(ball_left)
        bra      checkCollideMid_P2

*Check collision for middle portion of paddle (Player2)
checkCollideMid_P2
        move.w  (PaddleX),d2
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        move.l  (ball_y),d1
        move.l  d1,d3
        add.l   #BALL_HEIGHT,d3
        
        
        add.w   d2,d4
        divu    #2,d4
        move.l   d4,mid
        
        
        cmp.l   (mid),d1
        ble     CompareMid_1_P2
        bra     drawDiagDown
        
CompareMid_1_P2
        cmp.l   (mid),d3
        bge     CompareMid_1_X_P2
        bra     drawDiagDown
        
CompareMid_1_X_P2
        add.l    #BALL_WIDTH,(ball_left)
        cmpi.l   #632,(ball_left)
        bge     Player2Score
        sub.l    #BALL_WIDTH,(ball_left)
        bra      drawDiagDown
        
*Update ball after the game has started with positive slope (checks bounds and updates the position)
UpdateBall1

        *Render the chunks of space before moving the player paddle in the bitmap
        *move.l  (ball_y),(CHUNK_STARTX1)
        *move.l  #BALL_WIDTH,(CHUNK_WIDTH1)
        *move.l  #BALL_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (ball_y),(CHUNK_STARTY1)
        *jsr     Bitdraw
	    add.l	d6,(ball_left)
	    add.l   d5,(ball_y)
	    cmpi.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left)
	    ble	    noNegativeSet1
        move.l  #-BALL_SPEED,d6                           
	    move.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left) 
	    bra	    noPositiveSet1

*Check for the extreme bounds (top,bottom,left,right)
noNegativeSet1
	    cmpi.l	#0,(ball_left)                               
	    bge	    noPositiveSet1
	    move.l  #BALL_SPEED,d6
	
noPositiveSet1
        cmpi.l  #480-BALL_HEIGHT,(ball_y)  
        ble     noBottomCollision1
        *move.l  -(rand),d5
        move.l  #-BALL_SHIFT,d5
        move.l  #480-BALL_HEIGHT,(ball_y)  
        bra     noTopCollision1
        
noBottomCollision1
        cmpi.l   #0,(ball_y)
        bge      noTopCollision1
        move.l   #BALL_SHIFT,d5
        *move.l   (rand),d5
 

noTopCollision1
        bra     checkCollideDown1_P1 

*Update ball after the game has started with negative slope (checks bounds and updates the position)
UpdateBall2

        *Render the chunks of space before moving the player paddle in the bitmap
        *move.l  (ball_y),(CHUNK_STARTX1)
        *move.l  #BALL_WIDTH,(CHUNK_WIDTH1)
        *move.l  #BALL_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (ball_y),(CHUNK_STARTY1)
        *jsr     Bitdraw
	    add.l	d6,(ball_left)
	    sub.l   d5,(ball_y)
	    cmpi.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left) 
	    ble	    noNegativeSet2                           
	    move.l	#-BALL_SPEED,d6
	    move.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left) 
	    bra	    noPositiveSet2

*Check for the extreme bounds (top,bottom,left,right)
noNegativeSet2
	    cmpi.l	#0,(ball_left)                               
	    bge	    noPositiveSet2
	    move.l  #BALL_SPEED,d6
	
noPositiveSet2
        cmpi.l  #480-BALL_HEIGHT,(ball_y)  
        ble     noBottomCollision2
        move.l  #BALL_SHIFT,d5
        move.l  #480-BALL_HEIGHT,(ball_y)  
        bra     noTopCollision2
        
noBottomCollision2
        cmpi.l   #0,(ball_y)
        bge      noTopCollision2
        move.l   #-BALL_SHIFT,d5
 
noTopCollision2
        bra     checkCollideDown1_P1 
	    
*Draw the ball after collision with the player paddle
drawDiagDown 
        move.l	#RECT_FILL_COLOR,d1
	    move.b	#SET_PIXEL_COLOR,d0
	    trap    #15
	    move.b	#FILL_COLOR,d0
	    trap	#15
	
	    move.b	#DRAW_CIRCLE_COMMAND,d0
	    move.l	(ball_left),d1  
        move.l  (ball_y),d2
 
        move.l  d2,d4
        add.l   #BALL_HEIGHT,d4                    

	    move.l	d1,d3
	    add.l	#BALL_WIDTH,d3	
	    trap	#15
	    
	    move.b  #0,(flag)
	    bra    swapBuffers1       
	    
*Main Paddle Moving Loop       
PaddleLoop
        jsr     TakeInput1
        jsr     TakeInput2
        rts

*Lower movement for player 1
MoveDown1
        
        *Render the chunks of space before moving the player paddle in the bitmap
        *move.l  (PaddleX),(CHUNK_STARTX1)
        *move.l  #8,(CHUNK_WIDTH1)
        *move.l  #PADDLE_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (PaddleX),(CHUNK_STARTY1)
        *jsr     Bitdraw
        move.b  #CLR_SCR,d0
        move.l  #CLR_SCR_VAL,d1
        trap    #15
        
        
        add.w   #1,(PaddleY)
        move.w  #0,d1
        move.w  (PaddleY),d2
        move.w  #8,d3
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        cmp.w   #480,d4
        bge     NoMoveDown1
        
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        rts

*Lower bound for player 1       
NoMoveDown1
        sub.w   #1,(PaddleY)
        move.w  #0,d1
        move.w  (PaddleY),d2
        move.w  #8,d3
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        rts

*Upper movement for player 1    
MoveUp1

        *Render the chunks of space before moving the player paddle in the bitmap
        *move.l  (PaddleY),(CHUNK_STARTX1)
        *move.l  #8,(CHUNK_WIDTH1)
        *move.l  #PADDLE_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (PaddleY),(CHUNK_STARTY1)
        *jsr     Bitdraw
        move.b  #CLR_SCR,d0
        move.l  #CLR_SCR_VAL,d1
        trap    #15

        sub.w   #1,(PaddleY)
        move.w  #0,d1
        move.w  (PaddleY),d2
        move.w  #8,d3
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        
        cmp.w   #0,(PaddleY)
        ble     NoMoveUp1
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        
        rts
        
*Upper bound for player 1    
NoMoveUp1 
        add.w   #1,(PaddleY)
        move.w  #0,d1
        move.w  (PaddleY),d2
        move.w  #8,d3
        move.w  (PaddleY),d4
        add.w   #PADDLE_HEIGHT,d4
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        rts
        
*Lower movement for player 2
MoveDown2
        
        *Render the chunks of space before moving the player paddle in the bitmap
        *move.l  (PaddleX),(CHUNK_STARTX1)
        *move.l  #8,(CHUNK_WIDTH1)
        *move.l  #PADDLE_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (PaddleX),(CHUNK_STARTY1)
        *jsr     Bitdraw
        
        
        move.b  #CLR_SCR,d0
        move.l  #CLR_SCR_VAL,d1
        trap    #15

        add.w   #1,(PaddleX)
        move.w  #632,d1
        move.w  (PaddleX),d2
        move.w  #640,d3
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        cmp.w   #480,d4
        bge     NoMoveDown2
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        rts

*Lower bound for player 2        
NoMoveDown2
        sub.w   #1,(PaddleX)
        move.w  #632,d1
        move.w  (PaddleX),d2
        move.w  #640,d3
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        rts

*Upper movement for player 2
MoveUp2
        *Render the chunks of space before moving the player paddle in the bitmap
        *move.l  (PaddleX),(CHUNK_STARTX1)
        *move.l  #8,(CHUNK_WIDTH1)
        *move.l  #PADDLE_HEIGHT,(CHUNK_HEIGHT1)
        *move.l  (PaddleX),(CHUNK_STARTY1)
        *jsr     Bitdraw
        
        move.b  #CLR_SCR,d0
        move.l  #CLR_SCR_VAL,d1
        trap    #15
        
        move.l  (PaddleX),(CHUNK_STARTX1)
        move.l  #8,(CHUNK_WIDTH1)
        move.l  #PADDLE_HEIGHT,(CHUNK_HEIGHT1)
        move.l  (PaddleX),(CHUNK_STARTY1)

        sub.w   #1,(PaddleX)
        move.w  #632,d1
        move.w  (PaddleX),d2
        move.w  #640,d3
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        
        cmp.w   #0,(PaddleX)
        ble     NoMoveUp2
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        
        rts   

*Upper movement for player 2
NoMoveUp2 
        add.w   #1,(PaddleX)
        move.w  #632,d1
        move.w  (PaddleX),d2
        move.w  #640,d3
        move.w  (PaddleX),d4
        add.w   #PADDLE_HEIGHT,d4
        move.l  #DRAW_RECTANGLE,d0
        trap    #15
        rts  

*Take input for player 1        
TakeInput1     
        move.l  #(KEY_UP_INPUT<<16 + KEY_DOWN_INPUT<<8),d1
        move.b  #USER_INPUT,d0
        TRAP    #15
        move.l  d1, d2
        andi.l  #$00FF0000,d2
        bne     MoveUp1
        move.l  d1, d2
        andi.l  #$0000FF00,d2
        bne     MoveDown1
        rts  
        
*Take input for player 2
TakeInput2
        move.l  #(KEY_SPACE_INPUT<<24 + KEY_CTR_INPUT),d1
        move.b  #USER_INPUT,d0
        TRAP    #15
        move.l  d1, d2
        andi.l  #$FF000000,d2
        bne     MoveUp2
        move.l  d1, d2
        andi.l  #$000000FF,d2
        bne     MoveDown2
        rts 

*Triggered on collision with player 1 paddle (player 1 scoring a point)
Player1Score
        move.l  #BALL_SPEED,d6
        cmp.b   #9,(Score1)
        beq     End
        add.b   #1,(Score1)
        move.b  (Score1),NUMBER_DISPLAY
	    *Get random number for ball slope
	    jsr     seedRandomNumber
        clr     d5
        jsr     getRandomByteIntoD5
        move.b  d5,rand
        jsr     SevenSeg
        bra     drawDiagDown      

*Triggered on collision with player 2 paddle (player 2 scoring a point)
Player2Score  
        move.l  #-BALL_SPEED,d6                           
	    move.l	#RIGHT_SIDE_OF_SCREEN-BALL_WIDTH,(ball_left)
        sub.l   #BALL_WIDTH,(ball_left)
        cmp.b   #9,(Score2)
        beq     End
        add.b   #1,(Score2) 
        move.b  (Score2),NUMBER_DISPLAY2
        
        jsr     seedRandomNumber
        clr     d5
        jsr     getRandomByteIntoD5
        move.b  d5,rand
        jsr     SevenSeg2         
        bra     drawDiagDown
        
*Seven-segment led scoring system for player 1 
SevenSeg
        move.l #PADDLE_COLOR,d1 
        move.l #80,d0
        trap #15
        lea BITMASK_7SEG,a0
        lea NUMBER_DISPLAY,a1
        clr.l d1
        move.b (a1),d1
        add d1,a0
        move.b (a0),d7
        btst #0,d7
        bne FirstSegment
SecondCheck
        lsr.b #1,d7
        btst #0,d7
        bne SecondSegment
ThirdCheck
        lsr.b #1,d7
        btst #0,d7
        bne ThirdSegment
FourthCheck
        lsr.b #1,d7
        btst #0,d7
        bne FourthSegment
FifthCheck
        lsr.b #1,d7
        btst #0,d7
        bne FifthSegment
SixthCheck
        lsr.b #1,d7
        btst #0,d7
        bne SixthSegment
SeventhCheck
        lsr.b #1,d7
        btst #0,d7
        bne SeventhSegment
        rts
FirstSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #40,d1
        move.w #415,d2
        move.w #40,d3
        move.w #435,d4
        trap #15
        bra SecondCheck       
SecondSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #40,d1
        move.w #440,d2
        move.w #40,d3
        move.w #460,d4
        trap #15
        bra ThirdCheck
ThirdSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #20,d1
        move.w #460,d2
        move.w #40,d3
        move.w #460,d4
        trap #15
        bra FourthCheck
FourthSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #20,d1
        move.w #440,d2
        move.w #20,d3
        move.w #460,d4
        trap #15
        bra FifthCheck
FifthSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #20,d1
        move.w #415,d2
        move.w #20,d3
        move.w #435,d4
        trap #15
        bra SixthCheck
SixthSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #20,d1
        move.w #415,d2
        move.w #40,d3
        move.w #415,d4
        trap #15
        bra SeventhCheck
SeventhSegment
        move.w #DRAW_LINE_COMMAND,d0
        move.w #20,d1
        move.w #435,d2
        move.w #40,d3
        move.w #435,d4
        trap #15
        rts
        
*Seven-segment led scoring system for player 2     
SevenSeg2
        move.l #PADDLE_COLOR,d1 
        move.l #80,d0
        trap #15
        lea BITMASK_7SEG,a0
        lea NUMBER_DISPLAY2,a1
        clr.l d1
        move.b (a1),d1
        add d1,a0
        move.b (a0),d7
        btst #0,d7
        bne FirstSegment2
SecondCheck2
        lsr.b #1,d7
        btst #0,d7
        bne SecondSegment2
ThirdCheck2
        lsr.b #1,d7
        btst #0,d7
        bne ThirdSegment2
FourthCheck2
        lsr.b #1,d7
        btst #0,d7
        bne FourthSegment2
FifthCheck2
        lsr.b #1,d7
        btst #0,d7
        bne FifthSegment2
SixthCheck2
        lsr.b #1,d7
        btst #0,d7
        bne SixthSegment2
SeventhCheck2
        lsr.b #1,d7
        btst #0,d7
        bne SeventhSegment2
        rts
FirstSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #620,d1
        move.w #415,d2
        move.w #620,d3
        move.w #435,d4
        trap #15
        bra SecondCheck2     
SecondSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #620,d1
        move.w #440,d2
        move.w #620,d3
        move.w #460,d4
        trap #15
        bra ThirdCheck2
ThirdSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #600,d1
        move.w #460,d2
        move.w #620,d3
        move.w #460,d4
        trap #15
        bra FourthCheck2
FourthSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #600,d1
        move.w #440,d2
        move.w #600,d3
        move.w #460,d4
        trap #15
        bra FifthCheck2
FifthSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #600,d1
        move.w #415,d2
        move.w #600,d3
        move.w #435,d4
        trap #15
        bra SixthCheck2
SixthSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #600,d1
        move.w #415,d2
        move.w #620,d3
        move.w #415,d4
        trap #15
        bra SeventhCheck2
SeventhSegment2
        move.w #DRAW_LINE_COMMAND,d0
        move.w #600,d1
        move.w #435,d2
        move.w #620,d3
        move.w #435,d4
        trap #15
        rts

*Generating random number with every collision with the player for direction and slop of the ball
seedRandomNumber          
        clr.l   d5
        move.b  #GET_TIME_COMMAND,d0    
        TRAP    #15

        move.l  d1,RANDOMVAL
        rts  
 
getRandomByteIntoD5
        movem.l d0-d2,-(sp)       
        move.l  RANDOMVAL, d0     
        andi.b  #$03, d0          
        addq.b  #1, d0            
        move.b  d0, d5            
        movem.l (sp)+, d0-d2      
        rts
       
End
    SIMHALT             ; halt simulator

*Put variables and constants here
PaddleY     dc.w    1
flag        dc.b    2
ball_y      dc.l    100
RNG         dc.b    0
PaddleX     dc.w    1
Mid         dc.l    0
Score1      dc.b    0
Score2      dc.b    0
NUMBER_DISPLAY ds.b 1
NUMBER_DISPLAY2 ds.b 1
ball_left      dc.l 0
BITMASK_7SEG
    dc.b %00111111
    dc.b %00000011
    dc.b %01101101
    dc.b %01100111
    dc.b %01010011
    dc.b %01110110
    dc.b %01011110
    dc.b %00100011
    dc.b %01111111
    dc.b %01110011

bit5    dc.l    0
bit6    dc.l    0
bit7    dc.l    0
rand    dc.l    0
temp1   dc.l    0
temp2   dc.l    0
temp3   dc.l    0
temp4   dc.l    0

BITMAP
    INCBIN "pongus_1.bmp"   
ERRORTEXT
    DC.B 'Image is not 32-bit',0
SOUNDSTRING dc.b 'COUNTS.wav',0
RANDOMVAL   ds.l    1

CHUNK_WIDTH1  dc.l   0
CHUNK_HEIGHT1 dc.l   0
CHUNK_STARTX1 dc.l   0              
CHUNK_STARTY1 dc.l   0               


    END    START        
         

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
