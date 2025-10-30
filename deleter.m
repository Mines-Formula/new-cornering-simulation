clc, clearvars, clear all

inputFile = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_filtered_table.csv';
filteredTable = readtable(inputFile);

% These values are the ones where slip angle is moving
ranges = [12.59, 92.96; 239.67, 461.73; 715.954, 904.31];

mask = false(height(filteredTable), 1);
for i = 1:size(ranges, 1)
    mask = mask | (filteredTable.ElapsedTime >= ranges(i, 1) & filteredTable.ElapsedTime <= ranges(i, 2));
end

trimmedTable = filteredTable(mask, :);

roundedNormalForce = round(trimmedTable.NormalForce / 50) * 50;
maskNonZero = roundedNormalForce ~= 0;
trimmedTable = trimmedTable(maskNonZero, :);


outFile = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_ranges.csv';
writetable(trimmedTable, outFile);

disp("File saved");

figure;
t = trimmedTable.ElapsedTime;
NF = trimmedTable.NormalForce;
SA = trimmedTable.SlipAngle;
CF = trimmedTable.LateralForce;

plot(t, NF, 'b-', 'LineWidth', 1.5); % Normal Force (blue line)
hold on;
plot(t, SA, 'r-', 'LineWidth', 1.5); % Slip Angle (red line)
hold on;
plot(t, CF, 'g-', 'LineWidth', 1.5);
hold off;

grid on;
xlabel('Elapsed Time (s)');
ylabel('Value');
title('Normal Force and Slip Angle vs Time');
legend('Normal Force (N)', 'Slip Angle (deg)', 'Location', 'best');