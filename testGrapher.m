clc, clearvars, clear all

path = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';
allDataPath = fullfile(path, 'R20_infoTable.csv');
rangeDataPath = fullfile(path, 'R20_ranges.csv');

allData = readtable(allDataPath);
rangeData = readtable(rangeDataPath);

validTimes = rangeData.ElapsedTime;

timeRanges = [13.0, 91.86; 239.92, 460.94; 716.424, 903.17];

mask = false(height(allData), 1);
for i = 1:size(timeRanges, 1)
    mask = mask | (allData.ElapsedTime >= timeRanges(i, 1) & allData.ElapsedTime <= timeRanges(i, 2));
end

filtereAll = allData(mask, :);
disp("Finished Masking");

