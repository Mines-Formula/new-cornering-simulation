clc, clearvars, clear all

dataFile = '/Users/Blanchards1/Documents/Round9/A2356run4.mat';
outputFolder = '/Users/Blanchards1/Documents/FormulaSim/Output/R20Round4&5';

idxRange50 = 17450:18640;
idxRange100 = 19942:21169;
idxRange150 = 16205:17419;
idxRange200 = 14961:16162;
idxRange250a = 18696:19922;
%idxRange250b = 6255:7418;

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
    fname = fullfile(outputFolder, sprintf("R20_FZ_%s_IA-4.csv", outNames{i}(3:end)));
    writetable(subTables.(outNames{i}), fname);
    disp("Saved: " + fname);
end

disp("All FZ bin CSV files successfully exported.");