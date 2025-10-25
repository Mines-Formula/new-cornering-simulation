clc, clearvars, clear all

inputFile = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_filtered_table.csv';
filteredTable = readtable(inputFile);

% These values are the ones where slip angle is moving
ranges = [13.0, 91.86; 239.92, 460.94; 716.424, 903.17];

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

plot(t, NF, 'b-', 'LineWidth', 1.5); % Normal Force (blue line)
hold on;
plot(t, SA, 'r-', 'LineWidth', 1.5); % Slip Angle (red line)
hold off;

grid on;
xlabel('Elapsed Time (s)');
ylabel('Value');
title('Normal Force and Slip Angle vs Time');
legend('Normal Force (N)', 'Slip Angle (deg)', 'Location', 'best');