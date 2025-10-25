clc, clearvars, clear all

dataPath = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_ranges.csv';
data = readtable(dataPath);

FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;

P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = [1, 1, 1, 1, 1, 1, 1, 1];

FY = pacejka(P, L, FZ, IA, alpha);

data.Calculated_FY = FY;

outFile = fullfile('/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation', 'R20_with_FY.csv');
writetable(data, outFile);
disp("Finished");