clc; clear; close all;

data = readtable('R20_combined_filtered.csv');

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
    tag = sprintf('R20_FZ_%d_filtered', bins(i));
    idx = contains(source, tag);
    FYAll = [FYAll; FYExperimental(idx)];
    FZAll = [FZAll; bins(i) * ones(sum(idx),1)];
    alphaAll = [alphaAll; alpha(idx)];
    IAAll = [IAAll; IA(idx)];
end

alphaAll = deg2rad(alphaAll);

P0 = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = ones(1,8);

objFun = @(P) FYExperimental_all(P, L, FZAll, IAAll, alphaAll, FYAll);

options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 20000, 'TolFun', 1e-8, 'TolX', 1e-8);

lb = -Inf(1,19);
ub = Inf(1,19);
% Fix PEY2, PEY3, PEY4, PHY2, PVY2 to zero
fixedIdx = [7, 8, 9, 14, 17]; % Parameter positions to fix
lb(fixedIdx) = 0;
ub(fixedIdx) = 0;

POptimization = lsqnonlin(objFun, P0, lb, ub, options);
disp('Optimized Parameters:')
disp(POptimization)

FYPredicted = pacejka(POptimization, L, FZAll, IAAll, alphaAll);
rmse = sqrt(mean((FYAll - FYPredicted).^2));
fprintf('Overall RMSE: %.3f\n', rmse);


disp('Available bins: [50, 100, 150, 200, 250]');
plot_choice = input('Enter FZ bin to plot (or "all" for all bins): ', 's');

figure; hold on; grid on;
colors = lines(numel(bins));         % base colors for experimental data
fitColors = brighten(colors, -0.4);  % darker shades for the fitted lines

if strcmpi(plot_choice, 'all')
    % Plot all bins together
    for i = 1:numel(bins)
        idx = FZAll == bins(i);

        % Experimental data (scatter)
        scatter(rad2deg(alphaAll(idx)), FYAll(idx), 12, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'DisplayName', sprintf('Exp FZ=%d', bins(i)));

        % Fit line (darker color)
        [alphaSort, ord] = sort(alphaAll(idx));
        FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
        plot(rad2deg(alphaSort), FYFit, 'Color', fitColors(i,:), 'LineWidth', 2, ...
            'DisplayName', sprintf('Fit FZ=%d', bins(i)));
    end
    title(sprintf('Pacejka Fit (All Bins) - RMSE = %.2f', rmse));

else
    % Plot only selected bin
    binValue = str2double(plot_choice);
    if isnan(binValue) || ~ismember(binValue, bins)
        error('Invalid bin selection. Must be one of: %s', num2str(bins));
    end

    idx = FZAll == binValue;
    colorIdx = find(bins == binValue);

    % Experimental points
    scatter(rad2deg(alphaAll(idx)), FYAll(idx), 20, ...
        'MarkerFaceColor', colors(colorIdx,:), ...
        'MarkerEdgeColor', 'none', ...
        'DisplayName', sprintf('Exp FZ=%d', binValue));

    % Fit line
    [alphaSort, ord] = sort(alphaAll(idx));
    FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
    plot(rad2deg(alphaSort), FYFit, 'Color', fitColors(colorIdx,:), 'LineWidth', 2.5, ...
        'DisplayName', sprintf('Fit FZ=%d', binValue));

    title(sprintf('Pacejka Fit (FZ = %d N) - RMSE = %.2f', binValue, rmse));
end

xlabel('Slip Angle [deg]');
ylabel('Lateral Force FY [N]');
legend('Location', 'best');


%terminal output
disp(' ')
disp('Optimized Pacejka Parameters:')
disp('----------------------------------------------')

paramNames = { ...
    'FZ0',  'PCY1', 'PDY1', 'PDY2', 'PDY3', ...
    'PEY1', 'PEY2', 'PEY3', 'PEY4', ...
    'PKY1', 'PKY2', 'PKY3', ...
    'PHY1', 'PHY2', 'PHY3', ...
    'PVY1', 'PVY2', 'PVY3', 'PVY4'};

paramDescriptions = { ...
    'Nominal load (N)'; ...
    'Shape factor'; ...
    'Lateral friction, μy'; ...
    'Variation of friction with load'; ...
    'Variation of friction with camber²'; ...
    'Lateral curvature at FZ0'; ...
    'Variation of curvature with load'; ...
    'Zero-order camber dependency of curvature'; ...
    'Variation of curvature with camber'; ...
    'Max stiffness Ky/FZ0'; ...
    'Normalized load where Ky max'; ...
    'Variation of Ky/FZ0 with camber'; ...
    'Horizontal shift SHy at FZ0'; ...
    'Variation of SHy with load'; ...
    'Variation of SHy with camber'; ...
    'Vertical shift SVy at FZ0'; ...
    'Variation of SVy with load'; ...
    'Variation of SVy with camber'; ...
    'Variation of SVy with camber & load'};

for i = 1:length(POptimization)
    fprintf('%-6s | %-45s = %10.5f\n', ...
        paramNames{i}, paramDescriptions{i}, POptimization(i));
end

disp('----------------------------------------------')
fprintf('Overall RMSE: %.3f\n', rmse);


function err = FYExperimental_all(P, L, FZ, IA, alpha, FYExperimental)
    FYModel = pacejka(P, L, FZ, IA, alpha);
    err = FYModel - FYExperimental;   % residuals for lsqnonlin
end

