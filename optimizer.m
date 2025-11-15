clc, clearvars, close all;

data0 = readtable('LC0_combined_filtered.csv');
data2 = readtable('LC0_IA-2_combined_filtered.csv');
data4 = readtable('LC0_IA-4_combined_filtered.csv');
data = [data0; data2; data4];

% Column meanings
IA = data{:,3};            % Inclination angle (held constant at 0)
FZRaw = data{:,4};        % Normal force
alpha = data{:,5};         % Slip angle (deg)
FYExperimental = data{:,7};        % Experimental lateral force
source = data{:,9};        % Source file name

FZBins = [50, 100, 150, 200, 250];
FYAll = [];
FZAll = [];
alphaAll = [];
IAAll = [];

for i = 1:numel(FZBins)
    baseTag = sprintf('LC0_FZ_%d', FZBins(i));
    
    % Match any of these forms:
    % R20_FZ_*_filtered
    % R20_FZ_*_IA-2_filtered
    % R20_FZ_*_IA-4_filtered
    idx = contains(source, [baseTag '_filtered']) | contains(source, [baseTag '_IA-2_filtered']) | contains(source, [baseTag '_IA-4_filtered']);
    
    FYAll = [FYAll; FYExperimental(idx)];
    FZAll = [FZAll; FZBins(i) * ones(sum(idx),1)];
    alphaAll = [alphaAll; alpha(idx)];
    IAAll = [IAAll; IA(idx)];
end

alphaAll = deg2rad(alphaAll);

P0 = [250, 0.727381, 2.8, -0.529889, 3, -1.16315, -1.5, 0, 0, -26.2673, 1.1146, 1, -0.001096, 0, -0.128, -0.0744754, 0, 0, 1.43];
L = ones(1,8);

objFun = @(P) FYExperimental_all(P, L, FZAll, IAAll, alphaAll, FYAll);

%options = optimoptions('lsqnonlin','Display', 'iter', 'MaxFunctionEvaluations', 40000, 'TolFun', 1e-10, 'TolX', 1e-10, 'UseParallel', true);

options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 20000, 'TolFun', 1e-8, 'TolX', 1e-8);

lb = -Inf(1,19);
ub = Inf(1,19);
% Fix PEY2, PEY3, PEY4, PHY2, PVY2 to zero
fixedIdx = []; % Parameter positions to fix
lb(1) = 250;
ub(1) = 250;
lb(fixedIdx) = P0(fixedIdx);
ub(fixedIdx) = P0(fixedIdx);


POptimization = lsqnonlin(objFun, P0, lb, ub, options);
disp('Optimized Parameters:')
disp(POptimization)

FYPredicted = pacejka(POptimization, L, FZAll, IAAll, alphaAll);
rmse = sqrt(mean((FYAll - FYPredicted).^2));
fprintf('Overall RMSE: %.3f\n', rmse);


IAValues = [0, 2, 4];
colors = lines(numel(FZBins));

for k = 1:numel(IAValues)
    figure;
    hold on;
    grid on;

    thisIA = IAValues(k);
    idxIA = (IAAll == thisIA);

    for i = 1:numel(FZBins)
        idx = idxIA & (FZAll == FZBins(i));
        scatter(rad2deg(alphaAll(idx)), FYAll(idx), 2, colors(i,:), 'filled', 'DisplayName', sprintf('Exp FZ=%d', FZBins(i)));

        [alphaSort, ord] = sort(alphaAll(idx));
        FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
        plot(rad2deg(alphaSort), FYFit, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', sprintf('Fit FZ=%d', FZBins(i)));
    end

    title(sprintf('Pacejka Fit - IA = %d° (RMSE = %.2f)', thisIA, rmse));
    xlabel('Slip Angle [deg]');
    ylabel('Lateral Force FY');
    legend('Location', 'best');

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