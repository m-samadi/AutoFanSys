% Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%% Clear variables and screen 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
clc;





%%%%% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SimulationTime=600;
TotalInformation=zeros(SimulationTime,9); % Time | Temperature | Gas | Light | Speed | Total current consumption without the proposed system | Total current consumption with the proposed system | Total energy consumption without the proposed system | Total energy consumption with the proposed system
TotalInformation_Index=0;
Max_S=255;
V=6;
I=500;

Temperature_EffectiveWeight=0.4;
Gas_EffectiveWeight=0.5;
Light_EffectiveWeight=0.1;

Temperature_ShapeFactor=180;
Gas_ShapeFactor=9000;
Light_ShapeFactor=130000;
Speed_ShapeFactor=255;

Temperature_Type='i';
Gas_Type='i';
Light_Type='i';
Speed_Type='b';





%%%%% Membership functions of the fuzzy decision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Temperature
U_Temperature=[-55 0 30 80 125];
% Cold
Crisp=-30;
mu_Temperature_Cold=fuzzifysn(U_Temperature,Crisp,Temperature_Type,Temperature_ShapeFactor)
mu_Temperature_Cold_W=mu_Temperature_Cold*Temperature_EffectiveWeight
% Moderate
Crisp=10;
mu_Temperature_Moderate=fuzzifysn(U_Temperature,Crisp,Temperature_Type,Temperature_ShapeFactor)
mu_Temperature_Moderate_W=mu_Temperature_Moderate*Temperature_EffectiveWeight
% Warm
Crisp=60;
mu_Temperature_Warm=fuzzifysn(U_Temperature,Crisp,Temperature_Type,Temperature_ShapeFactor)
mu_Temperature_Warm_W=mu_Temperature_Warm*Temperature_EffectiveWeight
% Hot
Crisp=125;
mu_Temperature_Hot=fuzzifysn(U_Temperature,Crisp,Temperature_Type,Temperature_ShapeFactor)
mu_Temperature_Hot_W=mu_Temperature_Hot*Temperature_EffectiveWeight

disp(' ');
disp(' ');
disp(' ');

%%% Gas
U_Gas=[10 2500 5000 7500 10000];
% Low Density
Crisp=10;
mu_Gas_LowDensity=fuzzifysn(U_Gas,Crisp,Gas_Type,Gas_ShapeFactor)
mu_Gas_LowDensity_W=mu_Gas_LowDensity*Gas_EffectiveWeight
% Normal
Crisp=4000;
mu_Gas_Normal=fuzzifysn(U_Gas,Crisp,Gas_Type,Gas_ShapeFactor)
mu_Gas_Normal_W=mu_Gas_Normal*Gas_EffectiveWeight
% High Density
Crisp=7500;
mu_Gas_HighDensity=fuzzifysn(U_Gas,Crisp,Gas_Type,Gas_ShapeFactor)
mu_Gas_HighDensity_W=mu_Gas_HighDensity*Gas_EffectiveWeight
% Extreme Density
Crisp=10000;
mu_Gas_ExtremeDensity=fuzzifysn(U_Gas,Crisp,Gas_Type,Gas_ShapeFactor)
mu_Gas_ExtremeDensity_W=mu_Gas_ExtremeDensity*Gas_EffectiveWeight

disp(' ');
disp(' ');
disp(' ');

%%% Light
U_Light=[0 32500 65000 97500 130000];
% Dark
Crisp=0;
mu_Light_Dark=fuzzifysn(U_Light,Crisp,Light_Type,Light_ShapeFactor)
mu_Light_Dark_W=mu_Light_Dark*Light_EffectiveWeight
% Standard
Crisp=40000;
mu_Light_Standard=fuzzifysn(U_Light,Crisp,Light_Type,Light_ShapeFactor)
mu_Light_Standard_W=mu_Light_Standard*Light_EffectiveWeight
% Bright
Crisp=65000;
mu_Light_Bright=fuzzifysn(U_Light,Crisp,Light_Type,Light_ShapeFactor)
mu_Light_Bright_W=mu_Light_Bright*Light_EffectiveWeight
% Very Bright
Crisp=130000;
mu_Light_VeryBright=fuzzifysn(U_Light,Crisp,Light_Type,Light_ShapeFactor)
mu_Light_VeryBright_W=mu_Light_VeryBright*Light_EffectiveWeight

disp(' ');
disp(' ');
disp(' ');

%%% Speed
%U_Speed=[0 50 127 200 255];
U_Speed=0:0.1:255;
% Low
Crisp=20;
mu_Speed_Low=fuzzifysn(U_Speed,Crisp,Speed_Type,Speed_ShapeFactor)
% Medium
Crisp=127;
mu_Speed_Medium=fuzzifysn(U_Speed,Crisp,Speed_Type,Speed_ShapeFactor)
% High
Crisp=200;
mu_Speed_High=fuzzifysn(U_Speed,Crisp,Speed_Type,Speed_ShapeFactor)
% Very High
Crisp=255;
mu_Speed_VeryHigh=fuzzifysn(U_Speed,Crisp,Speed_Type,Speed_ShapeFactor)

disp(' ');
disp(' ');
disp(' ');





%%%%% Fuzzy rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Rule 1
mu_ABC1=fuzzyand(mu_Temperature_Cold_W,mu_Gas_LowDensity_W,mu_Light_Dark_W);
R1=rulemakem(mu_ABC1,mu_Speed_Low);
%%% Rule 2
mu_ABC2=fuzzyand(mu_Temperature_Cold_W,mu_Gas_LowDensity_W,mu_Light_Standard_W);
R2=rulemakem(mu_ABC2,mu_Speed_Low);
%%% Rule 3
mu_ABC3=fuzzyand(mu_Temperature_Cold_W,mu_Gas_Normal_W,mu_Light_Bright_W);
R3=rulemakem(mu_ABC3,mu_Speed_Low);
%%% Rule 4
mu_ABC4=fuzzyand(mu_Temperature_Cold_W,mu_Gas_Normal_W,mu_Light_VeryBright_W);
R4=rulemakem(mu_ABC4,mu_Speed_Low);
%%% Rule 5
mu_ABC5=fuzzyand(mu_Temperature_Cold_W,mu_Gas_HighDensity_W,mu_Light_Dark_W);
R5=rulemakem(mu_ABC5,mu_Speed_Medium);
%%% Rule 6
mu_ABC6=fuzzyand(mu_Temperature_Cold_W,mu_Gas_HighDensity_W,mu_Light_Standard_W);
R6=rulemakem(mu_ABC6,mu_Speed_Medium);
%%% Rule 7
mu_ABC7=fuzzyand(mu_Temperature_Cold_W,mu_Gas_ExtremeDensity_W,mu_Light_Bright_W);
R7=rulemakem(mu_ABC7,mu_Speed_High);
%%% Rule 8
mu_ABC8=fuzzyand(mu_Temperature_Cold_W,mu_Gas_ExtremeDensity_W,mu_Light_VeryBright_W);
R8=rulemakem(mu_ABC8,mu_Speed_High);
%%% Rule 9
mu_ABC9=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_LowDensity_W,mu_Light_Dark_W);
R9=rulemakem(mu_ABC9,mu_Speed_Low);
%%% Rule 10
mu_ABC10=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_LowDensity_W,mu_Light_Standard_W);
R10=rulemakem(mu_ABC10,mu_Speed_Low);
%%% Rule 11
mu_ABC11=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_Normal_W,mu_Light_Bright_W);
R11=rulemakem(mu_ABC11,mu_Speed_Low);
%%% Rule 12
mu_ABC12=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_Normal_W,mu_Light_VeryBright_W);
R12=rulemakem(mu_ABC12,mu_Speed_Medium);
%%% Rule 13
mu_ABC13=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_HighDensity_W,mu_Light_Dark_W);
R13=rulemakem(mu_ABC13,mu_Speed_Medium);
%%% Rule 14
mu_ABC14=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_HighDensity_W,mu_Light_Standard_W);
R14=rulemakem(mu_ABC14,mu_Speed_High);
%%% Rule 15
mu_ABC15=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_ExtremeDensity_W,mu_Light_Bright_W);
R15=rulemakem(mu_ABC15,mu_Speed_High);
%%% Rule 16
mu_ABC16=fuzzyand(mu_Temperature_Moderate_W,mu_Gas_ExtremeDensity_W,mu_Light_VeryBright_W);
R16=rulemakem(mu_ABC16,mu_Speed_VeryHigh);
%%% Rule 17
mu_ABC17=fuzzyand(mu_Temperature_Warm_W,mu_Gas_LowDensity_W,mu_Light_Dark_W);
R17=rulemakem(mu_ABC17,mu_Speed_Low);
%%% Rule 18
mu_ABC18=fuzzyand(mu_Temperature_Warm_W,mu_Gas_LowDensity_W,mu_Light_Standard_W);
R18=rulemakem(mu_ABC18,mu_Speed_Low);
%%% Rule 19
mu_ABC19=fuzzyand(mu_Temperature_Warm_W,mu_Gas_Normal_W,mu_Light_Bright_W);
R19=rulemakem(mu_ABC19,mu_Speed_Medium);
%%% Rule 20
mu_ABC20=fuzzyand(mu_Temperature_Warm_W,mu_Gas_Normal_W,mu_Light_VeryBright_W);
R20=rulemakem(mu_ABC20,mu_Speed_Medium);
%%% Rule 21
mu_ABC21=fuzzyand(mu_Temperature_Warm_W,mu_Gas_HighDensity_W,mu_Light_Dark_W);
R21=rulemakem(mu_ABC21,mu_Speed_High);
%%% Rule 22
mu_ABC22=fuzzyand(mu_Temperature_Warm_W,mu_Gas_HighDensity_W,mu_Light_Standard_W);
R22=rulemakem(mu_ABC22,mu_Speed_VeryHigh);
%%% Rule 23
mu_ABC23=fuzzyand(mu_Temperature_Warm_W,mu_Gas_ExtremeDensity_W,mu_Light_Bright_W);
R23=rulemakem(mu_ABC23,mu_Speed_VeryHigh);
%%% Rule 24
mu_ABC24=fuzzyand(mu_Temperature_Warm_W,mu_Gas_ExtremeDensity_W,mu_Light_VeryBright_W);
R24=rulemakem(mu_ABC24,mu_Speed_VeryHigh);
%%% Rule 25
mu_ABC25=fuzzyand(mu_Temperature_Hot_W,mu_Gas_LowDensity_W,mu_Light_Dark_W);
R25=rulemakem(mu_ABC25,mu_Speed_Medium);
%%% Rule 26
mu_ABC26=fuzzyand(mu_Temperature_Hot_W,mu_Gas_LowDensity_W,mu_Light_Standard_W);
R26=rulemakem(mu_ABC26,mu_Speed_Medium);
%%% Rule 27
mu_ABC27=fuzzyand(mu_Temperature_Hot_W,mu_Gas_Normal_W,mu_Light_Bright_W);
R27=rulemakem(mu_ABC27,mu_Speed_High);
%%% Rule 28
mu_ABC28=fuzzyand(mu_Temperature_Hot_W,mu_Gas_Normal_W,mu_Light_VeryBright_W);
R28=rulemakem(mu_ABC28,mu_Speed_High);
%%% Rule 29
mu_ABC29=fuzzyand(mu_Temperature_Hot_W,mu_Gas_HighDensity_W,mu_Light_Dark_W);
R29=rulemakem(mu_ABC29,mu_Speed_VeryHigh);
%%% Rule 30
mu_ABC30=fuzzyand(mu_Temperature_Hot_W,mu_Gas_HighDensity_W,mu_Light_Standard_W);
R30=rulemakem(mu_ABC30,mu_Speed_VeryHigh);
%%% Rule 31
mu_ABC31=fuzzyand(mu_Temperature_Hot_W,mu_Gas_ExtremeDensity_W,mu_Light_Bright_W);
R31=rulemakem(mu_ABC31,mu_Speed_VeryHigh);
%%% Rule 32
mu_ABC32=fuzzyand(mu_Temperature_Hot_W,mu_Gas_ExtremeDensity_W,mu_Light_VeryBright_W);
R32=rulemakem(mu_ABC32,mu_Speed_VeryHigh);

%%% Aggregation of rules 
R=totalrule(R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31,R32)





%%%%% Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=1;
Temperature=30;
Gas=5000;
Light=45000;

while (Time<=SimulationTime)
    % Temperature
    DifferenceValue=5;    
    if rand()<=0.5
        Temperature=Temperature+DifferenceValue;
    else
        Temperature=Temperature-DifferenceValue;
    end;
    
    if Temperature<-55
        Temperature=-55;
    end;
    
    if Temperature>125
        Temperature=125;
    end;    
    
    % Gas
    DifferenceValue=50;    
    if rand()<=0.5
        Gas=Gas+DifferenceValue;
    else
        Gas=Gas-DifferenceValue;
    end;
    
    if Gas<10
        Gas=10;
    end;
    
    if Gas>10000
        Gas=10000;
    end;     
    
    % Light
    DifferenceValue=500;    
    if rand()<=0.5
        Light=Light+DifferenceValue;
    else
        Light=Light-DifferenceValue;
    end;
    
    if Light<0
        Light=0;
    end;
    
    if Light>130000
        Light=130000;
    end;
    
    % Speed
    mu_Temperature=fuzzifysn(U_Temperature,Temperature,Temperature_Type,Temperature_ShapeFactor);
    mu_Temperature_W=mu_Temperature*Temperature_EffectiveWeight;

    mu_Gas=fuzzifysn(U_Gas,Gas,Gas_Type,Gas_ShapeFactor);
    mu_Gas_W=mu_Gas*Gas_EffectiveWeight;

    mu_Light=fuzzifysn(U_Light,Light,Light_Type,Light_ShapeFactor);
    mu_Light_W=mu_Light*Light_EffectiveWeight;

    mu_Speed=ruleresp(R,fuzzyand(mu_Temperature_W,mu_Gas_W,mu_Light_W));
    Speed=defuzzyg(U_Speed,mu_Speed);
    
    % Total current consumption
    %\ Total current consumption without the proposed system
    TotalCurrentConsumption1=I*Time;
    
    %\ Total current consumption with the proposed system
    TotalCurrentConsumption2=I*Time*(Speed/Max_S); 
    
    % Total energy consumption
    %\ Total energy consumption without the proposed system
    TotalEnergyConsumption1=I*V*Time;
    
    %\ Total energy consumption with the proposed system
    TotalEnergyConsumption2=I*V*Time*(Speed/Max_S);     
    
    % Total information
    TotalInformation_Index=TotalInformation_Index+1;
    TotalInformation(TotalInformation_Index,1)=Time;
    TotalInformation(TotalInformation_Index,2)=Temperature;
    TotalInformation(TotalInformation_Index,3)=Gas;
    TotalInformation(TotalInformation_Index,4)=Light;
    TotalInformation(TotalInformation_Index,5)=Speed;
    TotalInformation(TotalInformation_Index,6)=TotalCurrentConsumption1;
    TotalInformation(TotalInformation_Index,7)=TotalCurrentConsumption2;
    TotalInformation(TotalInformation_Index,8)=TotalEnergyConsumption1;
    TotalInformation(TotalInformation_Index,9)=TotalEnergyConsumption2;
    
    %
    Time
    Time=Time+1;
end;





%%%%% Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);

subplot(3,1,1);
plot(TotalInformation(:,1),TotalInformation(:,2),'r','LineWidth',2);
xlabel('Time (min)');
ylabel('Temperature (°C)');

subplot(3,1,1);
plot(TotalInformation(:,1),TotalInformation(:,3),'r','LineWidth',2);
xlabel('Time (min)');
ylabel('Gas (ppm)');

subplot(3,1,2);
plot(TotalInformation(:,1),TotalInformation(:,4),'b','LineWidth',2);
xlabel('Time (min)');
ylabel('Light (lx)');

subplot(3,1,3);
plot(TotalInformation(:,1),TotalInformation(:,5),'k','LineWidth',2);
xlabel('Time (min)');
ylabel('Speed (PWM)');

