clc, clearvars, close all;

data0 = readtable('R20_combined_filtered.csv');
data2 = readtable('R20_IA-2_combined_filtered.csv');
data4 = readtable('R20_IA-4_combined_filtered.csv');
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
    baseTag = sprintf('R20_FZ_%d', FZBins(i));
    
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

P0 = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = ones(1,8);

objFun = @(P) FYExperimental_all(P, L, FZAll, IAAll, alphaAll, FYAll);

options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 20000, 'TolFun', 1e-8, 'TolX', 1e-8);

lb = -Inf(1,19);
ub = Inf(1,19);
% Fix PEY2, PEY3, PEY4, PHY2, PVY2 to zero
fixedIdx = [17]; % Parameter positions to fix
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
FZPlot = [50, 150, 250]; % FZ levels to show

% Generate 9 unique colors (one per combination)
colors = lines(numel(IAValues) * numel(FZPlot));

figure;
hold on;
grid on;

c = 1; % color counter

for k = 1:numel(IAValues)
    thisIA = IAValues(k);
    idxIA = (IAAll == thisIA);

    for i = 1:numel(FZPlot)
        idx = idxIA & (FZAll == FZPlot(i));

        % Skip if no data found for this combination
        if ~any(idx), continue; end

        % Scatter experimental data
        %scatter(rad2deg(alphaAll(idx)), FYAll(idx), 6, 'MarkerEdgeColor', colors(c,:), 'MarkerFaceColor', colors(c,:), 'MarkerFaceAlpha', 0.25, 'DisplayName', sprintf('Exp FZ=%d lb, IA=%d°', FZPlot(i), thisIA));

        % Fit line
        [alphaSort, ord] = sort(alphaAll(idx));
        FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);

        plot(rad2deg(alphaSort), FYFit, 'Color', colors(c,:), 'LineWidth', 1.8, 'DisplayName', sprintf('Fit FZ=%d lb, IA=%d°', FZPlot(i), thisIA));

        c = c + 1; % advance color index
    end
end

title(sprintf('Pacejka Fit — 50, 150, 250 lb Across Camber Angles\nOverall RMSE = %.2f', rmse));
xlabel('Slip Angle [deg]');
ylabel('Lateral Force FY');
legend('Location', 'bestoutside');
hold off;



fprintf('Overall RMSE: %.3f\n', rmse);

fprintf('[');
fprintf('%g, ', POptimization(1:end-1));
fprintf('%g]\n', POptimization(end));


function err = FYExperimental_all(P, L, FZ, IA, alpha, FYExperimental)
    FYModel = pacejka(P, L, FZ, IA, alpha);
    err = FYModel - FYExperimental;   % residuals for lsqnonlin
end