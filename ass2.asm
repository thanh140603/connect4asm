# File:     connect4.asm
# Author:   Brennan Reed
#
# Description:  Main program for MIPS implementation of connect4 game
.data 

whitespace:             .ascii " "
bar:                    .ascii "|"
gameBoard:              .space  42
player1Token:           .asciiz "X"
player2Token:           .asciiz "O"

player1_name: 		.space 100

player2_name: 		.space 100

turnstring:		.asciiz " This turn belongs to: "
titleString:            .asciiz "   ************************\n   **    Connect Four    **\n   ************************\n"

topRow:                 .asciiz "\n   0   1   2   3   4   5   6\n+-----------------------------+\n|+---+---+---+---+---+---+---+|\n"

middleRow:              .asciiz "\n|+---+---+---+---+---+---+---+|\n"

bottomRow:              .asciiz "\n|+---+---+---+---+---+---+---+|\n+-----------------------------+\n   0   1   2   3   4   5   6\n\n"

index_pt1:              .asciiz "| "

index_pt2:              .asciiz "||"

add_newline: 		.asciiz "\n"

player1Prompt:          .asciiz "Player 1: select a row to place your coin (0-6 or -1 to quit):"

player2Prompt:          .asciiz "Player 2: select a row to place your coin (0-6 or -1 to quit):"

IllegalMove:            .asciiz "Illegal move, no more room in that column.\n"

IllegalColumn:          .asciiz "Illegal column number.\n"

player1Wins:            .asciiz "Player 1 wins!\n"

player2Wins:            .asciiz "Player 2 wins!\n"

player1Quits:           .asciiz "Player 1 quit.\n"

player2Quits:           .asciiz "Player 2 quit.\n"

tieGameString:          .asciiz "The game ends in a tie.\n"

undostring:		.asciiz  "Undo press 1  |  Skip press others \n"

blockstring:		.asciiz  "Block press 1  |  Skip press others \n"

undoremain:		.asciiz  "              Undo remaning:"


removestring1:		.asciiz " \nPlayer1: Remove press 1  |  Skip press others \n"

removestring2:		.asciiz " \nPlayer2: Remove press 1  |  Skip press others \n"

col:			.asciiz " \n Col: \n"

row:			.asciiz " \n Row: \n"

pieces_string: 		.asciiz "Coin tossing... Your randomly assigned pieces are:\n"

role: 			.asciiz "    You are "

begin_prompt:		.asciiz "----------------------------Let the game BEGIN-----------------------------\n\n"

start_prompt:		.asciiz "---------------------Welcome to the Four in a Row game---------------------\n"

player1_setName: 	.asciiz " \n Player 1 please enter name: "

player2_setName: 	.asciiz " \n Player 2 please enter name: "

violationremain:	.asciiz " Violation remaining:"

player1_first_move:	.asciiz "\n You have to drop your piece in the center column! "

player2_first_move:	.asciiz "\n You have to drop your piece in the center column!"

socsocstring:		.asciiz "\n ---------------------------------------------------\n"

blockused:		.asciiz "\n Block counting:"

removeused:		.asciiz "            Remove counting:"


#
# Name:     Main program
#
# Description:  Main controlling logic for the program.
#

.text               # this is program code
.globl  main            # main is a global label


main:
    addi    $sp, $sp, -64
    sw $zero,-20($sp)#block1
    sw $zero,-24($sp) #block2
    sw $zero,-28($sp)#remove2
    sw $zero,-32($sp)#remove1

    
    sw $zero, -60($sp)#first move 1
    sw $zero, -64($sp)#first move 2
    
    li $v0,3
    sw $v0, -44($sp)#violation1
    sw $v0, -48($sp)#violatio2
    sw $v0,-52($sp)#undo1
    sw $v0,-56($sp)#undo2

    li 	$v0, 4
    la 	$a0, start_prompt
    syscall
    jal	nameAndPieces
    li 	$v0, 4
    la 	$a0, begin_prompt
    syscall
    
    sw      $ra, -16($sp)
    sw      $ra, 0($sp)
    j       createBoard     # creates the initial game board
createRet:
    jal     displayFirstBoard   # display the initial game board
    lw      $ra, 0($sp)
doneDisplay:
    jal     requestPlayer1Move   # begin game loop
gameOver:
    lw      $ra, -16($sp)
    addi    $sp, $sp, 64
    jr      $ra 


nameAndPieces:
	li	$v0, 4 
	la 	$a0, player1_setName 
	syscall
	li 	$v0, 8          
	la 	$a0, player1_name    
	li 	$a1, 100         
	syscall
	li 	$v0, 4          
	la 	$a0, player2_setName  
	syscall
	li 	$v0, 8          
	la 	$a0, player2_name   
	li 	$a1, 100       
	syscall
	li 	$v0, 42
	li 	$a1, 2
	syscall
	beq 	$a0, 0, player1X
	li 	$t0, 'O'
    	li 	$t1, 'X'
    	sw	$t0, -36($sp)
    	sw	$t1, -40($sp)
    	j 	Print_pieces	
player1X:
    	li 	$t0, 'X'
    	li 	$t1, 'O'
    	sw	$t0, -36($sp)
    	sw	$t1, -40($sp)
    	j 	Print_pieces
Print_pieces:
	li 	$v0, 4
	la 	$a0, pieces_string
	syscall
	la 	$a0, add_newline
	syscall
	la 	$a0, player1_name
	syscall
	la	$a0, role
	syscall
	li 	$v0, 11         
	move 	$a0, $t0      
	syscall
	li 	$v0, 4
	la 	$a0, add_newline
	syscall
	la	$a0,player2_name
	syscall
	la 	$a0,role
	syscall
	li	 $v0, 11
	move 	$a0, $t1
	syscall
	li 	$v0, 4
	la 	$a0, add_newline
	syscall
	jr 	$ra
createBoard:
    li      $s1, 42         
    la      $s2, gameBoard 
    move    $s3, $zero      
    la      $t2, whitespace
    lb      $t1, 0($t2)    
    j       createLoop      
createLoop:
    addi    $t3, $s3, -42
    bgez    $t3, createRet  
    sb      $t1, 0($s2)     
    addi    $s2, $s2, 1     
    addi    $s3, $s3, 1     
    j       createLoop
displayFirstBoard:
    j       displayTitle    
displayBoard:
    move    $s4, $zero      
    move    $s5, $zero     
    j       displayRowLoop 
rowLoopRet:
    jr      $ra            
displayTitle:
    li      $v0, 4         
    la      $a0, titleString    
    syscall                 
    j       displayBoard   
displayRowLoop:
    bne     $s4, $zero, notFirstRow    
    li      $v0, 4
    la      $a0, topRow               
    syscall

notFirstRow:
    move    $s5, $zero          
    j       displayColumnLoop
columnLoopRet:
    addi    $t4, $s4, -5    
    bgez    $t4, doneRowLoop    
    li      $v0, 4              
    la      $a0, middleRow     
    syscall                     
    addi    $s4, $s4, 1         
    j       displayRowLoop
doneRowLoop:
    li      $v0, 4              
    la      $a0, bottomRow      
    syscall                     
    j       rowLoopRet
displayColumnLoop:
    bne     $s5, $zero, notFirstColumn  
    li      $v0, 11                     
    la      $t2, bar                    
    lb      $a0, 0($t2)                
    syscall                            
notFirstColumn:
    li      $v0, 11                 
    la      $t2, bar                
    lb      $a0, 0($t2)             
    syscall                         
    la      $t2, whitespace        
    lb      $a0, 0($t2)            
    syscall                        
    move    $a0, $s4                
    move    $a1, $s5                
    sw      $ra, 0($sp)             
    jal     getArrayIndex          
    lw      $ra, 0($sp)             
    move    $s6, $v0               
    li      $v0, 11                 
    la      $s7, gameBoard          
    add     $s7, $s7, $s6           
    lb      $a0, 0($s7)             
    syscall                         
    la      $t2, whitespace         
    lb      $a0, 0($t2)             
    syscall                         
    addi    $t4, $s5, -6            
    bgez    $t4, lastColumn         
    addi    $s5, $s5, 1            
    j       displayColumnLoop       
lastColumn:
    li      $v0, 4                  
    la      $a0, index_pt2          
    syscall                        
    j       columnLoopRet           
getArrayIndex:
    move    $t0, $a0              
    move    $v0, $a1                 
multLoop:
    blez    $t0, multDone           
    addi    $v0, $v0, 7            
    addi    $t0, $t0, -1           
    j       multLoop               
multDone:
    jr      $ra                     
requestPlayer1Move:
    sw $ra,0($sp)
    jal print1
    lw $ra,0($sp)
    
    lw $t0,-60($sp)
    beq $t0,1,con1
    li $v0,4
    la  $a0,player1_first_move
    syscall
    
    li $v0,5
    syscall
    
    bne $v0, 3, con1_1
    move $a1, $v0
    addi $t0,$t0,1
    sw $t0,-60($sp)
    j processPlayer1Move
    
    con1_1:

    lw  $t1,-44($sp)
    addi $t1,$t1,-1 
    sw $t1,-44($sp)

    sw $ra,0($sp)                              
    jal violation1_check                      
    lw $ra,0($sp)
    
    j requestPlayer1Move
    
    con1:
    li      $v0, 4                  
    la      $a0, removestring1    
    syscall                         
    li      $v0, 5                  
    syscall 
    beq     $v0,1,remove1
    
    li      $v0, 4                  
    la      $a0, player1Prompt      
    syscall                         
    li      $v0, 5                  
    syscall                         
    move    $a1, $v0                
    addi    $t4, $zero, -1          
    addi    $a2, $zero, 1           
    beq     $t4, $a1, playerQuit   
    j       processPlayer1Move      


remove1:
    lw      $t0,-28($sp) 
    beq     $t0,1,requestPlayer1Move
    addi    $t0,$t0,1
    sw      $t0,-28($sp)  
    
    la      $t2, whitespace              
    lb      $t3, 0($t2)  
    
    la      $t2, -40($sp)              
    lb      $t4, 0($t2) 
    
    li      $v0, 4                  
    la      $a0, col      
    syscall                         
    li      $v0, 5                 
    syscall 
    move    $t0,$v0
    
    li      $v0, 4                  
    la      $a0, row      
    syscall                         
    li      $v0, 5                 
    syscall 
    move    $t1,$v0
    
    #t0 cot, t1 hang
    
    add $t2,$zero,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t0	                    #t2 ung voi index muon xoa

    la      $s1, gameBoard                 
    add     $s1, $s1, $t2                 
    lb      $t5, 0($s1)                    #gia tri cua index muon xoa        
    
    bne     $t5, $t4, remove_exit1	   #remove khong duoc
    li      $v0,0    #v0=0
    li      $a0,7  #a0=7

    
    removeloop1:
    slt $v0, $t2,$a0      #v0=1 khi t2<7
    beq $v0, 1, remove_exitt1     	#chay loop cho den khi den dong tren cung thi dung
    la      $s7, gameBoard              #lay gia tri o tren lien ke bo vao o duoi lien ke 
    add     $s7, $s7, $t2 
    lb      $t6,-7($s7)
    sb      $t6,0($s7)
    subi    $t2,$t2,7
    j removeloop1
     
remove_exitt1:
    la      $s7, gameBoard               
    add     $s7, $s7, $			#o tren cung cuar cot do thanh khoang trang vi da xoa mot o
    sb      $t3, 0($s7)
    
    j check1
check1:
    move $a0,$t1
    move $a1,$t0
    li $a2,1   
    while1:
    li $v0,0
    lw $a3,-36($sp)
    li $a2,1
    slti    $v0,$a0,1
    beq     $v0,1,requestPlayer2Move
    
    sw      $ra, 0($sp)                             
    jal     checkWinner                    
    lw      $ra, 0($sp)    
                     
    addi    $t4, $zero, 1                   
    beq     $t4, $v0, gameOver    
    subi    $a0,$a0,1         
          
    j while1                                   
remove_exit1:
    lw $t0,-28($sp)
    subi $t0,$t0,1                  
    sw $t0,-28($sp)
    j requestPlayer1Move
    

   
remove2:
    lw $t0,-32($sp)
    beq $t0,1,requestPlayer2Move
    addi $t0,$t0,1
    sw $t0,-32($sp)  #check xem da remove tu truoc hay chua

    
    
    la      $t2, whitespace              
    lb      $t3, 0($t2)  #t3 tuong ung voi khoang trang
    
    la      $t2, -36($sp)              
    lb      $t4, 0($t2) #t4 tuong ung voi X
    
    li      $v0, 4                  
    la      $a0, col      
    syscall                         
    li      $v0, 5                 
    syscall 
    move    $t0,$v0
    
    li      $v0, 4                  
    la      $a0, row      
    syscall                         
    li      $v0, 5                 
    syscall 
    move    $t1,$v0
    
    #t0 cot, t1 hang
    
    add $t2,$zero,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    add $t2,$t2,$t1
    
    add $t2,$t2,$t0	                    #t2 ung voi index muon xoa
    
    
    
    
    
    la      $s1, gameBoard                 
    add     $s1, $s1, $t2                 
    lb      $t5, 0($s1)                    #gia tri cua index muon xoa        
    
    bne     $t5, $t4, remove_exit2	    #gia tri o muon xoa khac O thi ket thuc, chuyen sang luot player2, player1 mat luot?????
    li      $v0,0    #v0=0
    li      $a0,7  

    
    removeloop2:
    slt $v0, $t2,$a0
    beq $v0, 1, remove_exitt2
    la      $s7, gameBoard               
    add     $s7, $s7, $t2 
    lb      $t6,-7($s7)
    sb      $t6,0($s7)
    subi    $t2,$t2,7
    j removeloop2
     
remove_exitt2:
    la      $s7, gameBoard               
    add     $s7, $s7, $t2
    sb      $t3, 0($s7)
    
    j check2

    
check2:
    li $v0,0
    move $a0,$t1
    move $a1,$t0
    while2:
    lw $a3,-40($sp)
    li $a2,2
    slti    $v0,$a0,1
    beq     $v0,1,requestPlayer1Move
    sw      $ra, 0($sp)                    
    jal     checkWinner                    
    lw      $ra, 0($sp)                     
    addi    $t4, $zero, 1                   
    beq     $t4, $v0, gameOver    
    subi    $a0,$a0,1         
           
    j while2                                
    
remove_exit2:
    lw $t0,-28($sp)
    subi $t0,$t0,1
    sw $t0,-28($sp)
    j requestPlayer2Move   
    


# Description: resuests user input from player2
#
# Arguments:    NA
#
# Registers:    a0: stores the player prompt string
#               a1: stores the inputted integer value
#               a2: stores the current player value
#               v0: stores the syscall value
#               t4: used in checking to see if the player quit
#
# Returns:  NA


requestPlayer2Move:
    sw $ra,0($sp)
    jal print2
    lw $ra,0($sp)

    lw $t0,-64($sp)
    beq $t0,1,con2
    li $v0,4
    la  $a0,player2_first_move
    syscall
    
    li $v0,5
    syscall
    bne $v0, 3, con2_1
    move $a1, $v0
    addi $t0,$t0,1
    sw $t0,-64($sp)
    j processPlayer2Move
    
    con2_1:
    lw $t1,-48($sp)
    addi $t1,$t1,-1
    sw $t1,-48($sp)
    
    sw $ra,0($sp)                              
    jal violation2_check                      
    lw $ra,0($sp)
    
    j requestPlayer2Move
    
    con2:

    li      $v0, 4                  
    la      $a0, removestring2    
    syscall                         
    li      $v0, 5                  
    syscall 
    beq     $v0,1,remove2

    li      $v0, 4                  
    la      $a0, player2Prompt      
    syscall                         
    li      $v0, 5                 
    syscall                         
    move    $a1, $v0                
    addi    $t4, $zero, -1          
    addi    $a2, $zero, 2           
    beq     $t4, $a1, playerQuit   
    j       processPlayer2Move      


# Description: processes user input for player1's turn
#
# Arguments:    a1: stores the inputted column value
#
# Registers:    a0: stores the available row index or -1 if there are no spaces available
#               a2: stores the current player value
#               a3: stores the current player token value
#               v0: stores the sysCall value
#               s6: stores the currrent array index
#               s7: stores the address of the current array index
#               t1: temporarily stores player1's token value
#               t2: stores the address of player1's token
#               t3: holds the value returned from validIndex
#               t4: holds the value used in checking if the game is over
#
# Returns:  NA
#

processPlayer1Move:
    sw      $ra, 0($sp)                     
    jal     validIndex                      
    lw      $ra, 0($sp)                     
    move    $t3, $v0                        
    addi    $a2, $zero, 1                   
    bnez    $t3, invalidPlayerIndex         
    sw      $ra, 0($sp)                     
    jal     availableSpace                  
    lw      $ra, 0($sp)                     
    addi    $t3, $zero, -1                  
    move    $a0, $v0                        
    addi    $a2, $zero, 1                   
    beq     $a0, $t3, invalidSpaceChoice   
    sw      $ra, 0($sp)                     
    jal     getArrayIndex                   
    lw      $ra, 0($sp)                     
    la      $t2, -36($sp)               
    lb      $t1, 0($t2)                     
    move    $s6, $v0                        
    move    $t8, $v0
    la      $s7, gameBoard                 
    add     $s7, $s7, $s6                   

    sb      $t1, 0($s7)                     
    move    $a3, $t1                       
    addi    $a2, $zero, 1                   
    sw      $ra, 0($sp)                    
    jal     checkWinner                     
    lw      $ra, 0($sp)                     
    addi    $t4, $zero, 1                   
    beq     $t4, $v0, gameOver             
    
    li      $v0, 4                  		
    la      $a0, undostring    			
    syscall                         		
    
    
    li      $v0, 5                 		
    syscall  
    
    addi    $a2, $zero, 1 
    
    sw $ra,0($sp)
    jal undo_check1
    lw $ra,0($sp)
    
    addi    $a2, $zero, 1 
    beq     $v0, 1, undo
    
    p_con1:
    
    li      $v0, 4                  		
    la      $a0, blockstring   			
    syscall         
                    		
    li      $v0, 5                 		 
    syscall  
    
    addi    $a2, $zero, 1 
    beq     $v0, 1, block2
    continue1:
    
    addi    $a2, $zero, 1
    j       switchPlayers                   

undo:
    beq $a2,2,undo_con
    lw $t0,-52($sp)
    addi $t0,$t0,-1
    sw $t0,-52($sp)
    undo_con_con:
    la      $t2, whitespace             
    lb      $t1, 0($t2) 
    la      $s7, gameBoard                  
    add     $s7, $s7, $t8                  
    sb      $t1, 0($s7)                    
    bne     $a2,1,requestPlayer2Move
    j requestPlayer1Move
    undo_con:
    lw $t0,-56($sp)
    addi $t0,$t0,-1
    sw $t0,-56($sp)
    j undo_con_con  
undo_check1:
    lw $t0,-52($sp)
    sw $t0,-52($sp)
    beq $t0,$zero,undo_check_exit1
    jr $ra
    undo_check_exit1:
    lw $t0,-44($sp)
    addi $t0,$t0,-1
    sw $t0,-44($sp)
    move $t1,$ra
    jal violation1_check
    move $ra,$t1
    lw   $ra, 0($sp)
    j p_con1
    

# Description: processes user input for player2's turn
#
# Arguments:    a1: stores the inputted column value
#
# Registers:    a0: stores the available row index or -1 if there are no spaces available
#               a2: stores the current player value
#               a3: stores the current player token value
#               v0: stores the sysCall value
#               s6: stores the currrent array index
#               s7: stores the address of the current array index
#               t1: temporarily stores player2's token value
#               t2: stores the address of player2's token
#               t3: holds the value returned from validIndex
#               t4: holds the value used in checking if the game is over
#
# Returns:  NA

processPlayer2Move:
    sw      $ra, 0($sp)                     
    jal     validIndex                      
    lw      $ra, 0($sp)                    
    move    $t3, $v0                        
    addi    $a2, $zero, 2                   
    bnez    $t3, invalidPlayerIndex         
    sw      $ra, 0($sp)                     
    jal     availableSpace                  
    lw      $ra, 0($sp)                     
    addi    $t3, $zero, -1                  
    move    $a0, $v0                        
    addi    $a2, $zero, 2                   
    beq     $a0, $t3, invalidSpaceChoice    
    sw      $ra, 0($sp)                     
    jal     getArrayIndex                   
    lw      $ra, 0($sp)                     
    la      $t2, -40($sp)               
    lb      $t1, 0($t2)                     
    move    $s6, $v0                        
    move    $t8, $v0
    la      $s7, gameBoard                  
    add     $s7, $s7, $s6                   
    sb      $t1, 0($s7)                     
    move    $a3, $t1                        
    addi    $a2, $zero, 2                   
    sw      $ra, 0($sp)                     
    jal     checkWinner                     
    lw      $ra, 0($sp)                     
    addi    $t4, $zero, 1                   
    beq     $t4, $v0, gameOver              
    
    li      $v0, 4                  		
    la      $a0, undostring    			
    syscall                         		
    li      $v0, 5                 		 
    syscall  
    addi    $a2, $zero, 2
    
    beq     $v0, 1, undo
    addi    $a2, $zero, 2
    
    
    li      $v0, 4                  		
    la      $a0, blockstring   			
    syscall                         		
    li      $v0, 5                 		 
    syscall  
    addi    $a2, $zero, 1 
    beq     $v0, 1, block1
    addi    $a2, $zero, 2
    
    continue2:
    
    j       switchPlayers                   

# Description: checks whether an inputted index is in bounds
# Arguments:    a1: column index
# Registers:    t0: stores the column index         
# Returns:      v0: 0 if in range, 1 if out of bounds


validIndex:
    slt     $v0, $a1, $zero     
    bnez    $v0, indexReturn    
    move    $t0, $a1            
    addi    $t0, $t0, -6        
    slt     $v0, $zero, $t0     
indexReturn:
    jr      $ra                 


invalidPlayerIndex:
    sw $ra,0($sp)
    jal invalid_col1
    lw $ra,0($sp)
    
    li      $v0, 4                          
    la      $a0, IllegalColumn              
    syscall                                 
    addi    $t2, $zero, 2                   
    beq     $a2, $t2, requestPlayer2Move    
    j       requestPlayer1Move              


invalidSpaceChoice:
    sw $ra,0($sp)
    jal invalid_col1
    lw $ra,0($sp)

    li      $v0, 4                          
    la      $a0, IllegalMove               
    syscall                                 
    addi    $t2, $zero, 2                   
    beq     $a2, $t2, requestPlayer2Move   
    j       requestPlayer1Move              


availableSpace:
    addi    $a0, $zero, 5                  
spaceLoop:
    sw      $ra, 0($sp)                     
    jal     getArrayIndex                 
    lw      $ra, 0($sp)                     
    la      $t2, whitespace                 
    lb      $s5, 0($t2)                     # s5 = whitespace character
    move    $s6, $v0                        
    la      $s7, gameBoard                 
    add     $s7, $s7, $s6                   
    lb      $s4, 0($s7)                     
    beq     $s4, $s5, spaceAvailable        
    addi    $a0, $a0, -1                    
    slt     $t5, $a0, $zero                 
    bne     $t5, $zero, noSpaceAvailable    
    j       spaceLoop                       
spaceAvailable:
    move    $v0, $a0                       
    jr      $ra                            
noSpaceAvailable:
    addi    $v0, $zero, -1                  
    jr      $ra                             



checkWinner:
    addi    $s1, $a0,0                     
    addi    $s2, $a1 ,0                  
    sw      $ra, 0($sp)                    
    sw      $a0, -4($sp)                    
    sw      $a1, -8($sp)                   
    j       check_Horizontal_Win             
hLoopRet:
    j       check_Vertical_Win                
vLoopRet:
    j       check_Diagonal_WIn                
diagonalRet:
    j       checkTieGame                    

check_Horizontal_Win:
    lw      $s1, -4($sp)                    
    li    $s2, 0                    
    li    $s3, 0                
    j       horizontalLoop                 

horizontalLoop:
    add    $t6, $s2,$zero                   
    subi    $t6, $t6, 6                    
    bgtz    $t6, hLoopRet                 
    add    $a0, $s1 ,$zero                      
    add    $a1, $s2 ,$zero                       
    sw      $ra, -12($sp)                  
    jal     getArrayIndex                  
    lw      $ra, -12($sp)                  
    add    $s6, $v0 ,$zero                     
    la      $s7, gameBoard                  
    add     $s7, $s7, $s6                   
    lb      $s4, 0($s7)                    
    bne     $a3, $s4, hLoopReset            
    subi    $s3, $s3, -1                     
    
    subi    $t4, $s3, 3                   
    bgtz    $t4, winner                    
    subi    $s2, $s2, -1                   
    j       horizontalLoop                 

hLoopReset:
    li    $s3, 0                     
    subi    $s2, $s2, -1                    
    j       horizontalLoop                 

check_Vertical_Win:
    li    $s3, 0                   
    lw      $s2, -8($sp)                    
    subi    $s1, $zero, -5                  
    j       verticalLoop                   

verticalLoop:
    slt     $t4, $s1, $zero                 
    bne     $t4, $zero, vLoopRet           
    add    $t6, $s2 ,$zero                       
    add    $a0, $s1 ,$zero                     
    add    $a1, $s2 ,$zero                       
    sw      $ra, -12($sp)                   
    jal     getArrayIndex                   
    lw      $ra, -12($sp)                   
    add    $s6, $v0 , $zero                      
    la      $s7, gameBoard                  
    add     $s7, $s7, $s6                   
    lb      $s4, 0($s7)                     
    bne     $a3, $s4, vLoopReset            
    subi    $s3, $s3, -1                    
    subi    $t4, $s3, 3                   
    bgtz    $t4, winner                     
    subi    $s1, $s1, 1                    
    j       verticalLoop                   

vLoopReset:
    li    $s3, 0                      
    subi    $s1, $s1, 1                    
    j       verticalLoop                   

check_Diagonal_WIn:
    lw      $s1, -4($sp)                    
    lw      $s2, -8($sp)                   
    j       rightDiagonalPrep               
rDiagonalRet:
    lw      $s1, -4($sp)                    
    lw      $s2, -8($sp)                    
    j       leftDiagonalPrep               

rightDiagonalPrep:
    li    $s3, 0                     
    slti    $t4, $s1, 5                     
    beq     $t4, $zero, checkRightDiagonal  
    blez    $s2, checkRightDiagonal         
    subi    $s1, $s1, -1                    
    subi    $s2, $s2, 1                   
    j       rightDiagonalPrep              

leftDiagonalPrep:
    li    $s3, 0                      
    slti    $t4, $s1, 5                    
    beq     $t4, $zero, checkLeftDiagonal  
    slti    $t4, $s2, 6                     
    beq     $t4, $zero, checkLeftDiagonal   
    subi    $s1, $s1, -1                     
    subi    $s2, $s2, -1                    
    j       leftDiagonalPrep               

checkRightDiagonal:
    add    $t6, $s2 ,$zero                      
    subi    $t6, $t6, 6                   
    bgtz    $t6, rDiagonalRet             
    add    $a0, $s1  ,$zero                     
    add    $a1, $s2   ,$zero                   
    sw      $ra, -12($sp)                   
    jal     getArrayIndex                  
    lw      $ra, -12($sp)                 
    add    $s6, $v0 , $zero                       
    la      $s7, gameBoard                  
    add     $s7, $s7, $s6                   
    lb      $s4, 0($s7)                     
    lw      $a0, -4($sp)                    
    bne     $a3, $s4, rDiagonalReset       
    subi    $s3, $s3, -1                    
    subi    $t4, $s3, 3                    
    bgtz    $t4, winner                     
    subi    $s1, $s1, 1                    
    subi    $s2, $s2, -1                     
    j       checkRightDiagonal             

rDiagonalReset:
    li    $s3, 0                      
    subi    $s1, $s1, 1                    
    subi    $s2, $s2, -1                     
    j       checkRightDiagonal              

checkLeftDiagonal:
    slti    $t4, $s2, 0                     
    bne     $t4, $zero, diagonalRet         
    slti    $t4, $s1, 0                     
    bne     $t4, $zero, diagonalRet        
    add    $a0, $s1, $zero                       
    add    $a1, $s2, $zero                     
    sw      $ra, -12($sp)                  
    jal     getArrayIndex                   
    lw      $ra, -12($sp)                   
    add    $s6, $v0, $zero                        
    la      $s7, gameBoard                  
    add     $s7, $s7, $s6                  
    lb      $s4, 0($s7)                    
    lw      $a0, -4($sp)                    
    bne     $a3, $s4, lDiagonalReset        
    subi    $s3, $s3, -1                    
    subi    $t4, $s3, 3                    
    bgtz    $t4, winner                     
    subi    $s1, $s1, 1                    
    subi    $s2, $s2, 1                    
    j       checkLeftDiagonal               

lDiagonalReset:
    li    $s3, 0                      
    subi    $s1, $s1, 1                    
    subi    $s2, $s2, 1                    
    j       checkLeftDiagonal               

checkTieGame:
    li    $t4, 0                      
    la      $t5, gameBoard                  
    la      $t2, whitespace                
    lb      $t1, 0($t2)                    
    j       checkTieLoop                    

checkTieLoop:
    subi    $t3, $t4, 42                  
    bgez    $t3, tieGame                    
    lb      $t6, 0($t5)                     
    beq     $t1, $t6, doneWinCheck          
    subi    $t4, $t4, -1                     
    subi    $t5, $t5, -1                    
    j       checkTieLoop                    

tieGame:
    jal     displayBoard                    
    addi      $v0, $v0, 4                          
    la      $a0, tieGameString              
    syscall                                 
    j       gameOver                        

winner:
    jal     displayBoard                    
    lw      $ra, -12($sp)                  
    subi    $t2, $zero, -1                   
    bne     $a2, $t2, p2Wins                
    li      $v0, 4                          
    la      $a0, player1Wins                
    syscall                                 
    lw      $a0, -4($sp)                  
    lw      $a1, -8($sp)                    
    addi    $v0, $zero, 1                   
    j exit
    jr      $ra                             
p2Wins:
    li      $v0, 4                          
    la      $a0, player2Wins                
    syscall                                 
    lw      $a0, -4($sp)                    
    lw      $a1, -8($sp)                    
    addi    $v0, $zero, 1                   
    j exit 
    jr      $ra     			     
                          

playerQuit:
    li    $t2, 1                   
    bne     $a2, $t2, player2Quit           
    li      $v0, 4                          
    la      $a0, player1Quits               
    syscall                                
    j       gameOver                        
player2Quit:
    li      $v0, 4                          
    la      $a0, player2Quits              
    syscall                                 
    j       gameOver                       

doneWinCheck:
    li    $v0, 0                     
    lw      $ra, 0($sp)                     
    lw      $a0, -4($sp)                   
    lw      $a1, -8($sp)                    
    jr      $ra                             

switchPlayers:
    sw      $ra, 0($sp)                    
    sw      $a2, -4($sp)                    
    jal     displayBoard                    
    lw      $ra, 0($sp)                     
    lw      $a2, -4($sp)                    
    addi    $t3, $zero, 1                   
    bne     $a2, $t3, requestPlayer1Move    
    j       requestPlayer2Move              
    

block1:
    lw $t0,-20($sp)
    beq $t0,$zero,block1_1
    beq $t0,1,requestPlayer1Move
    
block2:
    lw $t0,-24($sp)
    beq $t0,$zero,block2_1
    beq $t0,1,requestPlayer2Move
block1_1:  
    addi    $t0,$t0,1
    sw      $t0, -20($sp)
    la      $t2, whitespace                 
    lb      $t1, 0($t2) 
    la      $s7, gameBoard                  
    add     $s7, $s7, $t8                  
    sb      $t1, 0($s7)                    
    j requestPlayer1Move
block2_1:
    addi $t0,$t0,1
    sw   $t0, -24($sp)
    la      $t2, whitespace                 
    lb      $t1, 0($t2) 
    la      $s7, gameBoard                  
    add     $s7, $s7, $t8                   
    sb      $t1, 0($s7)                     
    j requestPlayer2Move
violation1_check:
    lw $t0,-44($sp)
    li $t9,0
    slt $t9,$t0,$zero
    li $a2,2
    sw $t0,-44($sp)
    beq $t9,1,winner
    li $a2,1
    jr $ra
    
    
violation2_check:
    lw $t0,-48($sp)
    li $t9,0
    slt $t9,$t0,$zero
    li $a2,1
    sw $t0,-48($sp)
    beq $t9,1,winner
    li $a2,2    
    jr $ra

print1:
    la $a0,socsocstring
    li $v0,4
    syscall
    la $a0,turnstring
    li $v0,4
    syscall
    la $a0,player1_name
    li $v0,4
    syscall
    la $a0,violationremain
    li $v0,4
    syscall
    lw $a0,-44($sp)
    li $v0,1
    syscall
    la $a0,undoremain
    li $v0,4
    syscall
    lw $a0,-52($sp)
    li $v0,1
    syscall
    la $a0,blockused
    li $v0,4
    syscall
    lw $a0,-20($sp)
    li $v0,1
    syscall
    la $a0,removeused
    li $v0,4
    syscall
    lw $a0,-28($sp)
    li $v0,1
    syscall
    la $a0,socsocstring
    li $v0,4
    syscall
    
    jr $ra
    
print2:
    la $a0,socsocstring
    li $v0,4
    syscall
    
    la $a0,turnstring
    li $v0,4
    syscall

    la $a0,player2_name
    li $v0,4
    syscall
    
    la $a0,violationremain
    li $v0,4
    syscall
    
    lw $a0,-48($sp)
    li $v0,1
    syscall
    
    la $a0,undoremain
    li $v0,4
    syscall
    
    lw $a0,-56($sp)
    li $v0,1
    syscall
    
    la $a0,blockused
    li $v0,4
    syscall
    
    lw $a0,-24($sp)
    li $v0,1
    syscall
    
    la $a0,removeused
    li $v0,4
    syscall
    
    lw $a0,-32($sp)
    li $v0,1
    syscall
    
    la $a0,socsocstring
    li $v0,4
    syscall
    
    jr $ra
      
          
exit:
li $v0,10
syscall
    

invalid_col1:
	beq $a2,2,invalid_col2
	lw $t0,-44($sp)
	subi $t0,$t0,1
	sw $t0,-44($sp)
	sw $ra,0($sp)
	jal violation1_check
	lw $ra,0($sp)
	
	j invalid_exit
		
	
	invalid_col2:
	lw $t0,-48($sp)
	subi $t0,$t0,1
	sw $t0,-48($sp)
	sw $ra,0($sp)
	jal violation2_check
	lw $ra,0($sp)	
						
invalid_exit:
	jr $ra


        
