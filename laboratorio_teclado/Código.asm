#include <p18f4550.inc>	;Llamamos a la libreria de nombre de los registros
;Aqu? inclu?mos los bits de configuraci?n que lo sacamos del asistonto
    CONFIG  FOSC = XT_XT    ; Oscillator Selection bits (Internal oscillator, port function on RA6, EC used by USB (INTIO))
    CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
    CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
    CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
    CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
    CONFIG  MCLRE  = ON
    CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
    
 CBLOCK 0x10
    aux1 
    aux2 
    aux3
    cont_int
    cont_d
    cont1 
    cont2
    cont3
    cont4
    uni 
    dece 
    cent
    mil
 ENDC
    
    org 0x00
	goto main
    org 0x008
	goto RUT_INT
    org 0x020
TABLA: db 0x40,0x79,0x24,0x30,0x19,0x12,0x02,0x78,0x00,0x18
    org 0x040
    
main:
    movlw b'10000000'
    movwf TRISD
    clrf LATD
    movlw b'11110000'
    movwf TRISB
    clrf LATB
    movlw b'11110000'
    movwf TRISA
    clrf  LATA
    movlw UPPER TABLA
    movwf TBLPTRU
    movlw HIGH TABLA
    movwf TBLPTRH
    movlw LOW TABLA
    movwf TBLPTRL
    
    clrf  uni	    ;crea valores de los display
    clrf  dece
    clrf cent
    clrf mil
    
    clrf cont1	    ;contadores para el cambio de ...
    clrf cont2
    clrf cont_int
    
    bcf   INTCON2,RBPU	    ;HABILITA RES´S
    bsf   INTCON,RBIE
    movlw b'01000001'
    movwf T0CON
    bsf   INTCON,TMR0IE
    bsf   INTCON,GIE
    bsf   T0CON,TMR0ON	    ;esta wea apagada el timer0
fin:
    goto fin
    
RUT_INT:
    btfsc INTCON,TMR0IF
    goto conteo
    btfss PORTB,7
    goto  COL4
    btfss PORTB,6
    goto  COL3
    btfss PORTB,5
    goto  COL2
    btfss PORTB,4
    goto  COL1
    retfie
    
    
conteo:
    bcf INTCON,TMR0IF
    incf cont_int   
    movlw .9
    cpfseq cont_int
    retfie
    clrf cont_int
    call DISP1
    call DISP2
    call DISP3
    call DISP4
   
    incf  uni
    movlw .10
    cpfseq uni
    retfie
    
    incf   dece
    clrf   uni
    movlw  .6
    cpfseq dece
    retfie
    
    incf  cent
    clrf dece
    movlw .10
    cpfseq cent
    retfie
    
    incf   mil
    clrf   cent
    movlw  .6
    cpfseq mil
    retfie

DISP1:
    clrf  LATA
    bsf   LATA,0
    movlw LOW TABLA
    addwf uni,W
    movwf TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    call retardo
    return
    
DISP2:
    clrf  LATA
    bsf   LATA,1
    movlw LOW TABLA
    addwf dece,W
    movwf TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    call retardo
    return
    
    
DISP3:
    clrf  LATA
    bsf   LATA,2
    movlw LOW TABLA
    addwf cent,W
    movwf TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    call retardo
    return
    
    
DISP4:
    clrf  LATA
    bsf   LATA,3
    movlw LOW TABLA
    addwf mil,W
    movwf TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    call retardo
    return
COL1:
    movlw b'00001111'
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0	    ;BOTON 1
    retfie		    ;ASCENDENTE
    btfss PORTB,1	    ;BOTON 4
    retfie		    ;goto DESCIENDE
    btfss PORTB,2	    ;BOTON 7
    retfie		    ;aca se puede hacer otra wea
    btfss PORTB,3	    ;BOTON *
    retfie		    ;aca se puede hacer otra wea	    
    retfie		    ;es ambiguo
COL2:
    movlw b'00001111'
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0	    ;BOTON 2
    goto PARA
    btfss PORTB,1	    ;BOTON 5
    retfie		    ;goto ACELERA
    btfss PORTB,2	    ;BOTON 8
    retfie		    ;aca se puede hacer otra wea
    btfss PORTB,3	    ;BOTON 0
    retfie		    ;aca se puede hacer otra wea
    retfie
COL3:
    movlw b'00001111'
    movwf TRISB
    clrf  LATB
    nop 
    nop
    btfss PORTB,0	    ;BOTON 3
    goto CONTINUA
    btfss PORTB,1	    ;BOTON 6
    retfie		    ;goto DESACELERA
    btfss PORTB,2	    ;BOTON 9
    retfie		    ;aca se puede hacer algo
    btfss PORTB,2	    ;BOTON #
    retfie
    retfie
COL4:
    retfie
    
retardo:
    movlw .2
    movwf aux3
RET3:
    movlw .2
    movwf aux1
RET2:
    movlw .1
    movwf aux1
RET1:
    nop ;1 us de retardo 
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz aux1,f ;decrece de 1 en 1 
    goto RET1
    decfsz aux2,f ;decrece de 1 en 1 
    goto RET2
    decfsz aux3,f ;decrece de 1 en 1 
    goto RET3
    return
 
PARA:
    bcf   T0CON,TMR0ON		;APAGA EL TIMER0
    goto salir
CONTINUA:
    bsf T0CON,TMR0ON		;PRENDE EL TIMER0
    goto salir
salir:
    call retardo
    movlw b'11110000'
    movwf TRISB
    clrf  LATB
    bcf  INTCON,RBIF
    retfie
 END