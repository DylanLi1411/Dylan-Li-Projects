;***************************************************************************
;*
;* Title: Temperature and Humidity System Extended
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/13/2022
;* Target: AVR128DB48
;*
;* DESCRIPTION
;* The program and circuit measures the temperature and humidity around it.
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************
// Create the arrays and digit_num
.dseg
	bcd_entries: .byte 4
	led_display: .byte 4
	digit_num: .byte 1

	measured_data: .byte 5

	tBCD0: .byte 1  // BCD digits 1:0
	tBCD1: .byte 1  // BCD digits 3:2
	tBCD2: .byte 1  // BCD digits 4
.cseg

	.def	tBCD0_reg = r13		;BCD value digits 1 and 0
	.def	tBCD1_reg = r14		;BCD value digits 3 and 2
	.def	tBCD2_reg = r15		;BCD value digit 4

	.def	fbinL = r16		;binary value Low byte
	.def	fbinH = r17		;binary value High byte

	.def	cnt16a	=r18		;loop counter
	.def	tmp16a	=r19		;temporary value

	.equ PERIOD_EXAMPLE_VALUE = 100

reset:
 	jmp start			;reset vector executed a power ON

.org TCA0_OVF_vect
	jmp multiplex_display      ;vector for TCA0

.org PORTE_PORT_vect
	jmp porte_isr		;vector for all PORTE pin change IRQs

start:
    // Configure all pins
    ldi r16, 0xFF       
	out VPORTD_DIR, r16       ;configure all PD pins as outputs (segments)
	out VPORTA_DIR, r16       ;configure all PA pins as outputs (digits)
	out VPORTB_DIR, r16       ;configure all PB pins as outputs (LEDs)
	ldi r16, 0x00
	cbi VPORTE_DIR, 0         ;configure PE0 as an input (pushbutton)


	// Configure interrupt for pushbutton
	lds r16, PORTE_PIN0CTRL	  ;set ISC for PE0 to pos. edge
	ori r16, 0x02             ;ISC = 2 for rising edge
	sts PORTE_PIN0CTRL, r16

	// Configure interrupt for TCA0 and multiplex display
	ldi r16, TCA_SINGLE_WGMODE_NORMAL_gc	;WGMODE normal
	sts TCA0_SINGLE_CTRLB, r16

	ldi r16, TCA_SINGLE_OVF_bm		;enable overflow interrupt
	sts TCA0_SINGLE_INTCTRL, r16

	;load period low byte then high byte
	ldi r16, LOW(PERIOD_EXAMPLE_VALUE)		;set the period
	sts TCA0_SINGLE_PER, r16
	ldi r16, HIGH(PERIOD_EXAMPLE_VALUE)
	sts TCA0_SINGLE_PER + 1, r16

	;set clock and start timer
	ldi r16, TCA_SINGLE_CLKSEL_DIV256_gc | TCA_SINGLE_ENABLE_bm
	sts TCA0_SINGLE_CTRLA, r16


	sei				          ;enable global interrupts


	// Initialize digit_num
	ldi r16, 0x00
	sts digit_num, r16

	// Initialize pointers
	ldi XH, High(led_display)        ;X for led_display
	ldi XL, Low(led_display)
	ldi YH, High(bcd_entries)        ;Y for bcd_entries
	ldi YL, Low(bcd_entries)

	// Initialize led_display array to all 1's (all digits are off in the beginning)
	ldi r16, 0xFF
	st X+, r16
	st X+, r16
	st X+, r16
	st X+, r16

	// Initialize bcd_entries with all 0's
	ldi r16, 0x00
	st Y+, r16
	st Y+, r16
	st Y+, r16
	st Y+, r16
	
	// Turn all digits off in beginning
	ldi r16, 0xF0
	out VPORTA_OUT, r16

	// Mode reset to Temperature (C)
	ldi r30, 0x01

	/*
	// Test
	ldi r30, 0x02

	// Initialize measured DATA
	ldi XH, High(measured_data)
	ldi XL, Low(measured_data)

	;Humid
	ldi r16, 0
	st X+, r16
	st X+, r16

	;Temp
	ldi r16, 30
	st X+, r16
	ldi r16, 4
	st X+, r16

	;Checksum
	ldi r16, 0
	st X, r16*/

main_loop:
	rcall send_start
	rcall wait_for_response_signal
	rcall get_measured_data

	rcall convert_measured_data		;r30 determines mode

	rcall delay_2seconds
	rjmp main_loop


;***************************************************************************
;* 
;* "multiplex_display" - Mutliplex 4 digit LED Display
;*
;* Description: Outputs the array of led_display onto
;* the 4-digit seg display
;*
;* Author: Dylan Li
;* Version: 1.1
;* Last updated: 11/13/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: led_display, digit_num
;*
;* Returns: output to the 4-digit display, digit_num is set to index
;* of the last digit that was displayed
;*
;* Notes: Now uses an interrupt from TCA0
;*
;***************************************************************************
multiplex_display:
	push r16			;save registers r16 and r17
	in r16, CPU_SREG    ;save status register
	push r16
	push r17
	push r20

	/* Main instructions for this subroutine */
	// Turn all digits off
	ldi r16, 0xF0
	out VPORTA_OUT, r16

	// Pointer goes back to start of array
	ldi XH, High(led_display)
	ldi XL, Low(led_display)

	// Display digit based on digit_num
	lds r20, digit_num        ;load r20 with digit_num value
	add XL, r20               ;pointer goes to array position
	ld r17, X                 ;get value from array position into r17
	out VPORTD_OUT, r17       ;out hex value in r17
	
	// check r20 to see which should digit turn on
	cpi r20, 0x00
	breq pos0
	cpi r20, 0x01
	breq pos1
	cpi r20, 0x02
	breq pos2
	cpi r20, 0x03
	breq pos3

pos0:
	cbi VPORTA_OUT, 4
	rjmp multiplex_done
pos1:
	cbi VPORTA_OUT, 5
	rjmp multiplex_done
pos2:
	cbi VPORTA_OUT, 6
	rjmp multiplex_done
pos3:
	cbi VPORTA_OUT, 7
	rjmp multiplex_done
	
multiplex_done:
	inc r20                   ;increase r20
	andi r20, 0x03            ;mask r20
	sts digit_num, r20        ;store r20 in digit_num

	ldi r16, TCA_SINGLE_OVF_bm	;clear OVF flag
	sts TCA0_SINGLE_INTFLAGS, r16

	pop r20
	pop r17				;restore registers
	pop r16             ;restore status register
	out CPU_SREG, r16
	pop r16

	reti



;***************************************************************************
;* 
;* "poll_digit_entry" - Mode Switch Subroutine
;*
;* Description: Polls the flag associated with the pushbutton.
;* Toggles between temperature and humidty modes
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/29/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r30 (current mode)
;*
;* Returns: r30 (next mode)
;*
;* Notes: 
;*
;***************************************************************************
poll_digit_entry:
	push r16

	ldi r16, 0x01
	add r30, r16		;add 1 to go to next mode

	cpi r30, 0x03
	brge mode_reset

	poll_digit_entry_done:
		rcall convert_measured_data

		ldi r16, PORT_INT0_bm	;clear IRQ flag for PE0
		sts PORTE_INTFLAGS, r16

		pop r16
		ret

	mode_reset:
		ldi r30, 0x00
		rjmp poll_digit_entry_done



;***************************************************************************
;*
;* "hex_to_7seg" - Hexadecimal to Seven Segment Conversion
;*
;* Description: Converts a right justified hexadecimal digit to the seven
;* segment pattern required to display it. Pattern is right justified a
;* through g. Pattern uses 0s to turn segments on ON.
;*
;* Author: Ken Short
;* Version: 0.1
;* Last updated: 100322
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r18: hex digit to be converted
;* Returns: r18: seven segment pattern. 0 turns segment ON
;*
;* Notes:
;*
;***************************************************************************
hex_to_7seg:
	push r16
	push ZH
	push ZL

	ldi ZH, HIGH(hextable * 2) ;set Z to point to start of table
	ldi ZL, LOW(hextable * 2)
	ldi r16, $00 ;add offset to Z pointer
	andi r18, 0x0F ;mask for low nibble
	add ZL, r18
	adc ZH, r16
	lpm r18, Z ;load byte from table pointed to by Z

	pop ZL
	pop ZH
	pop r16
	ret

;Table of segment values to display digits 0 - F
;seven values must be added
hextable: .db $81, $CF, $92, $86, $CC, $A4, $A0, $8F, $80, $84, $88, $E0, $B1, $C2, $B0, $B8




;***************************************************************************
;* 
;* "porte_ISR" - Interrupt subroutine
;*
;* Description: Interrupt service routine for any PORTE pin change IRQ
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 10/31/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters:
;*
;* Returns:
;*
;* Notes: 
;*
;***************************************************************************
porte_ISR:
	cli				;clear global interrupt enable, I = 0
	push r16		;save r16 then SREG, note I = 0
	in r16, CPU_SREG
	push r16

	;Determine which pins of PORTE have IRQs
	lds r16, PORTE_INTFLAGS	;check for PE0 IRQ flag set
	sbrc r16, 0
	rcall poll_digit_entry  ;execute subroutine for PE0

	pop r16			;restore SREG then r16
	out CPU_SREG, r16	;note I in SREG now = 0
	pop r16
	sei				;SREG I = 1
	reti			;return from PORTE pin change ISR
;Note: reti does not set I on an AVR128DB48

















/********************************************************************** Measured Data subroutines **********************************************************************/

;***************************************************************************
;* 
;* "convert_measured_data" - Conversion Subroutine
;*
;* Description: Reads measured_data array and convert into bcd_entries
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/29/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: measured_data, bcd_entries, led_display, r30
;*
;* Changes: bcd_entries, led_display
;*
;* Notes: measured_data should already have all values in it as 
;*        called in the main loop
;*
;***************************************************************************
convert_measured_data:
	push XH								;save in stack
	push XL
	push YH
	push YL
	push r16
	push r17
	push r18

	ldi XH, HIGH(measured_data)			;load pointer to measured_data
	ldi XL, LOW(measured_data)

	// Turn all LEDs off
	cbi VPORTB_OUT, 3
	cbi VPORTB_OUT, 4
	cbi VPORTB_OUT, 5

	// Mode Selection
	cpi r30, 0x00
	breq humidity_mode
	cpi r30, 0x01
	breq temp_c_mode
	cpi r30, 0x02
	breq temp_f_mode

	humidity_mode:
		sbi VPORTB_OUT, 5
		rjmp measured_conversion
	temp_c_mode:
		sbi VPORTB_OUT, 3
		adiw XL, 2
		brcc measured_conversion
		inc XH
		rjmp measured_conversion
	temp_f_mode:
		sbi VPORTB_OUT, 4
		adiw XL, 2
		brcc measured_conversion_f
		inc XH
		rjmp measured_conversion_f
	
	measured_conversion:
		ld r16, X+						;get high byte and move to low byte
		rcall bin2BCD16                 ;high byte converted into bcd
		rjmp store_BCD2

	measured_conversion_f:
		ld r16, X+						;get high byte and move to low byte
		ld r17, X						;store register with low byte(0-9)
		rcall Celsius_to_10Fahrenheit	;Convert Celsius to 10*Fahrenheit
		rcall bin2BCD16					;Convert 10*F(ignore decimal) to BCD
		rcall BCD_divide_by_10			;Divide BCD value by 10 to get Fahrenheit

	// Put BCD values into bcd_entries
	store_BCD:
		ldi YH, HIGH(bcd_entries)			;load pointer to bcd_entries
		ldi YL, LOW(bcd_entries)

		st Y+, r17							;digit 0
		lds r17, tBCD0						;load reg with digit 1 and 2
		andi r17, 0x0F
		st Y+, r17							;put digit 1 in bcd_entries
		lds r17, tBCD0
		lsr r17								;high nibble
		lsr r17
		lsr r17
		lsr r17
		st Y, r17							;digit 2
		rjmp convert_led_display

	store_BCD2:
		// Put BCD values into bcd_entries
		ldi YH, HIGH(bcd_entries)			;load pointer to bcd_entries
		ldi YL, LOW(bcd_entries)

		ld r21, X							;store register with low byte(0-9)
		st Y+, r21							;digit 0 and got to digit 1
		lds r21, tBCD0						;load reg with digit 1 and 2
		andi r21, 0x0F						;mask for only digit 1
		st Y+, r21							;put digit 1 in bcd_entries
		lds r21, tBCD0
		lsr r21								;high nibble
		lsr r21
		lsr r21
		lsr r21
		st Y, r21							;digit 2

	convert_led_display:
		// Reset Y and X pointer
		ldi YH, High(bcd_entries)      
		ldi YL, Low(bcd_entries)
		ldi XH, High(led_display)      
		ldi XL, Low(led_display)

		// Convert bcd_entries to led_display
		ld r18, Y+                      ;load r18 with value at Y and increment Y(post)
		call hex_to_7seg               ;convert r18 to display value
		st X+, r18                     ;put new r18 value in corresonding led_display array and increment X

		ld r18, Y+
		call hex_to_7seg
		andi r18, 0x7F					;turn on decimal point at digit 1
		st X+, r18

		ld r18, Y+
		call hex_to_7seg
		st X+, r18						;stop at digit 2

		ld r18, Y
		call hex_to_7seg
		st X, r18

	pop r18								;pop from stack
	pop r17
	pop r16
	pop YL
	pop YH
	pop XL
	pop XH
	ret

	




;***************************************************************************
;* 
;* "get_measured_data" - 
;*
;* Description: Put all bytes read from DHT11 into measured_data array
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: measured_data array
;*
;* Returns: measured_data array
;*
;* Notes: measured_data is in order of the DHT11 signals
;*
;***************************************************************************
get_measured_data:
	push XL			;save to stack
	push XH
	push r19
	push r20

	ldi XH, High(measured_data)		;pointer goes to start of array
	ldi XL, Low(measured_data)
	ldi r19, 0x05					;initialize r19

	get_measured_array:
		rcall get_byte			;get byte
		st X+, r20				;store byte in array and increment X pointer
		dec r19
		brne get_measured_array	;repeat for all 5 bytes

	pop r20			;pop from stack
	pop r19
	pop XH			
	pop XL
	ret







;***************************************************************************
;* 
;* "get_byte" - 
;*
;* Description: 
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r20
;*
;* Returns: r20 stored with read byte from DHT11
;*
;* Notes: should start from the first 50us delay from the DHT11
;*
;***************************************************************************
get_byte:
	push r16			;save to stack
	push r17

	ldi r20, 0x00		;initialize r20
	ldi r17, 0x08		;initialize r17

	read_bits:
		lsl r20					;lsb bit is DATA value read
		rcall wait_for_1_DHT11	;wait for DHT11 to output 1
		rcall delay_50us
		rcall read_DHT11		;r16 reads DATA value
		or r20, r16				;put DATA value into lsb of r20
		rcall wait_for_0_DHT11	;get ready for next bit				
		
		dec r17
		brne read_bits			;repeat for all 8 bits

	pop r17				;pop from stack
	pop r16
	ret





;***************************************************************************
;* 
;* "read_DHT11_data_bit" - 
;*
;* Description: Subroutine to read DATA line (full bit)
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r16
;* Returns: r16 carrying logic value of DATA in bit 0 (0x00 or 0x01)
;*
;* Notes: 
;*
;***************************************************************************
read_DHT11_data_bit:
	rcall wait_for_1_DHT11	;wait for DHT11 to output 1
	rcall delay_50us
	rcall read_DHT11		;r16 reads DATA value
	ret






;***************************************************************************
;* 
;* "send_start" - 
;*
;* Description: Subroutine to send start signal to DHT11
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: makes DATA a 0 for 18ms and then a 1 for 40us
;*
;***************************************************************************
send_start:
	rcall write_0_to_DHT11
	rcall delay_18ms
	rcall write_1_to_DHT11
	rcall delay_20us
	rcall delay_20us
	ret








;***************************************************************************
;* 
;* "write_0_to_DHT11" - 
;*
;* Description: causes the DATA line (pin PB0) to be 0
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/16/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters:
;*
;* Returns:
;*
;* Notes:
;*
;***************************************************************************
write_0_to_DHT11:
	sbi VPORTB_DIR, 0	;configure PB0 as output
	ret



;***************************************************************************
;* 
;* "write_1_to_DHT11" - 
;*
;* Description: causes the DATA line (pin PB0) to be 1 via the
;* the external pull-up resistor.
;* 
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/16/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters:
;*
;* Returns:
;*
;* Notes:
;*
;***************************************************************************
write_1_to_DHT11:
	cbi VPORTB_DIR, 0	;configure PB0 as input
	ret









;***************************************************************************
;* 
;* "delay_50us" - 
;*
;* Description: Wait 50 microseconds
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
delay_50us:
	push r16		;save to stack
	push r17

	ldi r16, 12		;value of r16 needed for 50us delay
	ldi r17, 4		;value of r17 needed for 50us delay
	rcall var_delay

	pop r17			;pop from stack
	pop r16
	ret



;***************************************************************************
;* 
;* "delay_18ms" - 
;*
;* Description: Wait 18 miliseconds
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
delay_18ms:
	push r16		;save to stack
	push r17

	ldi r16, 200		;value of r16 needed for 18ms delay
	ldi r17, 119		;value of r17 needed for 18ms delay
	rcall var_delay

	pop r17			;pop from stack
	pop r16
	ret



;***************************************************************************
;* 
;* "delay_20us" - 
;*
;* Description: Wait 20 microseconds
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
delay_20us:
	push r16		;save to stack
	push r17

	ldi r16, 4		;value of r16 needed for 20us delay
	ldi r17, 4		;value of r17 needed for 20us delay
	rcall var_delay

	pop r17			;pop from stack
	pop r16
	ret


;***************************************************************************
;* 
;* "delay_2seconds" - 
;*
;* Description: Wait 2 seconds
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
delay_2seconds:
	push r16		;save to stack
	push r17
	push r19

	ldi r19, 40		;initialize r19

	loop_delay:
		ldi r16, 250
		ldi r17, 250
		rcall var_delay

		dec r19
		brne loop_delay

	pop r19			;pop from stack
	pop r17
	pop r16
	ret




;***************************************************************************
;* 
;* "var_delay" - Delay
;*
;* Description: Delays the microchip before doing anything
;*
;* Author: Dylan Li
;* Version: 1.1
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r16, r17
;* Returns: Nothing
;*
;* Notes: Length of time of the delay is determined by other subroutines
;*
;***************************************************************************
var_delay:
	push r18	;save to stack
	            
	outer_loop:
		mov r18, r17
	inner_loop:
		dec r18
		brne inner_loop
		dec r16
		brne outer_loop

	pop r18		;pop from stack
	ret









/* Subroutines to read from DHT11 */

;***************************************************************************
;* 
;* "wait_for_response_signal" - 
;*
;* Description: Wait for the response signal from DHT11
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
wait_for_response_signal:
	push r16
	cbi VPORTB_DIR, 0	;configure PB0 as input

	rcall wait_for_0_DHT11	;wait for 0
	rcall wait_for_1_DHT11	;wait for 1
	rcall wait_for_0_DHT11	;wait for 0 (the start of 50us delay before DHT11 outputs first bit)

	pop r16
	ret






;***************************************************************************
;* 
;* "read_DHT11" - read_DHT11_data_bit?
;*
;* Description: Subroutine to read DATA line
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r16
;* Returns: r16 carrying logic value of DATA in bit 0 (0x00 or 0x01)
;*
;* Notes: 
;*
;***************************************************************************
read_DHT11:
	cbi VPORTB_DIR, 0	;configure PB0 as input
	in r16, VPORTB_IN	;get PORTB values
	andi r16, 0x01		;mask r16 to only get PB0
	ret







;***************************************************************************
;* 
;* "wait_for_0_DHT11" - 
;*
;* Description: Wait for the DATA line to be 0
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
wait_for_0_DHT11:
	rcall read_DHT11
	cpi r16, 0x00
	brne wait_for_0_DHT11
	ret




;***************************************************************************
;* 
;* "wait_for_1_DHT11" - 
;*
;* Description: Wait for the DATA line to be 1
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/28/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: None
;* Returns: Nothing
;*
;* Notes: 
;*
;***************************************************************************
wait_for_1_DHT11:
	rcall read_DHT11
	cpi r16, 0x01
	brne wait_for_1_DHT11
	ret




   ;***************************************************************************
;*
;* "bin2BCD16" - 16-bit Binary to BCD conversion
;*
;* This subroutine converts a 16-bit number (fbinH:fbinL) to a 5-digit
;* packed BCD number represented by 3 bytes (tBCD2:tBCD1:tBCD0).
;* MSD of the 5-digit number is placed in the lowermost nibble of tBCD2.
;*
;* Number of words	:25
;* Number of cycles	:751/768 (Min/Max)
;* Low registers used	:3 (tBCD0,tBCD1,tBCD2)
;* High registers used  :4(fbinL,fbinH,cnt16a,tmp16a)	
;* Pointers used	:Z
;*
;***************************************************************************
bin2BCD16:
    push fbinL
    push fbinH
    push cnt16a
    push tmp16a
	push r20
	push ZH
	push ZL

	ldi	cnt16a, 16	;Init loop counter	
    ldi r20, 0x00
    sts tBCD0, r20 ;clear result (3 bytes)
    sts tBCD1, r20
    sts tBCD2, r20
bBCDx_1:
    // load values from memory
    lds tBCD0_reg, tBCD0
    lds tBCD1_reg, tBCD1
    lds tBCD2_reg, tBCD2

    lsl	fbinL		;shift input value
	rol	fbinH		;through all bytes
	rol	tBCD0_reg		;
	rol	tBCD1_reg
	rol	tBCD2_reg

    sts tBCD0, tBCD0_reg
    sts tBCD1, tBCD1_reg
    sts tBCD2, tBCD2_reg

	dec	cnt16a		;decrement loop counter
	brne bBCDx_2		;if counter not zero

	pop ZL
	pop ZH
	pop r20
    pop tmp16a
    pop cnt16a
    pop fbinH
    pop fbinL
ret			; return
    bBCDx_2:
    // Z Points tBCD2 + 1, MSB of BCD result + 1
    ldi ZL, LOW(tBCD2 + 1)
    ldi ZH, HIGH(tBCD2 + 1)
    bBCDx_3:
	    ld tmp16a, -Z	    ;get (Z) with pre-decrement
	    subi tmp16a, -$03	;add 0x03

	    sbrc tmp16a, 3      ;if bit 3 not clear
	    st Z, tmp16a	    ;store back

	    ld tmp16a, Z	;get (Z)
	    subi tmp16a, -$30	;add 0x30

	    sbrc tmp16a, 7	;if bit 7 not clear
        st Z, tmp16a	;	store back

	    cpi	ZL, LOW(tBCD0)	;done all three?
    brne bBCDx_3
        cpi	ZH, HIGH(tBCD0)	;done all three?
    brne bBCDx_3
rjmp bBCDx_1




;***************************************************************************
;* 
;* "Celsius_to_10Fahrenheit" - Conversion Subroutine
;*
;* Description: Convert Celsius in binary to 10*Fahrenheit
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/29/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: r16 - High byte in Celsius
;*             r17 - Low byte in Celsius(decimal)
;*
;* Returns: r17 - High Byte of 10*Fahrenheit
;*          r16 - Low Byte of 10*Fahrenheit
;*
;* Notes: Fahrenheit is multiplied by 10 in binary and does not include decimal
;*
;***************************************************************************
Celsius_to_10Fahrenheit:
	push r18				;save to stack
	push r19
	push r20				
	push r21
	push r22
	push r24
	push r25
	push r26
	push r27
	push r28

	mov r22, r17			;10*F decimal byte
	mov r20, r16			;10*F low byte
	ldi r21, 0x00			;10*F high byte


	ldi r18, 0x00			;for carry check
	ldi r19, 18			;multiplier
	ldi r28, 0x01			;for increment

	mul r20, r19			;multiply low byte
	movw r20, r0			;move product back to r21:r20
	
	mul r22, r19			;multiply decimal byte
	movw r26, r0			;move product to r27:r26

	compare_decimal:
		clc
		cpi r27, 0x01
		brge Add_decimal
		cpi r26, 0x0A
		brge Add_decimal

	Add_320:
		ldi r19, 255
		add r20, r19
		adc r21, r18
		ldi r19, 65
		add r20, r19
		adc r21, r18


	mov r17, r21			;10*F bytes copied to r17 and r16
	mov r16, r20

	pop r28
	pop r27
	pop r26
	pop r25
	pop r24
	pop r22
	pop r21					
	pop r20	
	pop r19
	pop r18					;pop from stack
	ret

	Add_decimal:			;continusly add carries until decimal byte(s) is less than 10
		add r20, r28
		adc r21, r18
		sbiw r26, 10
		rjmp compare_decimal



;***************************************************************************
;* 
;* "BCD_divide_by_10" - 
;*
;* Description: Divide BCD by 10
;*
;* Author: Dylan Li
;* Version: 1.0
;* Last updated: 11/29/2022
;* Target: AVR128DB48
;* Number of words:
;* Number of cycles:
;* Low registers modified:
;* High registers modified:
;*
;* Parameters: BCD variables (tBCD0, tBCD1, tBCD2), r17
;*
;* Returns: r17, BCD variables
;*
;* Notes: specific for r17
;*
;***************************************************************************
BCD_divide_by_10:
	push r16
	push r18

	lds r16, tBCD0		
	mov r18, r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16	
	lds r17, tBCD1
	andi r17, 0x0F		;get digit 2
	swap r17
	or r16, r17			;combine
	sts tBCD0, r16		;tBCD0 done

	lds r16, tBCD1
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	lds r17, tBCD2
	andi r17, 0x0F
	swap r17
	or r16, r17
	sts tBCD1, r16		;tBCD1 done
	
	ldi r16, 0x00
	sts tBCD2, r16		;tBCD2 done


	andi r18, 0x0F
	mov r17, r18

	pop r18
	pop r16
	ret