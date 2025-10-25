clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/R20Data2';
fileList = dir(fullfile(dataFolder, "*.mat"));
targetTire = 'Hoosier 43070 16x6.0-10 R20, 7 inch rim';

allTables = cell(numel(fileList), 1);

for i = 1:numel(fileList)
    filePath = fullfile(fileList(i).folder, fileList(i).name);
    curFile = load(filePath);

    if ~strcmp(curFile.tireid, targetTire)
        disp(fileList(i).name);
        disp("skipped");
        continue
    end

    disp(fileList(i).name);
    disp("Chosen");

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

Table = vertcat(allTables{:});

finalTable = Table(:, ["RoadSpeed", "TirePressure", "InclinationAngle", "NormalForce", "SlipAngle", "ElapsedTime", "LateralForce", "Index"]);
finalTable.RoadSpeed = round(finalTable.RoadSpeed);
finalTable.TirePressure = floor(finalTable.TirePressure);
finalTable.InclinationAngle = floor(finalTable.InclinationAngle * 10) / 10;


finalTable = sortrows(finalTable, ["RoadSpeed", "TirePressure", "InclinationAngle"]);
outFile = fullfile('/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation', "R20_infoTable.csv");
writetable(finalTable, outFile);

disp("Finished OG Table");

filteredTable = finalTable(finalTable.InclinationAngle == 0 & finalTable.RoadSpeed == 25 & finalTable.TirePressure == 12, :);

filteredTable = sortrows(filteredTable, "ElapsedTime");

[~, idx] = sortrows([filteredTable.ElapsedTime, -filteredTable.SlipAngle]); % sort by time asc, slip desc
[~, ia] = unique(filteredTable.ElapsedTime, 'stable'); % keep first occurrence (max slip)
filteredTable = filteredTable(sort(ia), :);

%Output the file
outFilteredFile = fullfile('/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation', "R20_filtered_table.csv");
writetable(filteredTable, outFilteredFile);

disp("FilteredTableSaved");

figure;
t = filteredTable.ElapsedTime;
NF = filteredTable.NormalForce;
SA = filteredTable.SlipAngle;

plot(t, NF, 'b-', 'LineWidth', 1.5); % Normal Force (blue line)
hold on;
plot(t, SA, 'r-', 'LineWidth', 1.5); % Slip Angle (red line)
hold off;

grid on;
xlabel('Elapsed Time (s)');
ylabel('Value');
title('Normal Force and Slip Angle vs Time');
legend('Normal Force (N)', 'Slip Angle (deg)', 'Location', 'best');