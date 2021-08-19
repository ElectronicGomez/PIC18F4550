#include <xc.h>
#pragma config PLLDIV = 1
#pragma config CPUDIV = OSC1_PLL2
#pragma config USBDIV = 1
#pragma config FOSC = XTPLL_XT
#pragma config PWRT = OFF
#pragma config BOR = ON
#pragma config BORV = 3
#pragma config VREGEN = OFF
#pragma config WDT = OFF
#pragma config WDTPS = 32768
#pragma config PBADEN = OFF
#pragma config MCLRE = ON
#pragma config LVP = OFF
#define _XTAL_FREQ 48000000UL
#include "serial.h"
#include "LCD.h"
typedef union
{
    struct{
        char bit0:1;
        char bit1:1;
        char bit2:1;
        char bit3:1;
        char bit4:1;
        char bit5:1;
        char bit6:1;
        char bit7:1;
    }_bits;
    char _byte;
}tipo_sony;
char vector[12];
unsigned char x=1;
unsigned int memoria[12];
char flancos=0;
unsigned int aux;
char estado=0,i=0;
char power=10101001;
char ch1=10000000;
char ch2=10001;
char num1=00000;
char num2=00001;
char num3=0100000;
char num4=11000;
char num5=00100;
char num6=10100;
char num7=01100;
char num8=11100;
char num9=00010;
char num0=01001;
int cont;
int suma;
char z;

char posicion=0;


//unsigned int aux;
unsigned int boton1,boton2;
typedef union{
    unsigned int _tmr0;
    struct{
        char _tmr0_low;
        char _tmr0_high;
    }_bytes;
}tmr0;
tmr0 mi_timer;
//signed char angulo=-90;
unsigned char angulo;
tipo_sony dato;
#define ERROR 20
#define LISTO 21
void main()
{
    ///////////LCD
    TRISD = 0x00;
    LCD_CONFIG();
    __delay_ms(10);
    BORRAR_LCD();
    CURSOR_ONOFF(OFF);
    ///////////////
    
    TRISC = 0xBF;//10111111  //C6 como salida TX
    T3CONbits.RD16    = 1;
    T3CONbits.T3CKPS1 = 1;
    T3CONbits.T3CKPS0 = 1; //Prescaler = 8
    T3CONbits.T3CCP2 =1;
    T3CONbits.T3CCP1 =1;
    T3CONbits.TMR3ON  = 1;
    CCP2CON = 0x05; //Modo captura todo flanco de subida
    PIE2bits.CCP2IE   = 1;
    PIE2bits.TMR3IE   = 1;
    TRISCbits.TRISC0=0;     //  C0 COMO SALIDA
    T0CON = 0b00001000;//TMR0 OFF, 16 bits de conteo, PRESCALER=1, 0.0833us tiempo conteo
    T1CON = 0b10110001;//TMR1 ON, 16 bits de conteo,PRESCALER = 8, 0.66us tiempo conteo
    TMR1H = 0x8A;
    TMR1L = 0xD0;
    PIE1bits.TMR1IE=1;
    INTCONbits.TMR0IE=1;
    INTCONbits.PEIE=1;
    INTCONbits.GIE=1;
    Abrir_Serial(_9600);
    TX_CHAR_EUSART('\f');
    TX_MENSAJE_EUSART("Tecla: ",7);
    dato._byte=0x00;
    //
    ESCRIBE_MENSAJE("Pulse un angulo:",16);
    //ESCRIBE_MENSAJE("Pulse una Tecla:",16);
    POS_CURSOR(2,0);
    //ENVIA_CHAR(3+'0');
    //POS_CURSOR(2,10);
    //ESCRIBE_MENSAJE("A",1);
    
    while(1)
    {
        switch(estado)
        {
            case LISTO:
                dato._byte=0;
                dato._bits.bit0=vector[0];
                dato._bits.bit1=vector[1];
                dato._bits.bit2=vector[2];
                dato._bits.bit3=vector[3];
                dato._bits.bit4=vector[4];
                dato._bits.bit5=vector[5];
                dato._bits.bit6=vector[6];
                if(vector[7]==1 && vector[8]==0 &&
                   vector[9]==0 && vector[10]==0 &&
                   vector[11]==0)
                {
                    
                    //ENVIA_CHAR(dato._byte+'0');
                    //posicion++;
                    //TX_CHAR_EUSART(dato._byte+'0');
                    /*for (x=0;x<8;x++){
                        TX_CHAR_EUSART(vector[x]+'0');
                     }*/
                    //angulo=80;
                    /*if (dato._byte==21){
                        TX_MENSAJEASCII_EUSART("POWER");
                        angulo=0;
                        
                    }*/
                    if (dato._byte==16){    //CH+
                        //x=x*1;
                        if (cont==0){
                            ENVIA_CHAR('+');
                            TX_MENSAJEASCII_EUSART("+");
                            x=1;
                            cont++;
                            //angulo=-90;
                        }
                        
                    }
                    else if (dato._byte==17){ //CH-
                        //x=x*(-1);
                        if (cont==0){
                            TX_MENSAJEASCII_EUSART("-");
                            ENVIA_CHAR('-');
                            x=-1;
                            cont++;
                        }
                    }
                    
                    else if (dato._byte==0){ // 1
                        if (cont==1){
                            boton1=1;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){ //1
                            boton2=1;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==1){
                        if (cont==1){
                            boton1=2;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                        }
                        else if (cont==2){
                            
                            boton2=2;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==2){
                        if (cont==1){
                            boton1=3;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                        }
                        else if (cont==2){
                            
                            boton2=3;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==3){
                        if (cont==1){
                            boton1=4;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=4;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==4){
                        if (cont==1){
                            boton1=5;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=5;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==5){
                        if (cont==1){
                            boton1=6;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=6;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==6){
                        if (cont==1){
                            boton1=7;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=7;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==7){
                        if (cont==1){
                            boton1=8;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=8;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==8){
                        if (cont==1){
                            boton1=9;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=9;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==9){  //0
                        if (cont==1){
                            boton1=0;
                            TX_CHAR_EUSART(boton1+'0');
                            ENVIA_CHAR(boton1+'0');
                            cont++;
                            
                        }
                        else if (cont==2){
                            boton2=0;
                            TX_CHAR_EUSART(boton2+'0');
                            ENVIA_CHAR(boton2+'0');
                            cont++;
                        }
                    }
                    else if (dato._byte==21){//POWER
                        //if(-91< ((boton1*10)+boton2) <91)
                        
                        //{
                            if (cont==3){   //SOLO SI SE INGRESARON LOS 2 NUMEROS
                                aux=boton1*10;
                                angulo=aux+boton2;
                                TX_MENSAJEASCII_EUSART("ok");
                                angulo=angulo*x;
                                angulo=angulo+90;
                                
                                POS_CURSOR(2,0);
                                ESCRIBE_MENSAJE("                ",16);
                                POS_CURSOR(2,0);
                                cont=0;
                            }
                        //}
                        //else ESCRIBE_MENSAJE("Valor Invalido!!",16);
                    }
                    else if (dato._byte=='F'-48){
                        POS_CURSOR(2,0);
                        ESCRIBE_MENSAJE("           ",11);
                        POS_CURSOR(2,0);
                        cont=0;
                    }
                    
                    
                    
                }
                estado = 0;
                flancos = 0;
                break;
            case ERROR:
                //__delay_ms(200);
                
                estado = 0;
                flancos = 0;
                break;
        }
    }
}
void interrupt high_priority interrupciones(void)
{
    if(PIR2bits.TMR3IF==1)
    {
       PIR2bits.TMR3IF=0; 
    }
    if(PIR1bits.RC1IF==1)
    {
        char dato;
        dato = RCREG;
    }
    if(PIR2bits.CCP2IF==1)
    {
        aux = CCPR2;        
        TMR3H=0;TMR3L=0;
        PIR2bits.CCP2IF=0;
        switch(flancos)
        {
            case 0:
                i=0;
                break;
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
            case 11:
            case 12:
                if(aux>=1700 && aux<=1900)
                    vector[flancos-1]=0;
                else if(aux>=2600 && aux<=2800)
                    vector[flancos-1]=1;
                else 
                {
                    estado = ERROR;
                }
                memoria[i]=aux;
                i++;
                break;
        }
        flancos++;
        if(flancos==13)
        {
            __delay_ms(300);
            flancos = 0;
            estado = LISTO;
        }
    }
    if(PIR1bits.TMR1IF==1)
    {
        PIR1bits.TMR1IF=0;
        TMR1H = 0x8A;
        TMR1L = 0xD0;
        LATCbits.LATC0=1;
        mi_timer._tmr0=57736-angulo*113;
        TMR0L=mi_timer._bytes._tmr0_low;
        TMR0H=mi_timer._bytes._tmr0_high;
        T0CONbits.TMR0ON=1;
    }
    else if(INTCONbits.TMR0IF==1)
    {
        LATCbits.LATC0=0;
        INTCONbits.TMR0IF=0;
        T0CONbits.TMR0ON=0;
    }
}
