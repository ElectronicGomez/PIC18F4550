list p=18f4550		;Modelo del microcontrolador
#include<p18f4550.inc>	;Libreria de nombre de registros
    
    ;Aquí van los bits de configuracion
    CONFIG  FOSC = XT_XT          ; Oscillator Selection bits (XT oscillator (XT))
    CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
    CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
    CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
    CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
    CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
    
    cblock 0x010
    mindec
    minuni
    horadec
    horauni
    apagar
    seguni
    
    endc

    org 0x0600
Tabla db 0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x67
 
     org 0x0000
goto Configuracion

    org 0x0008
goto hi_int
    
    org 0x0018
goto low_int
 
    org 0x0020
Configuracion:
    clrf TRISD
    bsf RCON,IPEN
    bsf INTCON3,INT1IP
    bsf INTCON3,INT2IP
    bcf INTCON2,TMR0IP
    bsf IPR1,CCP1IP
    bsf PIE1,TMR1IE
    bsf PIE1,CCP1IE
    bcf INTCON2,INTEDG0
    bcf INTCON2,INTEDG1
    bcf INTCON2,INTEDG2
    bsf INTCON,INT0IE
    bsf INTCON3,INT1IE
    bsf INTCON3,INT2IE
    bsf INTCON,TMR0IE
    
    movlw 0xC0
    movwf T0CON
    movlw 0x8B
    movwf T1CON  ;TIMER1 ON, psc 1:1 xtal 32.768Khz
   
    movlw 0x0B
    movwf CCP1CON ;modo evento especial
    movlw 0x80
    movwf CCPR1H           ;Valor de comparación
    movlw 0x00
    movwf CCPR1L 
    ;bcf TRISB,3
    bsf INTCON,GIEL
    bsf INTCON,GIEH
    
    bcf TRISE,0
    bcf TRISE,1
    bcf TRISE,2
    bcf TRISB,7
    
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    
    movlw HIGH Tabla
    movwf TBLPTRH
    clrf apagar
    clrf mindec
    clrf minuni
    clrf horadec
    clrf horauni
    clrf seguni
inicio:
  
    goto inicio
    
    
hi_int:
    btfsc PIR1,CCP1IF
    goto timer1
    btfsc INTCON,INT0IF
    goto boton_int0
    btfsc INTCON3,INT1IF
    goto boton_int1
    btfsc INTCON3,INT2IF
    goto boton_int2
    retfie
    

low_int:
    btfsc INTCON,TMR0IF
    goto timer0
    retfie
timer1:
    ;btg LATB,3
    incf seguni
    movlw .60
    cpfseq seguni
    goto salida
    clrf seguni
    bcf PIR1,CCP1IF
    goto boton_int1
salida:
    bcf PIR1,CCP1IF
    retfie
timer0:
    movlw .1
    cpfseq apagar
    goto alto_consumo
    goto bajo_consumo
    
alto_consumo:
Display1:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff horadec,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    bcf LATE,0
    call noops
    bsf LATE,0
    
Display2:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff horauni,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    bcf LATE,1
    call noops
    bsf LATE,1
    
Display3:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff mindec,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    bcf LATE,2
    call noops
    bsf LATE,2
    
Display4:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff minuni,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
    bcf LATB,7
    call noops
    bsf LATB,7
    
    bcf INTCON,TMR0IF
    retfie
    
bajo_consumo:
Display1b:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff horadec,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
;    bcf LATE,0
    call noops
    bsf LATE,0
    
Display2b:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff horauni,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
;    bcf LATE,1
    call noops
    bsf LATE,1
    
Display3b:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff mindec,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
;    bcf LATE,2
    call noops
    bsf LATE,2
    
Display4b:
    bsf LATE,0
    bsf LATE,1
    bsf LATE,2
    bsf LATB,7
    movff minuni,TBLPTRL
    TBLRD*
    movff TABLAT,LATD
;    bcf LATB,7
    call noops
    bsf LATB,7
    
    bcf INTCON,TMR0IF
    retfie
boton_int0:
    movlw .2
    cpfseq horadec
    goto nohoradec
    goto sihoradec
    
nohoradec:
    movlw .9
    cpfseq horauni
    goto nohorauni
    goto sihorauni
sihoradec:
    movlw .3
    cpfseq horauni
    goto nonono0
    goto sisisi0
nohorauni:
    incf horauni
    goto finboton_int0
sihorauni:
    clrf horauni
    incf horadec
    goto finboton_int0

nonono0:
    incf horauni
    goto finboton_int0
sisisi0:
    clrf horauni
    clrf horadec
    goto finboton_int0
        
    
finboton_int0:
    bcf INTCON,INT0IF
    retfie


        
boton_int1:
    movlw .5
    cpfseq mindec
    goto nomindec
    goto simindec
    
nomindec:
    movlw .9
    cpfseq minuni
    goto nominuni
    goto siminuni
simindec:
    movlw .9
    cpfseq minuni
    goto nonono1
    goto sisisi1
nominuni:
    incf minuni
    goto Fin_Rutina_Int1
siminuni:
    clrf minuni
    incf mindec
    goto Fin_Rutina_Int1
nonono1:
    incf minuni
    goto Fin_Rutina_Int1
sisisi1:
    clrf minuni
    clrf mindec
    goto boton_int0
Fin_Rutina_Int1:
    bcf INTCON3,INT1IF
    retfie

    
    
boton_int2:
;    bsf LATE,0
;    bsf LATE,1 
;    bsf LATE,2
    movlw .1
    cpfseq apagar
    goto noes
    goto sies
noes:
    incf apagar,f
    goto bajar_bandera
sies:
    clrf apagar
bajar_bandera:
    bcf INTCON3,INT2IF
    retfie
  

    
noops:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    return                    
    
    END