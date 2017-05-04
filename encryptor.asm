
; File: encryptor.asm
; Description: 	An encryption/decryption program that prompts the user for a key and message,
; 		and depending on whether encryption or decryption is chosen, either toggles the LCB then adds the key
; 		or subtracts the key then toggles the LCB
; 
;
; Authors: Tan Pham, Joanna Gonzales, Samad Mazarei
; Project: CS 131 Assignment 8
; Date: 5/2/2017
;
; Operational Conditions: User is given the option to ecrypt or decrypt a message,
;	and is prompted for an encryption key, and message. A message of no 
;	more than 20 characters is engineered for. The encryption algorithm involves 
;	first togling the LCB, followed by adding the user defined key. To decrypt, 
;	the key is subtracted, followed by the toggling of the LCB. The encrypted, 
;	or decrypted, message is then displayed. The program loops continuously.
;		

; Note: No range checking is performed on the number of message characters
;
;
	.ORIG	x3000
;
;
; PROMPT USER FOR E OR D, VALIDATE, AND MOVE ON
;
L1	LEA R0,PROMPT1	
	PUTS			
	GETC			
	OUT				
	ADD R1,R0,#0	
	LD R2,DCOMP		
	ADD R2,R1,R2	
	BRz DECRYPT		
	LD R2,ECOMP		
	ADD R2,R1,R2	
	BRz ENCRYPT		
	LD R0,NEWLINE	
	OUT				
	BR L1			
; The following are all data values used in the above code
;
PROMPT1 .STRINGZ "Enter E)ncrypt or D)ecrypt: "
ECOMP 	.FILL 	xFFBB
DCOMP	.FILL	xFFBC
NEWLINE	.FILL	x0A
;
;
; SET R2 TO NEGATIVE AS FLAG REPRESENTING DECRYPTION
; SELECTED FOR LATER USE
; THEN MOVE ON TO KEY INPUT
;
DECRYPT	ADD R2,R2,#-1	;R2 holds negative value to denote decrypt choisen
	BRnzp KEYLOOP	;Branch to key prompt

;
; SET R2 TO POSITIVE AS FLAG REPRESENTING ENCRYPTION
; SELECTED FOR LATER USE
; THEN MOVE ON TO KEY INPUT
;
ENCRYPT ADD R2,R2,#1	;R2 holds positive value to denote encrypt chosen
	BRnzp KEYLOOP	;Branch to key prompt
;
;
;
; GETS KEY FROM USER AND VALIDATES IT IS 
; 1-9 AND IF NOT REQUESTS IT AGAIN. R3 IS INITIALIZED WITH 
; THE NEGATIVE VALUE OF ASCII 9, A COUNTER IS INITIALIZED 
; IN R4, AND R3 IS INCREMENTED, R4 DECREMENTED, AFTER EACH UNSUCCESSFUL
; ATTEMPT AT MATCHING THE KEY AGAINST A VALID VALUE. WHEN THE COUNTER REACHES 
; ZERO, ALL VALID INPUTS HAVE BEEN CHECKED AND USER IS REPROMPTED
;
KEYLOOP	LD R3,VALID	
	AND R4,R4,#0	
	ADD R4,R4,#9	
	LD R0,NEWLINE	 
	OUT				
	LEA R0,PROMPT2	
	PUTS			
	GETC			
	OUT				
KEYV	ADD R1,R0,R3	
	BRz RED	
	ADD R3,R3,#1	
	ADD R4,R4,#-1	
	BRz KEYLOOP 
	BRp KEYV
;
;
; DATA VALUES USED IN THE ABOVE CODE
;
PROMPT2	.STRINGZ "Enter Encryption Key (1-9): "
VALID	.FILL #-57
;
;
; THIS BLOCK CONVERTS THE ASCII VALUE FOR THE KEY INTO A 
; LITERAL VALUE THEN DEPENDING ON WHETHER ENCRYPT OR DECRYPT
; WAS CHOSEN THE KEY IS POSITIVE OR NEGATED
;
;
RED	LD R6, ASCII
	ADD R6,R6,R0	
	ADD R2,R2,#0
	BRp L2
	NOT R6,R6
	ADD R6,R6,#1
;
; THIS BLOCK PROMPTS USER FOR MESSAGE, CHECKS EACH CHAR FOR 
; NEWLINE, BRANCHING IF NEWLINE, IF NOT IT
; BRANCHES TO APPRPRIATE BLOCK FOR ENCRYPT OR DECRYPT 
; ALGORITHM
;
L2	LD R0,NEWLINE
	OUT
	LEA R0,PROMPT3
	LEA R5,MESS
	PUTS
INP	GETC
	OUT
	ADD R1,R0,#-10
	BRz LAST
	ADD R1,R0,#0 
	ADD R2,R2,#0
	BRn DCRYPT
	BRp ECRYPT
;
; THIS BLOCK TOGGLES THE LCB THEN MOVES ON TO ADD 
; THE KEY, THEN BRANCHES TO SAVE THE RESULTANT CHAR
; IN MEMORY
;
ECRYPT	ADD R1,R1,#-2
	BRp ECRYPT
	BRn ODD
	BRz EVEN
ODD	ADD R0,R0,#-1
	BR ECON
EVEN	ADD R0,R0,#1
	BR ECON
ECON	ADD R0,R0,R6
	BR SAV
;
; THIS BLOCK ADDS THE KEY THEN MOVES ON TO TOGGLE THE LCB
; THEN BRANCHES TO SAVE THE RESULTANT CHAR
; IN MEMORY
;
DCRYPT	ADD R1,R0,R6
	ADD R0,R0,R6
LOOP	ADD R1,R1,#-2
	BRp LOOP
	BRn ODD2
	BRz EVEN2
ODD2	ADD R0,R0,#-1
	BR SAV
EVEN2	ADD R0,R0,#1
	BR SAV
;
; THIS BLOCK STORES EACH CHAR IN SEQUENTIAL MEMORY LOCATIONS
; THEN BRANCHES BACK TO INPUT FOR THE NEXT CHAR
;
SAV	STR R0,R5,#0
	ADD R5,R5,#1
	BRnzp INP
;
; WHEN THE CHAR ENTERED IS THE NEWLINE
; IT IS STORED AS A NULL CHAR TO END THE CHAR STRING
; THEN LOADS THE APPROPRIATE PROMPT BASED ON 
; THE VALUE OF R2 (E OR D CHOSEN)
;
LAST	STR R1,R5,#0
	ADD R2,R2,#0
	BRn STEP
	LEA R0,ERES
	BR OUTPUT
STEP	LEA R0,DRES
	BR OUTPUT
;
; THIS BLOCK OUTPUTS PROMPT AND ENCRYPTED/DECRYPTED 
; MESSAGE, FOLLOWED BY LOOPING BACK TO START
; ALL OVER AGAIN
;
OUTPUT	PUTS
	LEA R0, MESS
	PUTS
	LD R0, NEWLINE
	OUT
	BR L1
;
; DATA VALUES USED IN THE ABOVE CODE	
;
ERES	.STRINGZ "Encrypted Message: "	
DRES	.STRINGZ "Decrypted Message: "
MESS	.BLKW #21
ASCII	.FILL #-48	
PROMPT3	.STRINGZ "Enter Message (<20 char, press <ENTER> when done): "
	.END 
