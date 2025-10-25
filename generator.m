clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/documentation/Round9';
fileList = dir(fullfile(dataFolder, "*.mat"));

finalTable = table();

<<<<<<< Updated upstream
targetTire = 'Hoosier 43070 16x6.0-10 R20, 7 inch rim'; % Change to 7 inch rim
=======
targetTire = 'Hoosier 43075 16x7.5-10 R20, 7 inch rim'; % Change to 7 inch rim
>>>>>>> Stashed changes

for i = 1:numel(fileList)
    filePath = fullfile(fileList(i).folder, fileList(i).name);
    curFile = load(filePath);

    % --- Safety checks ---
    if ~isfield(curFile, 'tireid') || ~isfield(curFile, 'testid')
        fprintf("Skipping %s (missing tireid or testid)\n", fileList(i).name);
        continue
    end

    if string(curFile.tireid) ~= targetTire
        fprintf("Skipping %s (tireid = %s)\n", fileList(i).name, curFile.tireid);
        continue
    end

    % --- Check that all required fields exist ---
    requiredFields = {'FZ', 'IA', 'P'};
    if ~all(isfield(curFile, requiredFields))
        fprintf("Skipping %s (missing one of required fields: FZ, IA, P)\n", fileList(i).name);
        continue
    end

    % --- Ensure column vectors ---
    FZ = abs(curFile.FZ(:));
    IA = curFile.IA(:);
    P  = curFile.P(:);

    % --- Get testid as a string for this file ---
    testid = string(curFile.testid);
    testidCol = repmat(testid, numel(FZ), 1);
    tireidCol = repmat(string(curFile.tireid), numel(FZ), 1);

    % --- Now safely create the table ---
    runTable = table(FZ, IA, P, testidCol, tireidCol, ...
        'VariableNames', {'NormalForce', 'InclinationAngle', 'TirePressure', 'testid', 'tireid'});

    finalTable = [finalTable; runTable];
    fprintf("Processed %s\n", fileList(i).name);
end

disp("All data loaded.");

% --- Round and extract unique combinations ---
finalTable.Pressure_PSI = round(finalTable.TirePressure);
finalTable.IA_deg = round(finalTable.InclinationAngle);
finalTable.Fz_lb = abs(round(finalTable.NormalForce, 1));

summaryData = unique(finalTable(:, {'Pressure_PSI', 'IA_deg', 'Fz_lb'}));

% --- Create the 'Data file/structure' name format ---
summaryData.Data_file_structure = strcat("<tire>_", ...
    string(summaryData.Pressure_kPa), "_", ...
    string(summaryData.IA_deg), "_", ...
    string(round(summaryData.Fz_N)), "_cornering");

% --- Sort for readability ---
summaryData = sortrows(summaryData, {'Pressure_PSI', 'IA_deg', 'Fz_lb'});

% --- Write to CSV ---
outSummary = fullfile(dataFolder, "R20_summary.csv");
writetable(summaryData, outSummary);

disp("Summary table created and saved.");
