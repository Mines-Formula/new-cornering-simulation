clc, clearvars, clear all

dataPath = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_ranges.csv';
data = readtable(dataPath);

data = data(data.SlipAngle < -0.2 | data.SlipAngle > 0.2, :);

FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;
FY_exp = data.LateralForce;

P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = [1, 1, 1, 1, 1, 1, 1, 1];

FY = pacejka(P, L, FZ, IA, alpha);

data.FY = FY;

outFile = fullfile('/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation', 'R20_with_FY.csv');
writetable(data, outFile);
disp("Finished");

FZ_binned = round(FZ / 50) * 50;

% Graph comparison of the two

[alphaSorted, idx] = sort(alpha);
FY_exp_sorted = FY_exp(idx);
FY_calc_sorted = FY(idx);


figure;
scatter(alphaSorted, FY_exp_sorted, 10, 'r', 'filled', 'DisplayName', 'Experimental FY');
hold on;
scatter(alphaSorted, FY_calc_sorted, 10, 'b', 'filled', 'DisplayName', 'Calculated FY (Pacejka)');
hold off;

grid on;
xlabel('Slip Angle (deg)');
ylabel('Lateral Force FY (N)');
title('Experimental vs. Calculated Lateral Force (Pacejka Model)');
legend('Location', 'best');

rmse = sqrt(mean((FY - FY_exp).^2));
disp(['RMSE between experimental and calculated FY: ', num2str(rmse, '%.3f'), ' N']);