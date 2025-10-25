clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/Round9';
fileList = dir(fullfile(dataFolder, "*.mat"));
targetTire = 'Hoosier 43070 16x6.0-10 R20, 7 inch rim';

allTables = cell(numel(fileList), 1);

for i = 1:numel(fileList)
    filePath = fullfile(fileList(i).folder, fileList(i).name);
    curFile = load(filePath);

    if ~strcmp(curFile.tireid, targetTire)
        continue
    end

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
    runTable.Index = strcat(fileList(i).name, "_Line", string((1:height(runTable))'));

    allTables{i} = runTable;
end

% Combine all runs once
Table = vertcat(allTables{:});

% Vectorized cleanup
finalTable = Table(:, ["RoadSpeed", "TirePressure", "InclinationAngle", "NormalForce", "SlipAngle", "Index"]);
finalTable.RoadSpeed = round(finalTable.RoadSpeed);
finalTable.TirePressure = floor(finalTable.TirePressure);
finalTable.InclinationAngle = floor(finalTable.InclinationAngle * 10) / 10;

% Sort and save
finalTable = sortrows(finalTable, ["RoadSpeed", "TirePressure", "InclinationAngle"]);
outFile = fullfile('/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation', "R20_infoTable.csv");
writetable(finalTable, outFile);

disp("Finished");
