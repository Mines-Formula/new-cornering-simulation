clc, clearvars, clear all

dataPath = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_with_FY_binned.csv';
data = readtable(dataPath);

FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;
FY_exp = data.LateralForce;
FY = data.FY;
time = data.ElapsedTime;

FZ_binned = round(FZ / 50) * 50;

% Graph comparison of the two

[alphaSorted, idx] = sort(alpha);
FY_exp_sorted = FY_exp(idx);
FY_calc_sorted = FY(idx);
FZ_binned_sorted = FZ_binned(idx);
timeSorted = time(idx);

uniqueBins = unique(FZ_binned_sorted);
numBins = numel(uniqueBins);
colors = turbo(numBins);

timeWindows = [13.0, 91.86; 239.92, 460.94; 716.424, 903.17];

