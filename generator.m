clc, clearvars, clear all

dataFolder = 'C:\Users\ajsau\Downloads\RunData_Cornering_Matlab_USCS_10inch_Round8';
fileList = dir(fullfile(dataFolder, "*.mat"));

Table = table();

targetTire = 'Hoosier 43075 16x7.5-10 LCO, 7 inch rim';
for i = 1:numel(fileList)
    filePath = fullfile(fileList(i).folder, fileList(i).name);
    curFile = load(filePath);

    if string(curFile.tireid) ~= targetTire
        fprintf("Skipping %s (tireid = %s)\n", ...
            fileList(i).name, curFile.tireid);
        continue
    end

    runTable = table(curFile.AMBTMP, curFile.ET, curFile.FX, curFile.FY, curFile.FZ, curFile.IA, curFile.MX, curFile.MZ, curFile.N, curFile.NFX, curFile.NFY, curFile.P, curFile.RE, curFile.RL, curFile.RST, curFile.SA, curFile.SL, curFile.SR, curFile.TSTC, curFile.TSTI, curFile.TSTO, curFile.V, 'VariableNames', {'AmbientRoomTemperature', 'ElapsedTime', 'LongitudinalForce', 'LateralForce', 'NormalForce', 'InclinationAngle', 'OverturningMoment', 'AligningTorque', 'WheelRotationalSpeed', 'NormalizedLongitudinalForce(FX/FZ)', 'NormalizedLateralForce(FY/FZ)', 'TirePressure', 'EffectiveRadius', 'LoadedRadius', 'RoadSurfaceTemperature', 'SlipAngle', 'SlipRatioTextbook', 'SlipRatioBasedOnRL', 'TireSurfaceTemperature-Center', 'TireSurfaceTemperature-Inboard', 'TireSurfaceTemperature-Outboard', 'RoadSpeed'});
    time = double(table2array(runTable(1, "ElapsedTime")));
    n=0;
    while (floor(time*10^n)~=time*10^n)
        n=n+1;
    end
    n = 10^(n-1);
    %issue: some go to 2 decimal places, others go to 3 - calculate which
    %is wich
    if n >= 1
        disp(n > 0)
        runTable = runTable(n:n:end,:);
    end

    runTable.testid = repmat(string(curFile.testid), height(runTable), 1);
    runTable.tireid = repmat(string(curFile.tireid), height(runTable), 1);

    rows = height(runTable);
    for j= 1:rows
        index = fileList(i).name + "_Line"+ j;
        runTable.Index(j) = index;
    end

    Table = [Table; runTable];
    disp("Table done")

end

function [newTable] = genericSort(startTable, sortVars)
    newTable = sortrows(startTable, sortVars);
    %writetable(newTable, outFile);
    %disp("Finished sort.")
end

rows = height(Table);
finalTable = table();
for i = 1:rows
    finalTable.RoadSpeed(i) = table2array(Table(i, "RoadSpeed"));
    tp = table2array(Table(i, "TirePressure"));
    tp = tp - mod(tp, 1);
    finalTable.TirePressure(i) = tp;
    ia = table2array(Table(i, "InclinationAngle"));
    ia = ia - mod(ia, 0.1);
    finalTable.InclinationAngle(i) = ia;
    finalTable.NormalForce(i) = table2array(Table(i, "NormalForce"));
    finalTable.Index(i) = table2array(Table(i, "Index"));
end


finalTable = genericSort(finalTable, ["RoadSpeed", "TirePressure", "InclinationAngle"]);
dataFolder = 'C:\Users\ajsau\Documents\formula\corneringSim\cornering-simulation';
outFile = fullfile(dataFolder, "LCO_infoTable.csv");
writetable(finalTable, outFile);
disp("Finished");