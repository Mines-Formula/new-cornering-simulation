clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/Output/R20Round4&5';

filteredFiles = dir(fullfile(dataFolder, '*_filtered.csv'));

combinedTable = table();

for i = 1:numel(filteredFiles)
    curFile = fullfile(filteredFiles(i).folder, filteredFiles(i).name);
    disp("Adding " + filteredFiles(i).name);

    tempTable = readtable(curFile);

    [~, name, ~] = fileparts(filteredFiles(i).name);
    tempTable.SourceFile = repmat({name}, height(tempTable), 1);

    combinedTable = [combinedTable; tempTable];
end

combinedTable = sortrows(combinedTable, 'NormalForce');

outPath = fullfile(dataFolder, 'R20_combined_filtered.csv');
writetable(combinedTable, outPath);

disp("Combined filtered data saved as: " + outPath);
