clc, clearvars, clear all

dataPath = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_ranges.csv';
data = readtable(dataPath);

FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;
FY_exp = data.LateralForce;
%FY = data.FY;
time = data.ElapsedTime;

FZ_binned = round(FZ / 50) * 50;

invalidBins = [0, -50, -300, -350];
validMask = ~ismember(FZ_binned, invalidBins);

FZ = FZ(validMask);
IA = IA(validMask);
alpha = alpha(validMask);
FY_exp = FY_exp(validMask);
time = time(validMask);
FZ_binned = FZ_binned(validMask);

% Graph comparison of the two

[alphaSorted, idx] = sort(alpha);
FY_exp_sorted = FY_exp(idx);
%FY_calc_sorted = FY(idx);
FZ_binned_sorted = FZ_binned(idx);
timeSorted = time(idx);

uniqueBins = unique(FZ_binned_sorted);
numBins = numel(uniqueBins);
colors = turbo(numBins);

timeWindows = [12.64, 91.83; 239.67, 461.73; 715.954, 904.31];

for w = 1:size(timeWindows, 1)
    tStart = timeWindows(w, 1);
    tEnd = timeWindows(w, 2);

    timeMask = (timeSorted >= tStart) & (timeSorted <= tEnd);

    figure;
    hold on;

    for i = 1:numBins
        binMask = (FZ_binned_sorted == uniqueBins(i)) & timeMask;
        if any(binMask)
            scatter(alphaSorted(binMask), FY_exp_sorted(binMask), 10, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none', 'DisplayName', sprintf('Exp FY - FZ ≈ %d', uniqueBins(i)));
        end
    end

    hold off;
    grid on;
    xlabel('Slip Angle');
    ylabel('Lateral Force FY');

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
