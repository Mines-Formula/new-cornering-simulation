clc, clearvars, clear all

dataFile = '/Users/Blanchards1/Documents/Round9/A2356run6.mat';
outputFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';

idxRange50 = 3796:4977;
idxRange100 = 6248:7451;
idxRange150 = 2506:3704;
idxRange200 = 1259:2420;
idxRange250a = 1:1236;
idxRange250b = 4997:6222;

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
    fname = fullfile(outputFolder, sprintf("R20_FZ_%s_Round6.csv", outNames{i}(3:end)));
    writetable(subTables.(outNames{i}), fname);
    disp("Saved: " + fname);
end

disp("All FZ bin CSV files successfully exported.");