clc; clear; close all;

files = { 'R20_combined_filtered.csv', 'R20_IA-2_combined_filtered.csv', 'R20_IA-4_combined_filtered.csv'};

% % Column meanings
% IA = data{:,3};            % Inclination angle (held constant at 0)
% FZRaw = data{:,4};        % Normal force
% alpha = data{:,5};         % Slip angle (deg)
% FYExperimental = data{:,7};        % Experimental lateral force
% source = data{:,9};        % Source file name

bins = [50, 100, 150, 200, 250];
FYAll = [];
FZAll = [];
alphaAll = [];
IAAll = [];

for f = 1:length(files)
    fprintf('Loading %s ...\n', files{f});
    data = readtable(files{f});
    % Column meanings
    IA = data{:,3};            % Inclination angle (held constant at 0)
    FZRaw = data{:,4};        % Normal force
    alpha = data{:,5};         % Slip angle (deg)
    FYExperimental = data{:,7};        % Experimental lateral force
    source = data{:,9}; 

    for i = 1:numel(bins)
        tag = sprintf('R20_FZ_%d_filtered', bins(i));
        idx = contains(source, tag);
        FYAll = [FYAll; FYExperimental(idx)];
        FZAll = [FZAll; bins(i) * ones(sum(idx),1)];
        alphaAll = [alphaAll; alpha(idx)];
        IAAll = [IAAll; IA(idx)];
    end

end

alphaAll = deg2rad(alphaAll);

FZ0 = mean(bins);
dfz = (FZAll - FZ0) ./ FZ0;

P0 = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = ones(1,8);

options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 20000, 'TolFun', 1e-8, 'TolX', 1e-8);

lb = [50,  0.5,  0.5,  -1,   0,  -5, -5, -5, -5, -100,  0.1, -5, -1, -1, -1, -1, -1, -1, -1];
ub = [500, 3,    3,     1,  10,   5,  5,  5,  5,  100,  3,   5,   1,  1,  1,  1,  1,  1,  1];

objFun = @(P) FYExperimental_all(P, L, FZAll, IAAll, alphaAll, FYAll);

options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 30000, 'TolFun', 1e-8, 'TolX', 1e-8);

fprintf("\nRunning Optimizations \n");
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
        scatter(rad2deg(alphaAll(idx)), FYAll(idx), 10, colors(i,:), 'filled', ...
            'DisplayName', sprintf('Exp FZ=%d', bins(i)));

        [alphaSort, ord] = sort(alphaAll(idx));
        FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
        plot(rad2deg(alphaSort), FYFit, 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', sprintf('Fit FZ=%d', bins(i)));
    end
    title(sprintf('Pacejka Fit (All Bins) - RMSE = %.2f', rmse));

else
    % Plot only the selected bin
    binValue = str2double(plot_choice);
    if isnan(binValue) || ~ismember(binValue, bins)
        error('Invalid bin selection. Must be one of: %s', num2str(bins));
    end

    idx = FZAll == binValue;
    scatter(rad2deg(alphaAll(idx)), FYAll(idx), 5, 'filled', ...
        'DisplayName', sprintf('Exp FZ=%d', binValue), 'MarkerFaceColor', [0.3 0.3 0.9]);

    [alphaSort, ord] = sort(alphaAll(idx));
    FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
    plot(rad2deg(alphaSort), FYFit, 'r', 'LineWidth', 2, ...
        'DisplayName', sprintf('Fit FZ=%d', binValue));
    
    title(sprintf('Pacejka Fit (FZ = %d N) - RMSE = %.2f', binValue, rmse));
end

xlabel('Slip Angle [deg]');
ylabel('Lateral Force FY [N]');
legend('Location', 'best');



function err = FYExperimental_all(P, L, FZ, IA, alpha, FYExperimental)
    FYModel = pacejka(P, L, FZ, IA, alpha);
    err = FYModel - FYExperimental;   % residuals for lsqnonlin
end
