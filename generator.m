clc, clearvars, clear all

dataFile = 'Inputs/A2356run4.mat'; % Change this to round you want
outputFolder = 'data/Outputs/R20Round4&5'; % Change this to output you want

% Change these based off of inclination angle/tire type (see Teams)
idxRange50 = 5006:6220;
idxRange100 = 7491:8645;
idxRange150 = 3754:4937;
idxRange200 = 2546:3667;
idxRange250a = 1:2484;
idxRange250b = 6255:7418;

curFile = load(dataFile);
disp("Loaded " + dataFile);

runTable = table(curFile.AMBTMP, curFile.ET, curFile.FX, curFile.FY, curFile.FZ, curFile.IA, curFile.MX, curFile.MZ, ...
    curFile.N, curFile.NFX, curFile.NFY, curFile.P, curFile.RE, curFile.RL, curFile.RST, ...
    curFile.SA, curFile.SL, curFile.SR, curFile.TSTC, curFile.TSTI, curFile.TSTO, curFile.V, ...
    'VariableNames', {'AmbientRoomTemperature', 'ElapsedTime', 'LongitudinalForce', 'LateralForce', ...
    'NormalForce', 'InclinationAngle', 'OverturningMoment', 'AligningTorque', 'WheelRotationalSpeed', ...
    'NormalizedLongitudinalForce(FX/FZ)', 'NormalizedLateralForce(FY/FZ)', 'TirePressure', ...
    'EffectiveRadius', 'LoadedRadius', 'RoadSurfaceTemperature', 'SlipAngle', 'SlipRatioTextbook', ...
    'SlipRatioBasedOnRL', 'TireSurfaceTemperature-Center', 'TireSurfaceTemperature-Inboard', ...
    'TireSurfaceTemperature-Outboard', 'RoadSpeed'});

runTable.testid = repmat(string(curFile.testid), height(runTable), 1);
runTable.tireid = repmat(string(curFile.tireid), height(runTable), 1);
runTable.Index = (1:height(runTable))';

disp("Run table created with " + height(runTable) + " rows.");

subTables = struct();

subTables.FZ50 = runTable(idxRange50, :);
subTables.FZ100 = runTable(idxRange100, :);
subTables.FZ150 = runTable(idxRange150, :);
subTables.FZ200 = runTable(idxRange200, :);
subTables.FZ250 = [runTable(idxRange250a, :); runTable(idxRange250b, :)];

outNames = fieldnames(subTables);
for i = 1:numel(outNames)
<<<<<<< HEAD
    fname = fullfile(outputFolder, sprintf("R20_FZ_%s.csv", outNames{i}(3:end))); % Change this for tire type/inclination angle
=======
    fname = fullfile(outputFolder, sprintf("R20_FZ_%s.csv", outNames{i}(3:end)));
>>>>>>> main
    writetable(subTables.(outNames{i}), fname);
    disp("Saved: " + fname);
end

disp("All FZ bin CSV files successfully exported.");