clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';

csvFiles = {
    'R20_FZ_50.csv'
    'R20_FZ_100.csv'
    'R20_FZ_150.csv'
    'R20_FZ_200.csv'
    'R20_FZ_250.csv'
};

for i = 1:numel(csvFiles)
    curFile = fullfile(dataFolder, csvFiles{i});
    disp("Processing " + csvFiles{i});
    table = readtable(curFile);
    varNames = ["RoadSpeed", "TirePressure", "InclinationAngle","NormalForce", "SlipAngle", "ElapsedTime", "LateralForce", "Index"];
    table = table(:, varNames);
    table.RoadSpeed = round(table.RoadSpeed);
    table.TirePressure = floor(table.TirePressure);
    table.InclinationAngle = floor(table.InclinationAngle * 10) / 10;
    table = sortrows(table, ["RoadSpeed", "TirePressure", "InclinationAngle"]);

