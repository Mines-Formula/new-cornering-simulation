clc, clearvars, clear all

path = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';
allDataPath = fullfile(path, 'R20_filtered_table.csv');
extraDataPath = fullfile(path, 'R20_allData.csv');
rangeDataPath = fullfile(path, 'R20_ranges.csv');

allData = readtable(allDataPath);
rangeData = readtable(rangeDataPath);
extraData = readtable(extraDataPath);

validTimes = rangeData.ElapsedTime;

timeRanges = [13.0, 91.86; 239.92, 460.94; 716.424, 903.17];

mask = false(height(allData), 1);
for i = 1:size(timeRanges, 1)
    mask = mask | (allData.ElapsedTime >= timeRanges(i, 1) & allData.ElapsedTime <= timeRanges(i, 2));
end

filteredAll = allData(mask, :);
filteredMoreAll = extraData(mask, :);
disp("Finished Masking");

filteredAll = sortrows(filteredAll, "ElapsedTime");
filtereMoreAll = sortrows(filteredMoreAll, "ElapsedTime");

figure('Position', [200 200 900 600]);

t = filteredAll.ElapsedTime;

subplot(3, 1, 1);
plot(t, filteredAll.NormalForce, 'b');
xlabel('Elapsed Time (s)');
ylabel('Normal Force (N)');
title('Normal Force vs. Time');
grid on;

subplot(3,1,2);
plot(t, filteredAll.SlipAngle, 'r');
xlabel('Elapsed Time (s)');
ylabel('Slip Angle (deg)');
title('Slip Angle vs. Time');
grid on;

subplot(3,1,3);
plot(t, filteredAll.TirePressure, 'Color', [0.1 0.6 0.1], 'LineWidth', 1.5);
xlabel('Elapsed Time (s)');
ylabel('Tire Pressure (PSI)');
title('Tire Pressure vs. Time');
grid on;




sgtitle('Parameter Behavior in Selected Ranges (R20 Test)');


%outFile = fullfile(basePath, 'R20_infoTable_filteredByRanges.csv');
%writetable(filteredAll, outFile);
%disp("Filtered data saved to: " + outFile);