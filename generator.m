clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/documentation/data/runData';
fileList = dir(fullfile(dataFolder, "*.mat"));

finalTable = table();

targetTire = 'Hoosier 43070 16x6.0-10 R20, 6 inch rim'; % Change to 7 inch rim

for i = 1:numel(fileList)

    filePath = fullfile(fileList(i).folder, fileList(i).name);
    curFile = load(filePath);

    if string(curFile.tireid) ~= targetTire
        fprintf("Skipping %s (tireid = %s)\n", ...
            fileList(i).name, curFile.tireid);
        continue
    end

    runTable = table(curFile.AMBTMP, curFile.ET, curFile.FX, curFile.FY, curFile.FZ, curFile.IA, curFile.MX, curFile.MZ, curFile.N, curFile.NFX, curFile.NFY, curFile.P, curFile.RE, curFile.RL, curFile.RST, curFile.SA, curFile.SL, curFile.SR, curFile.TSTC, curFile.TSTI, curFile.TSTO, curFile.V, 'VariableNames', {'AmbientRoomTemperature', 'ElapsedTime', 'LongitudinalForce', 'LateralForce', 'NormalForce', 'InclinationAngle', 'OverturningMoment', 'AligningTorque', 'WheelRotationalSpeed', 'NormalizedLongitudinalForce(FX/FZ)', 'NormalizedLateralForce(FY/FZ)', 'TirePressure', 'EffectiveRadius', 'LoadedRadius', 'RoadSurfaceTemperature', 'SlipAngle', 'SlipRatioTextbook', 'SlipRatioBasedOnRL', 'TireSurfaceTemperature-Center', 'TireSurfaceTemperature-Inboard', 'TireSurfaceTemperature-Outboard', 'RoadSpeed'});
    
    runTable.testid = repmat(string(curFile.testid), height(runTable), 1);
    runTable.tireid = repmat(string(curFile.tireid), height(runTable), 1);

    finalTable = [finalTable; runTable];
    disp("Table done")

end

outFile = fullfile(dataFolder, "R20.csv");
writetable(finalTable, outFile);
disp("Finished");