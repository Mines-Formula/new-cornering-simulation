clc, clearvars, clear all

infoTable = readtable('C:\Users\ajsau\Documents\formula\corneringSim\cornering-simulation\LCO_infoTable.csv');

%genereate 8 ones
L = ones(1, 8);
%load in information from the sorted data
FZ = infoTable.NormalForce;
IA = infoTable.InclinationAngle;
%these are the P values for R20, not LC0
P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
alpha = infoTable.SlipAngle;

FY = pacejka(P, L, FZ, IA, alpha);