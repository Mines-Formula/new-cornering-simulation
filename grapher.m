clc, clearvars, clear all

dataPath = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_with_FY.csv';
data = readtable(dataPath);

FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;
FY_exp = data.LateralForce;
FY = data.FY;
time = data.ElapsedTime;

FZ_binned = round(FZ / 50) * 50;

% Graph comparison of the two

[alphaSorted, idx] = sort(alpha);
FY_exp_sorted = FY_exp(idx);
FY_calc_sorted = FY(idx);
FZ_binned_sorted = FZ_binned(idx);
timeSorted = time(idx);

uniqueBins = unique(FZ_binned_sorted);
numBins = numel(uniqueBins);
colors = turbo(numBins);

timeWindows = [13.0, 91.86; 239.92, 460.94; 716.424, 903.17];

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
