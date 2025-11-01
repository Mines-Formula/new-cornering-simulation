clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/Output/LC0Round19';
csvFiles = dir(fullfile(dataFolder, 'LC0_FZ_*_Round19_filtered.csv'));

allData = table();
FZValues = zeros(numel(csvFiles),1);

for i = 1:numel(csvFiles)
    filePath = fullfile(csvFiles(i).folder, csvFiles(i).name);
    table = readtable(filePath);
    tokens = regexp(csvFiles(i).name, 'FZ_(\d+)', 'tokens');
    if ~isempty(tokens)
        FZVal = str2double(tokens{1}{1});
    else
        FZVal = i * 100;
    end
    FZValues(i) = FZVal;

    table.FZbin = repmat(FZVal, height(table), 1);
    allData = [allData; table];
end

[~, sortIdx] = sort(FZValues);
FZValues = FZValues(sortIdx);
colors = turbo(numel(FZValues));

figCombined = figure('Name', 'All FZ Combined', 'NumberTitle', 'off');
hold on;
for i = 1:numel(FZValues)
    FZVal = FZValues(i);
    table = allData(allData.FZbin == FZVal, :);

    scatter(table.SlipAngle, table.LateralForce, 5, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none', 'DisplayName', sprintf('FZ = %d N', FZVal));
end

hold off;
grid on;
xlabel('Slip Angle (deg)');
ylabel('Lateral Force FY (N)');
title('Lateral Force vs Slip Angle (All Loads)');
legend('Location', 'bestoutside');
colormap(colors);
c = colorbar;
c.Ticks = linspace(0, 1, numel(FZValues));
c.TickLabels = string(FZValues);
c.Label.String = 'Normal Force (FZ, N)';

outCombinedPath = fullfile(dataFolder, 'LC0_All_FZ_Combined_Round19.png');
exportgraphics(figCombined, outCombinedPath, 'Resolution', 300);
disp(['Saved combined plot: ', outCombinedPath]);

for i = 1:numel(FZValues)
    FZVal = FZValues(i);
    table = allData(allData.FZbin == FZVal, :);

    figSingle = figure('Name', sprintf('FZ_%d', FZVal), 'NumberTitle', 'off');
    scatter(table.SlipAngle, table.LateralForce, 5, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none');
    grid on;
    xlabel('Slip Angle (deg)');
    ylabel('Lateral Force FY (N)');
    title(sprintf('Lateral Force vs Slip Angle — FZ = %d N', FZVal));

    outPath = fullfile(dataFolder, sprintf('LC0_FZ_%d_Plot_Round19.png', FZVal));
    exportgraphics(figSingle, outPath, 'Resolution', 300);
    disp(['Saved plot: ', outPath]);

end

disp("All filtered FZ datasets plotted successfully.");