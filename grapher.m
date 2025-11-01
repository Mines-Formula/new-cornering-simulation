clc, clearvars, clear all

dataPath = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_ranges.csv';
data = readtable(dataPath);

FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;
FY_exp = data.LateralForce;
time = data.ElapsedTime;

targetFZ = [];

%% Define time-based binning rules

binningRules = [
    % Graph 1
    12.64   91.83   250;
    % Graph 2
    239.67  297.15  250;
    297.31  330.97  200;
    331.13  364.77  150;
    365.11  398.55  50;
    398.98  432.28  250;
    432.68  461.73  100;
    % Graph 3
    716.664 739.664 250;
    739.914 773.473 200;
    773.643 802.842 150;
    816.862 836.801 50;
    841.571 874.86  250;
    875.201 904.31  100
];

%% Assign FZ_binned based on time windows
FZ_binned_by_time = zeros(size(time));

for i = 1:size(binningRules, 1)
    tStart = binningRules(i, 1);
    tEnd   = binningRules(i, 2);
    binVal = binningRules(i, 3);

    inRange = (time >= tStart) & (time <= tEnd);
    FZ_binned_by_time(inRange) = binVal;
end

%% Exclude zero slip angle in Graph 3's 816.862–836.801 range
excludeMask = (time >= 816.862 & time <= 836.801) & (abs(alpha) < 1e-3);
FZ_binned_by_time(excludeMask) = 0;

%% Filter invalid (unbinned) data
validMask = FZ_binned_by_time ~= 0;
FZ = FZ(validMask);
IA = IA(validMask);
alpha = alpha(validMask);
FY_exp = FY_exp(validMask);
time = time(validMask);
FZ_binned = FZ_binned_by_time(validMask);

if ~isempty(targetFZ) 
    FZmask = FZ_binned == targetFZ;
    FZ = FZ(FZmask);
    IA = IA(FZmask);
    alpha = alpha(FZmask);
    FY_exp = FY_exp(FZmask);
    time = time(FZmask);
    FZ_binned = FZ_binned(FZmask);
end

%% Graphing setup
[alphaSorted, idx] = sort(alpha);
FY_exp_sorted = FY_exp(idx);
FZ_binned_sorted = FZ_binned(idx);
timeSorted = time(idx);

uniqueBins = unique(FZ_binned_sorted);
numBins = numel(uniqueBins);
colors = turbo(numBins);

timeWindows = [12.59, 92.96; 244.89, 291.06; 414.12, 425.77];

%% This is the butterworth sort
%fs = 100;
%fc = 10;
%order = 4;
%[b, a] = butter(order, fc/(fs/2));
%FY_filtered = filtfilt(b, a, FY_exp_sorted);
%alpha_filtered = filtfilt(b, a, alphaSorted);
%FY_exp_sort = FY_filtered;
%alphaSort = alpha_filtered;

%% Diagnosing Plot
figure;
tiledlayout(2,1);


nexttile;
scatter(time, FY_exp, 5, FZ_binned, 'filled');
xlabel('Time (s)');
ylabel('FY (N)');
title('FY vs Time colored by FZ bin');
colorbar;
grid on;


nexttile;
scatter(time, alpha, 5, FZ_binned, 'filled');
xlabel('Time (s)');
ylabel('Slip Angle (deg)');
title('Slip Angle vs Time colored by FZ bin');
grid on;
colorbar;

%% Plot each main time window
for w = 1:size(timeWindows, 1)
    tStart = timeWindows(w, 1);
    tEnd = timeWindows(w, 2);
    timeMask = (timeSorted >= tStart) & (timeSorted <= tEnd);

    figure;
    hold on;

    for i = 1:numBins
        binMask = (FZ_binned_sorted == uniqueBins(i)) & timeMask;
        if any(binMask)
            scatter(alphaSorted(binMask), FY_exp_sorted(binMask), 5, ...
                'MarkerFaceColor', colors(i,:), ...
                'MarkerEdgeColor', 'none', ...
                'DisplayName', sprintf('Exp FY - FZ ≈ %d', uniqueBins(i)));
        end
    end

    hold off;
    grid on;
    xlabel('Slip Angle (deg)');
    ylabel('Lateral Force FY');
    if isempty(targetFZ)
        title(sprintf('Graph %d: Time %.2f–%.2f s (All FZ)', w, tStart, tEnd));
    else
        title(sprintf('Graph %d: Time %.2f–%.2f s (FZ = %d)', w, tStart, tEnd, targetFZ));
    end

    colormap(colors);
    c = colorbar;
    c.Ticks = linspace(0, 1, numBins);
    c.TickLabels = string(uniqueBins);
end




%% Old graphing section
%figure;
%hold on;

%for i = 1:numBins

    %binMask = FZ_binned_sorted == uniqueBins(i);
    %scatter(alphaSorted(binMask), FY_exp_sorted(binMask), 10, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none', 'DisplayName', sprintf('Exp FY - FZ ≈ %d', uniqueBins(i)));
    %scatter(alphaSorted(binMask), FY_calc_sorted(binMask), 10, 'MarkerEdgeColor', colors(i,:), 'MarkerFaceColor', 'none', 'DisplayName', sprintf('Calc FY - FZ ≈ %d', uniqueBins(i)));
%end
%hold off;

%grid on;
%xlabel('Slip Angle (deg)');
%ylabel('Lateral Force FY');
%title('Experimental vs. Calculated Lateral Force Colored by Normal Force');
%legend('Location', 'bestoutside');

%colormap(colors);
%c = colorbar;
%c.Ticks = linspace(0, 1, numBins);
%c.TickLabels = string(uniqueBins);

%rmse = sqrt(mean((FY - FY_exp).^2));
%disp(['RMSE between experimental and calculated FY: ', num2str(rmse, '%.3f')]);
