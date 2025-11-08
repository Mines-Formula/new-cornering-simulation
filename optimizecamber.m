clc; clear; close all;
data0 = readtable('R20_combined_filtered.csv');
data2 = readtable('R20_IA-2_combined_filtered.csv');
data4 = readtable('R20_IA-4_combined_filtered.csv');
data = [data0;data2;data4];
% Column meanings
IA = data{:,3};            % Inclination angle (held constant at 0)
FZRaw = data{:,4};        % Normal force
alpha = data{:,5};         % Slip angle (deg)
FYExperimental = data{:,7};        % Experimental lateral force
source = data{:,9};        % Source file name
bins = [50, 100, 150, 200, 250];
FYAll = [];
FZAll = [];
alphaAll = [];
IAAll = [];
for i = 1:numel(bins)
    tag2 = sprintf('R20_FZ_%d_IA-2_filtered', bins(i));
    tag4 = sprintf('R20_FZ_%d_IA-4_filtered', bins(i));
    tag = sprintf('R20_FZ_%d_filtered', bins(i));
    idx = contains(source, tag) | contains(source, tag2) | contains(source, tag4);
    FYAll = [FYAll; FYExperimental(idx)];
    FZAll = [FZAll; bins(i) * ones(sum(idx),1)];
    alphaAll = [alphaAll; alpha(idx)];
    IAAll = [IAAll; IA(idx)];
end
alphaAll = deg2rad(alphaAll);
P0 = [250, 1.53458, 2.366, -0.202526, 3, 0.214146, -0.825856, 0, 0, -30.6211, 1.25718, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = ones(1,8);
objFun = @(P) FYExperimental_all(P, L, FZAll, IAAll, alphaAll, FYAll);
options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 20000, 'TolFun', 1e-8, 'TolX', 1e-8);
lb = -Inf(1,19);
ub = Inf(1,19);
% Fix PEY2, PEY3, PEY4, PHY2, PVY2 to zero
fixedIdx = [8, 9, 13, 14, 16, 17, 18]; % Parameter positions to fix
lb(fixedIdx) = 0;
ub(fixedIdx) = 0;
lb(1) = 250;
ub(1) = 250;
lb(2) = P0(2);
ub(2) = P0(2);
lb(3) = P0(3);
ub(3) = P0(3);
lb(4) = P0(4);
ub(4) = P0(4);
lb(6) = P0(6);
ub(6) = P0(6);
lb(7) = P0(7);
ub(7) = P0(7);
lb(10) = P0(10);
ub(10) = P0(10);
lb(11) = P0(11);
ub(11) = P0(11);
%lb(12) = P0(12);
%ub(12) = P0(12);
POptimization = lsqnonlin(objFun, P0, lb, ub, options);
disp('Optimized Parameters:')
disp(POptimization)
FYPredicted = pacejka(POptimization, L, FZAll, IAAll, alphaAll);
rmse = sqrt(mean((FYAll - FYPredicted).^2));
fprintf('Overall RMSE: %.3f\n', rmse);
disp('Available bins: [50, 100, 150, 200, 250]');
plot_choice = input('Enter FZ bin to plot (or "all" for all bins): ', 's');
figure; hold on; grid on;
colors = lines(numel(bins));
if strcmpi(plot_choice, 'all')
    % Plot all bins together
    for i = 1:numel(bins)
        idx = FZAll == bins(i);
        scatter(rad2deg(alphaAll(idx)), FYAll(idx), 2, colors(i,:), 'filled', 'DisplayName', sprintf('Exp FZ=%d', bins(i)));
        [alphaSort, ord] = sort(alphaAll(idx));
        FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
        plot(rad2deg(alphaSort), FYFit, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', sprintf('Fit FZ=%d', bins(i)));
    end
    title(sprintf('Pacejka Fit (All Bins) - RMSE = %.2f', rmse));
else
    % Plot only the selected bin
    binValue = str2double(plot_choice);
    if isnan(binValue) || ~ismember(binValue, bins)
        error('Invalid bin selection. Must be one of: %s', num2str(bins));
    end
    idx = FZAll == binValue;
    scatter(rad2deg(alphaAll(idx)), FYAll(idx), 2, 'filled', 'DisplayName', sprintf('Exp FZ=%d', binValue), 'MarkerFaceColor', [0.3 0.3 0.9]);
    [alphaSort, ord] = sort(alphaAll(idx));
    FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
    plot(rad2deg(alphaSort), FYFit, 'r', 'LineWidth', 1.5, 'DisplayName', sprintf('Fit FZ=%d', binValue));
    title(sprintf('Pacejka Fit (FZ = %d N) - RMSE = %.2f', binValue, rmse));
end
xlabel('Slip Angle [deg]');
ylabel('Lateral Force FY');
legend('Location', 'best');
fprintf('Overall RMSE: %.3f\n', rmse);
fprintf('[');
fprintf('%g, ', POptimization(1:end-1));
fprintf('%g]\n', POptimization(end));
function err = FYExperimental_all(P, L, FZ, IA, alpha, FYExperimental)
    FYModel = pacejka(P, L, FZ, IA, alpha);
    err = FYModel - FYExperimental;   % residuals for lsqnonlin
end