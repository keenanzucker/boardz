function crushTests()
clear all
close all

width_mm = 12.68;
thickness_mm = .79;
l_0_mm = 57;

width = width_mm*10^-3;
thickness = thickness_mm*10^-3;
l_0 = l_0_mm*10^-3;

area = width*thickness;

%% Import Data
Test1 = csvread('Test1_Data1.csv',2,0);
Test2 = csvread('Test4_Data1.csv',2,0);
Test3 = csvread('Test5_Data1.csv',2,0);


%% Stress/Strain Calculations
Test1_strain = Test1(:,2)/l_0_mm;
Test1_stress = Test1(:,3)/area;
Test2_strain_crossHead = Test2(:,2)/l_0_mm;
Test2_strain_extensometer = Test2(:,4);
Test2_stress = Test2(:,3)/area;
Test3_strain_crossHead = Test3(:,2)/l_0_mm;
Test3_strain_extensometer = Test3(:,4);
Test3_stress = Test3(:,3)/area;

Test3_strain_gauge1 = StrainGauge(:,2);
Test3_strain_gauge2 = StrainGauge(:,3);
Test3_strain_gauge3 = StrainGauge(:,4);

%% Plot Raw Data
figure(1)
hold on
plot(Test1(:,2),Test1(:,3),'LineWidth',2)
plot(Test2(:,2),Test2(:,3),'k','LineWidth',2)
plot(Test3(:,2),Test3(:,3),'r','LineWidth',2)
title('Load-Extension')
legend('Test 1','Test 2','Test 3')
xlabel('Extension - mm');
ylabel('Load - kgf')

%% Plot Stress vs Strain
figure(2)
hold all
plot(Test1_strain,Test1_stress,'LineWidth',2)
plot(Test2_strain_extensometer,Test2_stress,'LineWidth',2)
plot(Test2_strain_crossHead,Test2_stress,'LineWidth',2)
plot(Test3_strain_extensometer,Test3_stress,'LineWidth',2)
plot(Test3_strain_crossHead,Test3_stress,'LineWidth',2)
plot(Test3_strain_gauge3,Test3_stress,'LineWidth',2)
title('Stress vs Strain')
legend('Test 1','Test 2 extensometer data','Test 2 Cross Head Data','Test 3 extensometer data','Test 3 Cross Head Data','Test 3 Strain Gauge Data')
xlabel('Strain')
ylabel('Stress - N/m^2')

%% Plot Measurement Compariosn
figure(3)
hold all
plot(Test3_strain_extensometer,Test3_stress,'LineWidth',2)
plot(Test3_strain_crossHead,Test3_stress,'LineWidth',2)
plot(Test3_strain_gauge3,Test3_stress,'LineWidth',2)
title('Strain Measurement Methods')
legend('Cross Head','Extensometer','Strain Gauge')
xlabel('Strain')
ylabel('Stress - N/m^2')

%% Young's Modulus
rise = 2.5*10^8;

crossHead_run = Test1_strain(find(Test1_stress>=rise,1));
extensometer_run = Test2_strain_extensometer(find(Test2_stress>=rise,1));
strainGauge_run = Test3_strain_gauge3(find(Test3_stress>=rise,1));

young_crossHead = rise/crossHead_run;
young_extensometer = rise/extensometer_run;
young_strainGauge = rise/strainGauge_run;

Youngs = [young_crossHead,young_extensometer,young_strainGauge];

%% Proportional Limit
Prime1 = Test1_strain*Youngs(1);
Prime2 = Test2_strain_extensometer*Youngs(2);
Prime3 = Test3_strain_gauge3*Youngs(3);
crossHeadDiff = Test1_stress-Prime1;
extensometerDiff = Test2_stress-Prime2;
strainGaugeDiff = Test3_stress-Prime3;

propLim_crossHead = Test1_stress(find(crossHeadDiff(500:end)<0,1));
propLim_extensometer = Test2_stress(find(extensometerDiff(500:end)<0,1));
propLim_strainGauge = Test3_stress(find(strainGaugeDiff(500:end)<0,1));

ProportinalLimit = [propLim_crossHead,propLim_extensometer,propLim_strainGauge];

%% Modulus of Resiliance

modOfRes_crossHead = trapz(Test1_strain(1:find(crossHeadDiff<-10^7,1)),Test1_stress(1:find(crossHeadDiff<-10^7,1)));
modOfRes_extensometer = trapz(Test2_strain_extensometer(1:find(extensometerDiff<-10^7,1)),Test2_stress(1:find(extensometerDiff<-10^7,1)));
modOfRes_strainGauge = trapz(Test3_strain_gauge3(1:find(strainGaugeDiff<-10^7,1)),Test3_stress(1:find(strainGaugeDiff<-10^7,1)));

ModulusOfResiliance = [modOfRes_crossHead,modOfRes_extensometer,modOfRes_strainGauge];

%% Yield Stress
Yield_05 = yieldStress(.0005);
Yield_2 = yieldStress(.002);
    function res = yieldStress(offset)
        Prime1 = (Test1_strain-offset)*Youngs(1);
        Prime2 = (Test2_strain_extensometer-offset)*Youngs(2);
        Prime3 = (Test3_strain_gauge3-offset)*Youngs(3);
        crossHeadDiff = Test1_stress-Prime1;
        extensometerDiff = Test2_stress-Prime2;
        strainGaugeDiff = Test3_stress-Prime3;
        
        yield_crossHead = Test1_stress(find(crossHeadDiff<0,1));
        yield_extensometer = Test2_stress(find(extensometerDiff<0,1));
        yield_strainGauge = Test3_stress(find(strainGaugeDiff<0,1));
        
        res = [yield_crossHead,yield_extensometer,yield_strainGauge];
    end

%% Poissons Ratio
PoissonsRatio = -Test3_strain_gauge1(1400)/Test3_strain_gauge3(1400);

%% Shear Modulus
shearStress = Test3(1000,3)*width*thickness*sqrt(2);
shearStrain = Test3_strain_gauge2(1000);

shearModulus = shearStress/shearStrain;

%% Ultimate Stress
ultStr_test1 = max(Test1_stress(find(Test1_strain>.1,1):end));
ultStr_test2 = max(Test2_stress(find(Test2_strain_crossHead>.1,1):end));

ultimateStress = (ultStr_test1+ultStr_test2)/2;

%% Fracture Stress
fracStress_test1 = Test1_stress(end);
fracStress_test2 = Test2_stress(end);

fractureStress = (fracStress_test1+fracStress_test2)/2;

%% Modulus of Toughness
modOfTough_test1 = trapz(Test1_strain,Test1_stress);
modOfTough_test2 = trapz(Test2_strain_crossHead,Test2_stress);

modulusOfToughness = (modOfTough_test1+modOfTough_test2)/2;

%% Strain Gauge 45 Comparison
strain45 = (Test3_strain_gauge3+Test3_strain_gauge1)/2;
figure(4)
hold all
plot(strain45,'LineWidth',2)
plot(Test3_strain_gauge2,'LineWidth',2)
title('45 degree predicted vs measured strain')
ylabel('Strain')
legend('Predicted Strain','Measured Strain')

%% Factor of Safety
factorOfSafety([0,45,90],StrainGauge(:,2:4),young_strainGauge,PoissonsRatio,Yield_2(3));

end