clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';

csvFiles = dir(fullfile(dataFolder, "R20_FZ_*.csv"));

for i = 1:numel(csvFiles)
    curFile = fullfile(csvFiles(i).folder, csvFiles(i).name);
    disp("Processing" + csvFiles(i).name);

    table = readtable(curFile);
    varNames = ["RoadSpeed", "TirePressure", "InclinationAngle", "NormalForce", "SlipAngle", "ElapsedTime", "LateralForce", "Index"];
    table = table(:, varNames);

end