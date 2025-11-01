clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';

csvFiles = dir(fullfile(dataFolder, "R20_FZ_*.csv"));

for i = 1:numel(csvFiles)
    curFile = fullfile(csvFiles(i).folder, csvFiles(i).name);
    disp("Processing " + csvFiles(i).name);

    table = readtable(curFile);
    varNames = ["RoadSpeed", "TirePressure", "InclinationAngle", "NormalForce", "SlipAngle", "ElapsedTime", "LateralForce", "Index"];
    table = table(:, varNames);

    table.RoadSpeed = round(table.RoadSpeed);
    table.TirePressure = floor(table.TirePressure);
    table.InclinationAngle = floor(table.InclinationAngle * 10) / 10;

    table = sortrows(table, ["RoadSpeed", "TirePressure", "InclinationAngle"]);
    filteredTable = table(table.InclinationAngle == 0 & table.RoadSpeed == 25 & table.TirePressure == 12, :);

    filteredTable = sortrows(filteredTable, "ElapsedTime");

    [~, name, ~] = fileparts(csvFiles(i).name);
    outName = sprintf('%s_filtered.csv', name);
    outPath = fullfile(dataFolder, outName);
    writetable(filteredTable, outPath);

    disp("Saved filtered version: " + outName);

    figure('Name', outName, 'NumberTitle', 'off');
    t = filteredTable.ElapsedTime;
    NF = filteredTable.NormalForce;
    SA = filteredTable.SlipAngle;
    CF = filteredTable.LateralForce;

    plot(t, NF, 'b-', 'LineWidth', 1.5); hold on;
    plot(t, SA, 'r-', 'LineWidth', 1.5);
    plot(t, CF, 'g-', 'LineWidth', 1.5);
    hold off;

    grid on;
    xlabel('Elapsed Time (s)');
    ylabel('Value');
    title(strrep(outName, '_', '\_'));
    legend('Normal Force (N)', 'Slip Angle (deg)', 'Lateral Force (N)', 'Location', 'best');

    saveas(gcf, fullfile(dataFolder, sprintf('%s_plot.png', name)));
    close(gcf);

    disp("Plot saved: " + name + "_plot.png");
end

disp("✅ All FZ bins processed, filtered, and plotted successfully.");