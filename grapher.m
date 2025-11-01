clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';
csvFiles = dir(fullfile(dataFolder, 'R20_FZ_*_filtered.csv'));

allData = table();
FZValues = zeros(numel(csvFiles),1);

for i = 1:numel(csvFiles)
    filePath = fullfile(csvFiles(i).folder, csvFiles(i).name);
    table = readtable(filePath);
    tokens = regexp(csvFiles(i).name, 'FZ_(\d+)', 'tokens');
    if ~isempty(tokens)
        FZval = str2double(tokens{1}{1});
    else
        FZval = i * 100;
    end
    FZValues(i) = FZval;

    table.FZbin = repmat(FZval, height(table), 1);
    allData = [allData; table];
end

[~, sortIdx] = sort(FZValues);
FZValues = FZValues(sortIdx);
colors = turbo(numel(FZValues));

figure('Name', 'All FZ Combined', 'NumberTitle', 'off');
hold on;
for i = 1:numel(FZValues)
    FZVal = FZValues(i);
    table - allData(allData.FZbin == FZval, :);

    scatter(table.SlipAngle, table.LateralForce, 10, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none', 'DisplayName', sprintf('FZ = %d N', FZval));
end

