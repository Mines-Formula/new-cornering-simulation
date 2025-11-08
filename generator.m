clc, clearvars, clear all

dataFile = '/Users/Blanchards1/Documents/Round9/A1965run18.mat';
outputFolder = '/Users/Blanchards1/Documents/FormulaSim/Output/LC0Round18';

idxRange50 = 10010:11225;
idxRange100 = 12501:13726;
idxRange150 = 8761:9979;
idxRange200 = 7510:8732;
idxRange250a = 11253:12474;
%idxRange250b = 5014:6233;

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
subTables.FZ250 = runTable(idxRange250a, :);

outNames = fieldnames(subTables);
for i = 1:numel(outNames)
    fname = fullfile(outputFolder, sprintf("LC0_FZ_%s_Round18_IA_2.csv", outNames{i}(3:end)));
    writetable(subTables.(outNames{i}), fname);
    disp("Saved: " + fname);
end

disp("All FZ bin CSV files successfully exported.");