function POptimization = LC0_optimizer()

    data0 = readtable('data/LC0_combined_filtered.csv');
    data2 = readtable('data/LC0_IA-2_combined_filtered.csv');
    data4 = readtable('data/LC0_IA-4_combined_filtered.csv');
    data  = [data0; data2; data4;];
    
    % Column meanings
    IA             = data.InclinationAngle;  % Inclination angle (held constant at 0)
    FZRaw          = data.NormalForce;       % Normal force
    alpha          = data.SlipAngle;         % Slip angle (deg)
    FYExperimental = data.LateralForce;      % Experimental lateral force
    source         = data.SourceFile;        % Source file name
    
    FZBins   = [50, 100, 150, 200, 250];
    FYAll    = [];
    FZAll    = [];
    alphaAll = [];
    IAAll    = [];
    
    for i = 1:numel(FZBins)
        baseTag = sprintf('LC0_FZ_%d', FZBins(i));
        
        % Match any of these forms:
        % R20_FZ_*_filtered
        % R20_FZ_*_IA-2_filtered
        % R20_FZ_*_IA-4_filtered
        % Also works for LC0 just match format for new tire
        idx = contains(source, [baseTag '_filtered']) | contains(source, [baseTag '_IA-2_filtered']) | contains(source, [baseTag '_IA-4_filtered']);
        
        FYAll    = [FYAll; FYExperimental(idx)];
        FZAll    = [FZAll; FZBins(i) * ones(sum(idx),1)];
        alphaAll = [alphaAll; alpha(idx)];
        IAAll    = [IAAll; IA(idx)];
    end
    
    alphaAll = deg2rad(alphaAll);
    
    P0 = [250, 1.17858, -2.45689, 0.207723, 0.00218554, 0.181269, 0.212474, -2.41388, 0.605724, -30.9683, 1.44763, 0.0143188, -0.00587066, -0.0126017, -0.00150596, -0.18861, -0.170156, 0.0185739, 0.0140275];
    L = ones(1,8);
    
    objFun = @(P) FYExperimental_all(P, L, FZAll, IAAll, alphaAll, FYAll);
    
    %options = optimoptions('lsqnonlin','Display', 'iter', 'MaxFunctionEvaluations', 40000, 'TolFun', 1e-10, 'TolX', 1e-10, 'UseParallel', true);
    
    options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 20000, 'TolFun', 1e-8, 'TolX', 1e-8);
    
    lb = -Inf(1,19);
    ub = Inf(1,19);
    % Fix PEY2, PEY3, PEY4, PHY2, PVY2 to zero
    %fixedIdx = [2, 3, 6, 4, 10, 11, 12]; % Parameter positions to fix
    %fixedZeroes = [8, 9, 13, 17, 18]
    lb(1) = 250;
    ub(1) = 250;
    %lb(fixedIdx) = P0(fixedIdx);
    %ub(fixedIdx) = P0(fixedIdx);
    %lb(fixedZeroes) = 0;
    %ub(fixedZeroes) = 0;
    
    POptimization = lsqnonlin(objFun, P0, lb, ub, options);
    POptimization = POptimization(:); % Convert row to column vector
    disp('Optimized Parameters:')
    disp(POptimization)
    
    FYPredicted = pacejka(POptimization, L, FZAll, IAAll, alphaAll);
    rmse = sqrt(mean((FYAll - FYPredicted).^2));
    fprintf('Overall RMSE: %.3f\n', rmse);
    
    
    IAValues = [0, 2, 4];
    colors = lines(numel(FZBins));
    
    for k = 1:numel(IAValues)
        fig = figure('Visible', 'on', 'Name', sprintf('LC0 Pacejka Fit - IA = %d°', IAValues(k)));
        hold on;
        grid on;
        thisIA = IAValues(k);
        idxIA = (IAAll == thisIA);
    
        for i = 1:numel(FZBins)
            idx = idxIA & (FZAll == FZBins(i));
            scatter(rad2deg(alphaAll(idx)), FYAll(idx), 2, colors(i,:), 'filled', 'DisplayName', sprintf('Exp FZ=%d', FZBins(i)));
            [alphaSort, ~] = sort(alphaAll(idx));
            FYFit = pacejka(POptimization, L, FZAll(idx), IAAll(idx), alphaSort);
            plot(rad2deg(alphaSort), FYFit, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', sprintf('Fit FZ=%d', FZBins(i)));
        end
    
        title(sprintf('Pacejka Fit - IA = %d° (RMSE = %.2f)', thisIA, rmse));
        xlabel('Slip Angle [deg]');
        ylabel('Lateral Force FY');
        legend('Location', 'best');
        
        saveas(fig, sprintf('data/Outputs/LC0_Pacejka_Fit_IA_%d.png', thisIA));
        
        drawnow; 
    end


end

function err = FYExperimental_all(P, L, FZ, IA, alpha, FYExperimental)
    FYModel = pacejka(P, L, FZ, IA, alpha);

    % Weight residuals so each inclination angle (IA) contributes equally
    IAvals = unique(IA);
    err = [];
    for i = 1:numel(IAvals)
        idx = IA == IAvals(i);
        n = sum(idx);
        w = 1 / max(n, 1);  % equal total contribution per IA group
        err = [err; w * (FYModel(idx) - FYExperimental(idx))];
    end
end