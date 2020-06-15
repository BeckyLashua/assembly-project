TITLE  Designing low-level I/O procedures   (Project6.asm)

; Author: Rebecca Lashua
; Last Modified: 6/10/2020
; OSU email address: lashuar@oregonstate.edu
; Course number/section: CS271
; Project Number:  #6             Due Date: 6/7/2020
; Description: This program displays the program and programmer
; information to the user, gives instructions to enter 10 32-bit signed
; ints, prompts the user for each integer, validating the input and 
; displaying an error and reprompting when the input is invalid. It saves
; these values in an array of integers, calculates and displays the sum
; and average results. All conversions between string and numeric are 
; achieved by using my own readInt and writeInt procedures. All strings
; are read and displayed by using my own getString and displayString 
; macros. 
;
; NOTE: All parameters are passed on the stack for the procedure calls.

INCLUDE Irvine32.inc

ARRAYSIZE = 10

;------------------------------------------------
; getString macro  prompt:req, inputAdd:req, 
;				   size:req, buffer:req
;
; Displays a prompt, then gets the user’s keyboard 
; input into a memory location. 
;
; preconditions: None. 
;
; postconditions: none.  
;
; receives:
;  prompt   = @ of prompt message
;  inputAdd = @ of memory location to store string
;  size     = length of bytes allocated for memory.
;  buffer   = @ of variabel to store byte count. 
;		
; returns: Updates the global variable numStr with
; a string from the user. 
;------------------------------------------------
getString	MACRO	prompt, inputAdd, size, buffer
	push	edx				; save registers
	push	ecx
	push	eax

	displayString prompt
	
	mov		edx, inputAdd	; get user input
	mov		ecx, size - 1	; need to account for 0-byte str
	call	ReadString
	mov		ecx, [buffer]	; store str length in memory
	mov		[ecx], eax

	pop		eax				; restore registers
	pop		ecx
	pop		edx
ENDM 


;------------------------------------------------
; displayString macro  strAdd:req
;
; Prints the string which is stored in a specified 
; memory location
;
; preconditions: none. 
;
; postconditions: none.  
;
; receives:
;  strAdd  = @ string to print to screen. 
;		
; returns: none.  
;------------------------------------------------
displayString	MACRO	strAdd
	push	edx
	
	mov		edx, strAdd
	call	WriteString

	pop		edx
ENDM


.data

; introduction procedure params
programName		BYTE	"Program 6: Designing low-level I/O procedures", 0
writtenBy		BYTE	"Written by: ", 0
programmer		BYTE	"Rebecca M. Lashua", 0
instruction1	BYTE	"Please provide 10 signed decimal integers.", 0
instruction2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruction3	BYTE	"After you have finished inputting the raw numbers I will display a list", 0
instruction4	BYTE	"of the integers, their sum, and their average value. ", 0

; farewell procedure param
thanks			BYTE	"Thanks for playing!", 0

; writeVal and readVal variables
enterNumber		BYTE	"Please enter a signed number: ", 0
numStr			BYTE	11 DUP(?)				; limit of a 32-bit signed int plus zero byte
numInt			SDWORD	?
byteCount		DWORD	?
errMsg			BYTE	"ERROR: You did not enter an signed number or number is too big.", 0
isNegative		DWORD	0
isValid			DWORD	?
negative		BYTE	"-", 0
numOfDigits		DWORD	?

; array variables
inputArray		SDWORD	ARRAYSIZE	DUP(?)
youEntered		BYTE	"You entered the following numbers: ", 0
comma			BYTE	",  ", 0

; result params 
sumPrompt		BYTE	"The sum of these numbers is: ", 0
sum				SDWORD	0
avgPrompt		BYTE	"The rounded average is: ", 0
average			SDWORD	?

	
.code
main PROC

; set up parameters for introduction call
push	OFFSET instruction4
push	OFFSET instruction3
push	OFFSET instruction2
push	OFFSET instruction1
push	OFFSET programmer
push	OFFSET writtenBy
push	OFFSET programName
call	introduction

; set up parameters for filling arr with user input
push	OFFSET byteCount
push	OFFSET errMsg
push	OFFSET isValid
push	OFFSET isNegative
push	OFFSET numInt
push	LENGTHOF numStr
push	OFFSET numStr
push	OFFSET enterNumber
push	ARRAYSIZE
push	OFFSET inputArray
call	fillArray

; set up params for displaying array afterwards
push	OFFSET numStr
push	OFFSET numOfDigits
push	OFFSET negative
push	OFFSET comma
push	OFFSET youEntered
push	OFFSET inputArray
push	LENGTHOF inputArray
call	displayArray

; set up params for calculating sum 
push	OFFSET	sum
push	OFFSET	inputArray
push	ARRAYSIZE
call	calculateSum

; set up params for displaying sum result
push	OFFSET numStr
push	OFFSET numOfDigits
push	OFFSET negative
push	OFFSET sumPrompt
push	OFFSET sum
call	displayResult

; set up params for calculating average
push	OFFSET average
push	OFFSET sum
push	ARRAYSIZE
call	calculateAvg

; set up params for displaying average result
push	OFFSET numStr
push	OFFSET numOfDigits
push	OFFSET negative
push	OFFSET avgPrompt
push	OFFSET average
call	displayResult

; set up paramaters for farewell call
push	OFFSET thanks
call	farewell

main ENDP

;------------------------------------------------
; readVal proc 
;
; Uses the getString macro to get the user’s string of 
; digits and then converts the digit string to numeric, 
; while validating the user’s input. 
;
; preconditions: None. 
;
; postconditions: none.  
;
; receives:
; [ebp+36] = @ byte count var
; [ebp+32] = @ error message string
; [ebp+28] = @ isValid boolean variable
; [ebp+24] = @ isNegative boolean variable
; [ebp+20] = @ var that will hold converted num
; [ebp+16] = LENGTHOF numStr
; [ebp+12] = @ string to be converted
; [ebp+8] = @ of prompt string
;		
; returns: Updates the global var numStr that will
; hold the number string that the user inputs. 
;------------------------------------------------
ReadVal		PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi
	
restoreVals:
	; restore numInt to 0
	mov		ecx, 0
	mov		ebx, [ebp+20]	; @ numInt
	mov		[ebx], ecx		

	; restore isNegative to 0
	mov		ecx, 0
	mov		ebx, [ebp+24]	; @ isNegative
	mov		[ebx], ecx		
	
getInput:							
	; Retrieve input from user until valid
	getString [ebp+8], [ebp+12],[ebp+16], [ebp+36]
	
convertNum:	
	push	[ebp+28]		; @ isValid
	push	[ebp+24]		; @ isNegative
	push	[ebp+20]		; @ numInt
	push	[ebp+12]		; @ numStr
	push	[ebp+36]		; str byte count
	call	convertStrToNum

validate:
	push	ebx
	mov		ebx, [ebp+28]	; @ isValid
	mov		ebx, [ebx]
	cmp		ebx, 0			; is it invalid?
	je		notValidInput
	jmp		isValidInput

notValidInput:
	pop		ebx
	displayString [ebp+32]  ; @ err message
	call	CrLf
	jmp		getInput

isValidInput:
	pop		ebx
	
	pop		esi				; restore registers
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		32
ReadVal		ENDP


;------------------------------------------------
; convertStrToNum proc 
;
; Converts a string to a 32-bit signed integer.  
;
; preconditions: The item to convert must be
; a string. Will return error if non-digits are
; found or if the number is larger than a 32-bit 
; signed integer. 
;
; postconditions: Changes the global variables isValid,
; isNegative.  It also clears the global variable numStr
; for the next procedure call. 
;
; receives:
; [ebp+24] = @ of boolean variable isValid
; [ebp+20] = @ of boolean variable isNegative
; [ebp+16] = @ of var that holds integer value
; [ebp+12] = @ string to be converted
; [ebp+8] = @ of byte count of string
;		
; returns: Returns the converted number in the 
; global variabel numInt. 
;------------------------------------------------
convertStrToNum		PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	ebx
	push	ecx
	push	edx
	push	esi

	mov		eax, 0
	mov		edx, 0			; accumulator
	mov		ebx, 10			; multiplier
	mov		ecx, [ebp+8]	; loop counter is byte count
	mov		ecx, [ecx]
	mov		esi, [ebp+12]	; @ inputStr

	cld						; direction = forward

	; Do-while loop. First check the first byte
	lodsb
	cmp		al, 2Dh			; is it a neg sign?
	je		hasNegSign
	cmp		al, 2Bh			; is it a pos sign?
	je		hasPosSign
	jmp		processByte		; else, process as usual

convert:
	lodsb					; load in byte

processByte:
	imul	edx, 10
	sub		al, 48			; get ASCII value

validateDigits:
	cmp		al, 0			; is it less than "0"
	jl		notValid		; no? then not valid
	cmp		al, 9			; is it more than "9"
	jg		notValid		; no? then not valid
	add		edx, eax		; add to accumulator
	loop	convert
	jmp		doneConverting

hasNegSign:
	push	ebx				; set isNegative to 1
	push	ecx
	mov		ecx, 1
	mov		ebx, [ebp+20]	; @ is Negative
	mov		[ebx], ecx		
	pop		ecx
	pop		ebx
	loop	convert			; skip over negative sign

hasPosSign:
	loop	convert			; skip over positive sign

doneConverting:
	; negate num if negative
	mov		ebx, [ebp+20]	; @ isNegative
	mov		ebx, [ebx]
	cmp		ebx, 1			; is it negative?
	je		negate

store:
	; store num in numInt 
	mov		esi, [ebp+16]	; store integer in memory
	mov		[esi], edx
	jmp		valid

negate:
	NEG		edx				; turn into neg num before store
	jmp		store

notValid:
	push	ebx				; set isValid to false
	push	ecx
	mov		ecx, 0
	mov		ebx, [ebp+24]   ; @ isValid
	mov		[ebx], ecx		
	pop		ecx
	pop		ebx
	jmp		endOfProcess

valid:
	push	ebx				; set isValid to true
	push	ecx
	mov		ecx, 1
	mov		ebx, [ebp+24]   ; @ isValid
	mov		[ebx], ecx		
	pop		ecx
	pop		ebx

endOfProcess:
	; restore number string 	
	mov		edi, [ebp+12]	; point to @ numStr 
	mov		ecx, [ebp+8]	; get bytecount
	mov		ecx, [ecx]
	add		edi, ecx
	dec		edi

	std						; direction = backward
delete:
	mov		al, 0				
	stosb
	loop	delete

	; restore byteCount to 0
	push	ebx
	push	ecx
	mov		ecx, 0
	mov		ebx, [ebp+8]
	mov		[ebx], ecx
	pop		ecx
	pop		ebx


	pop		esi				; restore registers 
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax				

	pop		ebp
	ret		20
convertStrToNum		ENDP


;------------------------------------------------
; fillArray proc 
;
; Prompts the user to enter 32-bit signed integers
; and adds them to an input array. 
;
; preconditions: none.
;
; postconditions: none. 
;
; receives:
; [ebp+44] = @ byte count var
; [ebp+40] = @ error message string
; [ebp+36] = @ boolen var isValid
; [ebp+32] = @ boolean var isNegative
; [ebp+28] = @ numInt variable 
; [ebp+24] = @ LENGTHOF number string
; [ebp+20] = @ number string
; [ebp+16] = @ enter number prompt
; [ebp+12] = ARRAYSIZE
; [ebp+8] = @ input array
;		
; returns: Returns all of the valid integers the
; user entered in the input array. 
;------------------------------------------------
fillArray		PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	edi
	push	ecx
	
	mov		edi, [ebp+8]	; inputArray @
	mov		ecx, [ebp+12]	; ARRAYSIZE
	
getData:
	push	[ebp+44]		; @ byteCount
	push	[ebp+40]		; @ err msg
	push	[ebp+36]		; @ isValid
	push	[ebp+32]		; @ isNegative
	push	[ebp+28]		; @ numInt
	push	[ebp+24]		; LENGTHOF numStr
	push	[ebp+20]		; @ numStr
	push	[ebp+16]		; @ prompt
	call	ReadVal

	; store value retrieved
	mov		eax, [ebp+28]
	mov		eax, [eax]
	mov		[edi], eax
	add		edi, 4
	loop	getData
	call	CrLf

	pop		ecx				; restore registers
	pop		edi
	pop		eax

	pop		ebp
	ret		40
fillArray		ENDP


;------------------------------------------------
; writeVal proc 
;
; Converts a numeric value to a string of digits, 
; and prints the output. 
;
; preconditions: A 32-bit signed integer must be
; passed on the stack. 
;
; postconditions: None.  
;
; receives:
; [ebp+20] = @ number string
; [ebp+16] = @ of var that holds num of digits
; [ebp+12] = @ of "-"			
; [ebp+8]  = integer to be printed			
;		
; returns: Updates the global variable that holds
; the number string with the result of converting
; the number to a string before printing. It also
; updates numOfDigits variable. 
;------------------------------------------------
writeVal	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	ebx
	push	ecx
	push	edx
	push	edi

	; test for negative case
	mov		eax, [ebp+8]
	test	eax, eax		; is num negative?
	js		isNegativeNum	; if so add sign
	jmp		convertNum

isNegativeNum:
	displayString  [ebp+12]	; "-"
	NEG		eax				; get absolute val of int

convertNum:
	; retreive num of digits
	push	[ebp+16]		; @ num of digits mem
	push	eax				; value of int
	call	getNumOfDigits	

	; save num of digits in ecx
	mov		ecx, [ebp+16]		
	mov		ecx, [ecx]

	; convert num to str
	push	ecx				; num of digits
	push	[ebp+20]		; @ output str
	push	eax				; value of int
	call	convertNumToStr

	; display converted str
	displayString [ebp+20]

	; restore str var
	mov		edi, [ebp+20]	; point to @ array again
	add		edi, ecx
	dec		edi				

	std						; direction = backward
delete:
	mov		al, 0				
	stosb
	loop	delete

	pop		edi				; restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		16
writeVal	ENDP


;------------------------------------------------
; getNumOfDigits proc 
;
; Calculates and returns the number of digits in 
; a 32-bit signed integer. 
;
; preconditions: A 32-bit signed integer must be
; passed on the stack. 
;
; postconditions: None.  
;
; receives:
; [ebp+12] = @ of the numOfDigits variable
; [ebp+8]  = value of int we need num of digits on
;
; returns: Returns the number of digits in the
; global variable numOfDigits.
;------------------------------------------------
getNumOfDigits	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	ebx
	push	ecx
	push	edx

	mov		eax, [ebp+8]	; num we are operating on
	mov		ecx, 0			; accumulator

getDigits:	
	mov		ebx, 10
	cdq
	div		ebx

	cmp		eax, 0			; is eax 0?
	je		doneGetting		; yes? move on
	inc		ecx				; no? increment num of digits
	jmp		getDigits

doneGetting:
	add		ecx, 1
	mov		ebx, [ebp+12]
	mov		[ebx], ecx		; store num of digits in mem		

	pop		edx				; restore registers
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		8
getNumOfDigits	ENDP


;------------------------------------------------
; convertNumToStr proc 
;
; Converts a 32-bit signed integer into a string.  
;
; preconditions: The number being converted must 
; be a 32-bit signed integer. 
;
; postconditions: None.  
;
; receives:
; [ebp+16] = the num of digits the number has 
; [ebp+12] = @ of the output string variable 
; [ebp+8]  = value of int to be converted
;
; returns: Returns the converted string in the
; global variable numInt. 
;------------------------------------------------
convertNumToStr		PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	ebx
	push	edx
	push	edi

	mov		edi, [ebp+12]	; @ output string
	add		edi, [ebp+16]	; need to write at end of string
	dec		edi
	mov		eax, [ebp+8]	; storing int to convert

	std						; direction = backward

convert:
	mov		ebx, 10			; divider
	cdq
	div		ebx
	add		edx, 48			; get ASCII char 
	
	push	eax
	mov		eax, edx		; store ASCII value
	stosb					; store byte 
	pop		eax

	cmp		eax, 0			; jump out if done
	je		doneConverting
	jmp		convert

doneConverting:
	pop		edi				; restore registers
	pop		edx
	pop		ebx
	pop		eax

	pop		ebp
	ret		12
convertNumToStr		ENDP


;------------------------------------------------
; calculateAvg proc 
;
; Calculates the average of signed 32-bit integers. 
;
; preconditions: The sum and size variables passed in
; must be 32-bit signed integers. 
;
; postconditions: None.  
;
; receives:
; [ebp+16] = @ of the average variable. 
; [ebp+12] = @ of the sum variable. 
; [ebp+8]  = ARRAYSIZE
;
; returns: The avg of the array, stored in the 
; global variable average. 
;------------------------------------------------
calculateAvg	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save registers
	push	ebx
	push	edx
	push	esi

	mov		eax, [ebp+12]	; store sum in eax
	mov		eax, [eax]
	mov		ebx, [ebp+8]	; store array size in ebx
	cdq
	idiv	ebx

	mov		esi, [ebp+16]	; store result in average var 
	mov		[esi], eax

	pop		esi				; restore registers
	pop		edx
	pop		ebx
	pop		eax

	pop		ebp
	ret		12
calculateAvg	ENDP


;------------------------------------------------
; calculateSum proc 
;
; Calculates the sum of the values of an array 
; comprised of 32-bit signed integers. 
;
; preconditions: The array address passed in must
; point to an array of 32-bit signed integers. 
;
; postconditions: None.  
;
; receives:
; [ebp+16] = @ of the sum variable
; [ebp+12] = @ of the input array
; [ebp+8]  = ARRAYSIZE
;
; returns: The sum of the array, stored in the 
; global variable sum. 
;------------------------------------------------
calculateSum	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp
	
	push	eax				; save registers
	push	ecx
	push	esi

	mov		esi, [ebp+12]	; esi points to @array
	mov		ecx, [ebp+8]	; loop counter is size of array
	mov		eax, 0			; accumulator

addNum:
	add		eax, [esi]		; add integer to accumulator
	add		esi, 4			; increment to next element
	loop	addNum
	
	mov		esi, [ebp+16]	; store result in sum
	mov		[esi], eax

	pop		esi				; restore registers
	pop		ecx
	pop		eax
	
	pop		ebp				
	ret		12
calculateSum	ENDP


;------------------------------------------------
; displayArray proc 
;
; Display the elements in an int array that holds unsigned
; 32-bit integers. 
;
; preconditions: The array must hold 32-bit signed integers. 
;
; postconditions: none.  
;
; receives:
; [ebp+32] = @ number string variable
; [ebp+28] = @ num of digits variable
; [ebp+24] = @ of "-"
; [ebp+20] = @ of comma string
; [ebp+16] = @ of list description
; [ebp+12] = @ of array
; [ebp+8] = LENGTHOF array
;
; returns: nothing. 
;------------------------------------------------
displayArray	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	edx
	push	ecx
	push	esi
	
	mov		esi, [ebp+12]	; @ list
	mov		ecx, [ebp+8]	; store array size in counter

	displayString [ebp+16]	; description of array
	call	CrLf

writeElement:
	mov		eax, [esi]		; write current element in arr
	
	; write val to screen	
	push	[ebp+32]		; @ numStr
	push	[ebp+28]		; @ num of digits
	push	[ebp+24]		; @ "-"
	push	eax					
	call	writeVal
	
	add		esi, 4			; move to next arr element
	cmp		ecx, 1			; check to see if end of array
	jne		writeComma		; if not, write comma
	loop	writeElement
	jmp		doneWriting

writeComma:
	displayString [ebp+20]			
	loop	writeElement

doneWriting:
	call	CrLf

	pop		esi				; restore registers
	pop		ecx
	pop		edx
	pop		ebp
	ret		28
displayArray	ENDP


;------------------------------------------------
; displayResult proc 
;
; Displays result of a 32-bit integer to user.  
;
; preconditions: integer passed in is 32-bit signed
; int.
;
; postconditions: None.  
;
; receives:
; [ebp+24] = @ of var that holds number string 
; [ebp+20] = @ of var that holds num of digits
; [ebp+16] = @ "-"
; [ebp+12] = @ of description of result
; [ebp+8]  = @ of var that holds sum
;
; returns: None. 
;------------------------------------------------
displayResult	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp

	push	eax				; save register

	call	CrLf
	displayString [ebp+12]	; "The [result] is: "
	mov		eax, [ebp+8]	; result numInt pushed
	mov		eax, [eax]
	
	; display result
	push	[ebp+24]
	push	[ebp+20]
	push	[ebp+16]
	push	eax					
	call	writeVal

	pop		eax				; restore register
	pop		ebp
	ret		20
displayResult	ENDP


;------------------------------------------------
; introduction proc 
;
; Displays title, program name and programmer name,
; and introduction to user. 
;
; preconditions: none. 
;
; postconditions: none.  
;
; receives:
; [ebp+32] = @ instruction4
; [ebp+28] = @ instruction3
; [ebp+24] = @ instruction2
; [ebp+20] = @ instruction1
; [ebp+16] = @ programmer
; [ebp+12] = @ writtenBy
; [ebp+8]  = @ programName
;
; returns: nothing. 
;------------------------------------------------
introduction	PROC
	push	ebp				; set up stack frame
	mov		ebp, esp
	
	; program name
	displayString [ebp+8]
	call	Crlf

	; progammer info
	displayString [ebp+12]
	displayString [ebp+16]

	call	Crlf
	call	CrLf

	; instructions
	displayString [ebp+20]
	call	CrLf
	displayString [ebp+24]
	call	CrLf
	displayString [ebp+28]
	call	CrLf
	displayString [ebp+32]

	call	CrLf
	call	CrLf

	pop		ebp
	ret		28
introduction	ENDP


;------------------------------------------------
; farewell proc 
;
; Displays farwell message to user. 
;
; preconditions: none. 
;
; postconditions: none.  
;
; receives:
; [ebp+8]  = @ thanks
;
; returns: nothing. 
;------------------------------------------------
farewell		PROC
	push	ebp				; set up stack frame
	mov		ebp, esp
	
	call	CrLf
	call	CrLf
	displayString [ebp+8]	; farewell message
	call	Crlf
	
	pop		ebp
	ret		4
farewell		ENDP


END main



