clc, clearvars, clear all\

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';
inFile  = fullfile(dataFolder, "R20_infoTable.csv");

T = readtable(inFile)

x = T{:,"ElapsedTime"}
tp = T{:,"TirePressure"}
ia = T{:,"InclinationAngle"}
sa = T{:, "SlipAngle"}
fz = T{:, "NormalForce"}

scatter(x, tp, "yellow")
hold on
scatter(x, ia, "magenta")
hold on
scatter(x, sa, "blue")
hold on
scatter(x, fz, "red")