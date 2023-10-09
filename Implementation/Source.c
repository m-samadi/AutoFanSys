/*******************************************************
This program was created by the
CodeWizardAVR V3.12 Advanced
Automatic Program Generator
© Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : Automatic Knowledge-based Fan System
Version : 
Date    : 2017/05/24
Author  : Mohammad Samadi
Company : 
Comments: 


Chip type               : ATmega16A
Program type            : Application
AVR Core Clock frequency: 8.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 256
*******************************************************/

#include <mega16a.h>

// 1 Wire Bus interface functions
#include <1wire.h>

// DS18B20 Temperature Sensor functions
#include <ds1820.h>

// Alphanumeric LCD functions
#include <alcd.h>

#include <delay.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#asm
   .equ __lcd_port=0x18; PORTB
#endasm

// Maximum number of DS18B20 devices connected to the 1 Wire bus
#define MAX_DS18B20 8

// Number of DS18B20 devices connected to the 1 Wire bus
unsigned char DS18B20_Devices;

// DS18B20 devices ROM code storage area,
// 9 bytes are used for each device
unsigned char DS18B20_ROM_Codes[MAX_DS18B20][9];

int Speed=255;
float Temperature_EffectiveWeight=0.4, Gas_EffectiveWeight=0.5, Light_EffectiveWeight=0.1;
long int Temperature_Universe[5]={-55, 0, 30, 80, 125}, Gas_Universe[5]={10, 2500, 5000, 7500, 10000}, Light_Universe[5]={0, 32500, 65000, 97500, 130000};
int Speed_Universe[5]={0, 50, 127, 200, 255};
float R[5][5]={{0.1, 0.1, 0.021787, 0.0078089, 0.0045963}, {0.088462, 0.088462, 0.05, 0.045666, 0.015325}, {0.1, 0.1, 0.1, 0.061538, 0.061538}, {0.05, 0.05, 0.05, 0.05, 0.05}, {0.0039063, 0.0060312, 0.015325, 0.077744, 0.1}};

//********************************************************************
long int ReadSensor(int SensorID)
{
    switch(SensorID)
    {
        // Temperature sensor (DS18B20)
        case 1:
            return ds1820_temperature_10(DS18B20_ROM_Codes[0])/80;
            break;
        
        // Gas sensor (MQ-9)     
        case 2:
            DDRA=0X00;
            ADMUX=0b11000001;
            ADCSRA.6=1;
            
            delay_ms(10);
                
            ADCSRA=0b11000000;    
            while (ADCSRA.4==0);
            ADCSRA.4=1;
            
            return ADCW;        
            break; 
        // Light sensor (Photocell)     
        case 3:
            DDRA=0X00;
            ADMUX=0b11000010;
            ADCSRA.6=1;
            
            delay_ms(10);
                
            ADCSRA=0b11000000;    
            while (ADCSRA.4==0);
            ADCSRA.4=1;
            
            return ADCW;        
            break;           
    }      
}
//********************************************************************
float Min_2(float a, float b)
{
    if (a<b)
        return a;
    else
        return b;
}
//********************************************************************
float Min_3(float a, float b, float c)
{
    float temp=a; 
    
    if (b<temp)
        temp=b;
    if (c<temp)
        temp=c;
    
    return temp;
}
//********************************************************************
float Max(float a, float b)
{
    if (a>b)
        return a;
    else
        return b;
}
//********************************************************************
float* Fuzzification(long int Universe[5], long int Center, long int Width)
{
    float Set[5];  
    int i;
    for(i=0;i<5;i++){
        if (abs(Center-Universe[i])>(Width/2))
            Set[i]=0;
        else
            Set[i]=1-((float)(2*abs(Center-Universe[i]))/Width);
    }
    
    return Set;
}
//********************************************************************
int Defuzzification(int Universe[5], float FuzzySet[5])
{
    int i;
    float s1=0, s2=0;
    for(i=0;i<5;i++){
        s1+=FuzzySet[i]*Universe[i];
        s2+=FuzzySet[i];
    } 
    
    return (int)(s1/s2);
}
//********************************************************************
void AdjustMotor(int Enable, int Speed)
{
    // Set some pins of Port D as output
    DDRD.5=1;
    DDRD.6=1;
    DDRD.7=1; 
    
    // Enable or disable the motor   
    PORTD.7=Enable;    
    
    // Handle the motor    
    if (Enable==1){                
        OCR1AL=Speed;
        PORTD.6=0;
    }
}
//********************************************************************
void main(void)
{
    // Local variables
    int i, j, SpeedPercentage;
    float m; 
    unsigned char LCD_Buffer[16];
    long int SensedData, Temperature=0, Gas=0, Light=0;
    float *Fuzzification_FuzzySet;
    float Temperature_W_FuzzySet[5], Gas_W_FuzzySet[5], Light_W_FuzzySet[5], Input_W_FuzzySet[5], Speed_FuzzySet[5];    

    // Input/Output Ports initialization
    // Port A initialization
    // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In 
    DDRA=(0<<DDA7) | (0<<DDA6) | (0<<DDA5) | (0<<DDA4) | (0<<DDA3) | (0<<DDA2) | (0<<DDA1) | (0<<DDA0);
    // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T 
    PORTA=(0<<PORTA7) | (0<<PORTA6) | (0<<PORTA5) | (0<<PORTA4) | (0<<PORTA3) | (0<<PORTA2) | (0<<PORTA1) | (0<<PORTA0);

    // Port B initialization
    // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In 
    DDRB=(0<<DDB7) | (0<<DDB6) | (0<<DDB5) | (0<<DDB4) | (0<<DDB3) | (0<<DDB2) | (0<<DDB1) | (0<<DDB0);
    // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T 
    PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (0<<PORTB3) | (0<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);

    // Port C initialization
    // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In 
    DDRC=(0<<DDC7) | (0<<DDC6) | (0<<DDC5) | (0<<DDC4) | (0<<DDC3) | (0<<DDC2) | (0<<DDC1) | (0<<DDC0);
    // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T 
    PORTC=(0<<PORTC7) | (0<<PORTC6) | (0<<PORTC5) | (0<<PORTC4) | (0<<PORTC3) | (0<<PORTC2) | (0<<PORTC1) | (0<<PORTC0);

    // Port D initialization
    // Function: Bit7=In Bit6=In Bit5=Out Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In 
    DDRD=(0<<DDD7) | (0<<DDD6) | (1<<DDD5) | (0<<DDD4) | (0<<DDD3) | (0<<DDD2) | (0<<DDD1) | (0<<DDD0);
    // State: Bit7=T Bit6=T Bit5=0 Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T 
    PORTD=(0<<PORTD7) | (0<<PORTD6) | (0<<PORTD5) | (0<<PORTD4) | (0<<PORTD3) | (0<<PORTD2) | (0<<PORTD1) | (0<<PORTD0);

    // Timer/Counter 1 initialization
    // Clock source: System Clock
    // Clock value: 7.813 kHz
    // Mode: Fast PWM top=0x00FF
    // OC1A output: Non-Inverted PWM
    // OC1B output: Disconnected
    // Noise Canceler: Off
    // Input Capture on Falling Edge
    // Timer Period: 32.768 ms
    // Output Pulse(s):
    // OC1A Period: 32.768 ms Width: 0 us
    // Timer1 Overflow Interrupt: Off
    // Input Capture Interrupt: Off
    // Compare A Match Interrupt: Off
    // Compare B Match Interrupt: Off
    TCCR1A=(1<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<WGM11) | (1<<WGM10);
    TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (1<<WGM12) | (1<<CS12) | (0<<CS11) | (1<<CS10);
    TCNT1H=0x00;
    TCNT1L=0x00;
    ICR1H=0x00;
    ICR1L=0x00;
    OCR1AH=0x00;
    OCR1AL=0x00;
    OCR1BH=0x00;
    OCR1BL=0x00;

    // Timer(s)/Counter(s) Interrupt(s) initialization
    TIMSK=(0<<OCIE2) | (0<<TOIE2) | (0<<TICIE1) | (0<<OCIE1A) | (0<<OCIE1B) | (0<<TOIE1) | (0<<OCIE0) | (0<<TOIE0);

    // 1 Wire Bus initialization
    // 1 Wire Data port: PORTA
    // 1 Wire Data bit: 0
    // Note: 1 Wire port settings are specified in the
    // Project|Configure|C Compiler|Libraries|1 Wire menu.
    w1_init(); 
    
    // Determine the number of DS18B20 devices
    // connected to the 1 Wire bus
    DS18B20_Devices=w1_search(0xf0,DS18B20_ROM_Codes);    

    // Alphanumeric LCD initialization
    // Connections are specified in the
    // Project|Configure|C Compiler|Libraries|Alphanumeric LCD menu:
    // RS - PORTB Bit 0
    // RD - PORTB Bit 1
    // EN - PORTB Bit 2
    // D4 - PORTB Bit 4
    // D5 - PORTB Bit 5
    // D6 - PORTB Bit 6
    // D7 - PORTB Bit 7
    // Characters/line: 16
    lcd_init(16);
    lcd_clear();    
       
    sprintf(LCD_Buffer, "**** Speed ****");
    lcd_puts(LCD_Buffer);
    delay_ms(100);
                
    while (1)
    {
        ///// Input unit
        // Temperature
        if (DS18B20_Devices>0)
        {
            SensedData=ReadSensor(1);            
            if (SensedData>=-55 && SensedData<=125)
                Temperature=SensedData;
        }
        
        // Gas                           
        SensedData=ceil(ReadSensor(2)*9.765)+10;
        if (SensedData>=10 && SensedData<=10000)
            Gas=SensedData;
            
        // Light                           
        SensedData=abs(ceil(ReadSensor(3)*97.75));
        if (SensedData>=0 && SensedData<=130000)
            Light=SensedData;                     
           
        ///// Process unit
        // Fuzzification                      
        Fuzzification_FuzzySet=Fuzzification(Temperature_Universe, Temperature, 180);
        for(i=0;i<5;i++)
            Temperature_W_FuzzySet[i]=*(Fuzzification_FuzzySet+i)*Temperature_EffectiveWeight; 
            
        Fuzzification_FuzzySet=Fuzzification(Gas_Universe, Gas, 9000);
        for(i=0;i<5;i++)
            Gas_W_FuzzySet[i]=*(Fuzzification_FuzzySet+i)*Gas_EffectiveWeight; 
            
        Fuzzification_FuzzySet=Fuzzification(Light_Universe, Light, 130000);
        for(i=0;i<5;i++)
            Light_W_FuzzySet[i]=*(Fuzzification_FuzzySet+i)*Light_EffectiveWeight;                                
                
        // Inference engine        
        for(i=0;i<5;i++)
            Input_W_FuzzySet[i]=Min_3(Temperature_W_FuzzySet[i], Gas_W_FuzzySet[i], Light_W_FuzzySet[i]);            
            
        for (j=0;j<5;j++){
            m=0;            
            for (i=0;i<5;i++) 
                m=Max(Min_2(Input_W_FuzzySet[i], R[i][j]), m); 
                               
            Speed_FuzzySet[j]=m;
        }
        
        // Defuzzification
        Speed=Defuzzification(Speed_Universe, Speed_FuzzySet);                    
        SpeedPercentage=ceil((float)Speed/255*100);
                
        ///// Output unit
        if (SpeedPercentage<10){
            AdjustMotor(0, Speed);
            
            lcd_gotoxy(0,1); 
            lcd_puts("      ");
            lcd_puts("Stop");            
        }
        
        if (SpeedPercentage>=10 && SpeedPercentage<=80){
            AdjustMotor(1, Speed);
            
            sprintf(LCD_Buffer, "%d", SpeedPercentage);
            lcd_gotoxy(0,1); 
            lcd_puts("      ");
            lcd_puts(LCD_Buffer);
            lcd_puts(" %");            
        }
                
        if (SpeedPercentage>80){
            AdjustMotor(1, 255);
            
            lcd_gotoxy(0,1); 
            lcd_puts("   ");
            lcd_puts("High Speed");             
        }             
       
        ///// Delay for 1 min
        delay_ms(60000);
    }
}
