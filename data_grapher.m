close all;   
clear;        
clc; 

dataFile0 = readtable("data/LC0_combined_filtered.csv");
dataFile2 = readtable("data/LC0_IA-2_combined_filtered.csv");
dataFile4 = readtable("data/LC0_IA-4_combined_filtered.csv");
SA0 = dataFile0.SlipAngle;
FY0 = dataFile0.LateralForce;
SA2 = dataFile2.SlipAngle; 
FY2 = dataFile2.LateralForce;
SA4 = dataFile4.SlipAngle;
FY4 = dataFile4.LateralForce;
P1 = [250, 1.17858, -2.45689, 0.207723, 0.00218554, 0.181269, 0.212474, -2.41388, 0.605724, -30.9683, 1.44763, 0.0143188, -0.00587066, -0.0126017, -0.00150596, -0.18861, -0.170156, 0.0185739, 0.0140275];
disp(P1)
L=[1,1,1,1,1,1,1,1];
alpha = linspace(-14,14,1000)*pi/180;
IA = 4*pi/180;

figure;
hold on 
plot(SA0,FY0, '.','MarkerSize',15)
plot(alpha*180/pi,pacejka(P1,L,50,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,100,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,150,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,200,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,250,IA,alpha));
title("IA = 0")
grid on
hold off

figure;
hold on 
plot(SA2,FY2, '.','MarkerSize',15)
plot(alpha*180/pi,pacejka(P1,L,50,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,100,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,150,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,200,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,250,IA,alpha));
title("IA = 2")
grid on
hold off

figure;
hold on 
plot(SA4,FY4, '.','MarkerSize',15)
plot(alpha*180/pi,pacejka(P1,L,50,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,100,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,150,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,200,IA,alpha));
plot(alpha*180/pi,pacejka(P1,L,250,IA,alpha));
title("IA = 4")
grid on
hold off