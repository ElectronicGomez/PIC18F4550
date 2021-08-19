#include <p18f4550.inc>	;Llamamos a la libreria de nombre de los registros
    
;Aquí incluímos los bits de configuración que lo sacamos del asistonto
 CONFIG  FOSC = XT_XT    ; Oscillator Selection bits (Internal oscillator, port function on RA6, EC used by USB (INTIO))
 CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
 CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
 CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
 CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
 CONFIG  MCLRE = ON
 CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)

tecla EQU 0x20
letras EQU 0x21			;ME INDICA EL NUMERO DE DIGITOS QUE HE ESCRITO
CIFRA EQU 0x22			;aqui guardo el valor digitado por el teclado
value EQU 0x23
num1 EQU 0x24
num2 EQU 0x25
producto EQU 0x2E
pro2 EQU 0x2F
val1 EQU 0x30
val2 EQU 0x31
contador EQU 0x32
ascii EQU 0x33
unidad EQU 0x34
decena EQU 0X35
 org 0x000
    goto MAIN
 org 0x008
    goto RUT_INT
 org 0x600
MENSAJE1: da "MULT:"
 org 0x640
MAIN:
    movlw b'00001000'
    movwf TRISD
    movlw b'11110000'
    movwf TRISB
    clrf  LATB
    bcf   INTCON2,RBPU
    clrf  TBLPTRU
    movlw HIGH MENSAJE1
    movwf TBLPTRH
    movlw LOW MENSAJE1
    movwf TBLPTRL
    call  DELAY15MSEG
    call  LCD_CONFIG
    call  BORRAR_LCD
    clrf value 
    clrf letras
    clrf num1
    clrf num2
    clrf contador
    clrf producto
    movlw .48
    movwf ascii
    movlw b'00001010'
    movwf T1CON
    bsf   INTCON,RBIE
    ;bsf   PIE1,TMR1IE
    bsf   INTCON,PEIE
    ;bsf   INTCON,GIE
    ;bsf   T1CON,TMR1ON
    ;bsf   ADCON0,ADON
    call CURSOR_ON
IMPRIME1:
    TBLRD*+
    movlw 0xFF
    subwf TABLAT,W
    btfsc STATUS,Z
    goto  INICIO
    movlw 0x00
    subwf TABLAT,W
    btfsc STATUS,Z
    goto  INICIO
    movf  TABLAT,W
    call  ENVIA_CHAR
    goto  IMPRIME1
INICIO:
    bsf   INTCON,GIE
INICIO2:    
    goto INICIO2
RUT_INT:
    btfss PORTB,4
    goto COL1
    btfss PORTB,5
    goto COL2
    btfss PORTB,6
    goto COL3
    btfss PORTB,7
    goto COL4
    bcf  INTCON,RBIF
    retfie
COL1:
    movlw 0x0F
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0
    movlw '1'
    btfss PORTB,1
    movlw '4';4
    btfss PORTB,2
    movlw '7';7
    btfss PORTB,3
    movlw '*'
    movwf CIFRA
    movlw .0
    cpfseq contador
    goto cambio
    movff CIFRA,num1
    incf contador
    movlw .2
    cpfslt letras
    goto SALIR_B
    incf letras
    movf CIFRA, W
    call ENVIA_CHAR
    goto SALIR_B
COL2:
    movlw 0x0F
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0
    movlw '2';2
    btfss PORTB,1
    movlw '5';5
    btfss PORTB,2
    movlw '8';8
    btfss PORTB,3
    movlw '0';0
    movwf CIFRA
    movlw .0
    cpfseq contador
    goto cambio
    movff CIFRA,num1
    incf contador
    movlw .2
    cpfslt letras
    goto SALIR_B
    incf letras
    movf CIFRA, W
    call ENVIA_CHAR
    goto SALIR_B
COL3:
    movlw 0x0F
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0
    movlw '3';3
    btfss PORTB,1
    movlw '6';6
    btfss PORTB,2
    movlw '9';9
    btfss PORTB,3
    movlw '#'
    movwf CIFRA
    movlw .0
    cpfseq contador
    goto cambio
    movff CIFRA,num1
    incf contador
    movlw .2
    cpfslt letras
    goto SALIR_B
    incf letras
    movf CIFRA, W
    call ENVIA_CHAR
    goto SALIR_B
COL4:
    movlw b'00001111'		;0x0F
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0
    goto BORRAR_CARACTER 
    btfss PORTB,1
    movlw 'B'
    btfss PORTB,2
    movlw 'C'
    btfss PORTB,3
    goto multiplicar 
    movwf CIFRA
    movlw .0
    cpfseq contador
    goto cambio
    movff CIFRA,num1
    incf contador
    movlw .2
    cpfslt letras
    goto SALIR_B
    incf letras
    movf CIFRA, W
    call ENVIA_CHAR
    goto SALIR_B		
cambio:
    movff CIFRA,num2
    movlw .2
    cpfslt letras
    goto SALIR_B
    incf letras
    movf CIFRA, W
    call ENVIA_CHAR
    goto SALIR_B
multiplicar:
    movf ascii, W
    subwf num1, W
    movwf num1
    movf ascii, W
    subwf num2,W
    movwf num2
    movf num2, W
    mulwf num1; MULTIPLICA
    movf PRODL,W
    movwf producto
    movlw .5
    call POS_CUR_FIL2
    movf producto, W
    call BIN_BCD
    movf BCD1, W
    movwf decena
    movf ascii, W
    addwf decena,W
    call ENVIA_CHAR
    movf BCD0, W
    movwf unidad
    movf ascii, W
    addwf unidad, W
    call ENVIA_CHAR
    goto SALIR_B
SALIR_B:
    call RETARDO200MS
    movlw b'11110000'
    movwf TRISB
    clrf  LATB
    retfie

BORRAR_CARACTER:
    decf letras
    movlw .5
    addwf letras,W
    call POS_CUR_FIL1
    movlw " "
    call ENVIA_CHAR
    movlw .5
    addwf letras,W
    call POS_CUR_FIL1
    goto SALIR_B
RETARDO200MS:
    movlw .250
    movwf 0x30
RET1:
    movlw .100
    movwf 0x31
RET2:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz 0x31,f
    goto RET2
    decfsz 0x30,f
    goto RET1
    return
  #include "LCD_LIB.asm"
 END
