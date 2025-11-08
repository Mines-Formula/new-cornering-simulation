%% fit_pacejka_with_IA.m
clc; clear; close all;

% --- FILE NAMES: adjust to your actual filenames
files = {
    'R20_combined_filtered.csv'          % IA = 0 (your original)
    'R20_IA-2_combined_filtered.csv'      % IA = 2 deg
    'R20_IA-4_combined_filtered.csv'      % IA = 4 deg
};

%% Load & concatenate data
FZ_all = [];
alpha_all = [];
FY_all = [];
IA_all = [];
source_all = [];

for f = 1:numel(files)
    if ~isfile(files{f})
        error('File not found: %s', files{f});
    end
    T = readtable(files{f});
    % columns per your earlier description
    IA_col = T{:,3};      % may be zero in IA=0 file; or file might encode IA in name
    FZ_col = T{:,4};
    alpha_col = T{:,5};
    FY_col = T{:,7};
    source_col = T{:,9};

    % If IA column is all zeros and file name encodes IA, try to parse degrees from filename
    if all(IA_col == 0)
        % look for "IA2" or "_IA2" or "IA_2" patterns in filename
        name = files{f};
        ia_deg_guess = [];
        tokens = regexp(name, 'IA[_-]?(\d+)', 'tokens', 'once');
        if ~isempty(tokens)
            ia_deg_guess = str2double(tokens{1});
        else
            % fallback: if you know file order matches IA values, set manually
            % leave as zeros if unknown
        end
        if ~isempty(ia_deg_guess)
            IA_col(:) = ia_deg_guess;
        end
    end

    % append
    FZ_all = [FZ_all; FZ_col];
    alpha_all = [alpha_all; alpha_col];
    FY_all = [FY_all; FY_col];
    IA_all = [IA_all; IA_col];
    source_all = [source_all; source_col];
end

% --- If IA is in degrees convert to radians to match alpha conversion
IA_all = deg2rad(IA_all);          % keep consistent with alpha in radians below

% Convert slip angle to radians (if you used radians in pacejka)
alpha_all = deg2rad(alpha_all);

% --- Bin mapping from source (assumes same tags like R20_FZ_250_filtered)
bins = [50, 100, 150, 200, 250];
% If your source strings include the FZ tag, override FZ_all with bin values:
FZ_binned = zeros(size(FZ_all));
for i = 1:numel(bins)
    tag = sprintf('R20_FZ_%d_filtered', bins(i));
    idx = contains(source_all, tag);
    FZ_binned(idx) = bins(i);
end
% Where no tag matched, keep measured FZ if available
no_tag_idx = FZ_binned == 0;
FZ_binned(no_tag_idx) = FZ_all(no_tag_idx);
FZ_all = FZ_binned;

% --- Initial parameters (same as before)
P0 = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, ...
      1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = ones(1,8);

%% ---- Stage 1: Fit non-IA terms using IA == 0 data only (gives good initial guess)
idx0 = abs(IA_all) < 1e-6;   % IA==0 rows
if any(idx0)
    FZ0 = FZ_all(idx0);
    a0 = alpha_all(idx0);
    FY0 = FY_all(idx0);

    % define objective for stage1: fix IA-related params (we'll hold them at initial P0)
    % Which params are IA-related? In your function: P8, P9, P12, P13-15, P16-19.
    ia_idx = [8,9,12,13,14,15,16,17,18,19];
    free_idx = setdiff(1:19, ia_idx);

    x0 = P0(free_idx);
    obj_stage1 = @(x) stage1_residuals(x, free_idx, P0, L, FZ0, zeros(size(FZ0)), a0, FY0);
    options_local = optimoptions('lsqnonlin','Display','iter','MaxFunctionEvaluations',20000);
    % optional bounds for stability
    lb_stage = -Inf(size(x0)); ub_stage = Inf(size(x0));

    x_opt = lsqnonlin(obj_stage1, x0, lb_stage, ub_stage, options_local);

    % rebuild P0 using optimized free params
    P_stage1 = P0;
    P_stage1(free_idx) = x_opt;
else
    warning('No IA==0 rows found; skipping Stage 1 and using P0 as starting guess.');
    P_stage1 = P0;
end

%% ---- Stage 2: Fit all parameters to combined data (IA=0,2,4)
% Use weighted residuals by bin inverse-std (so high-FZ doesn't dominate)
w = zeros(size(FY_all));
for i = 1:numel(bins)
    idx = (FZ_all == bins(i));
    if sum(idx) < 5, continue; end
    s = std(FY_all(idx));
    if s == 0, s = 1; end
    w(idx) = 1 ./ s;
end
% If any w==0 (e.g., unmatched FZ bins), set to median weight
w(w==0) = median(w(w>0));

% Weighted residuals function
objFun = @(P) ((pacejka(P, L, FZ_all, IA_all, alpha_all) - FY_all) .* w);

% sensible bounds (tweak to your domain knowledge)
lb = [50,    0.05, -5, -5,  0, -50, -50, -10, -10, -200, 0.05, -5, -50, -50, -5, -50, -50, -50, 0.01];
ub = [400,   5.0,  5,  5, 10,  50,  50,  10,  10,  200, 10.0,  5,  50,  50,  5,  50,  50,  50, 10];

options = optimoptions('lsqnonlin', 'Display', 'iter', ...
    'MaxFunctionEvaluations', 50000, 'TolFun', 1e-8, 'TolX', 1e-8);

% start from stage1 estimate
P_opt = lsqnonlin(objFun, P_stage1, lb, ub, options);

% Report RMSE (unweighted)
FY_pred = pacejka(P_opt, L, FZ_all, IA_all, alpha_all);
rmse = sqrt(mean((FY_all - FY_pred).^2));
fprintf('Final global RMSE (all IA): %.3f\n', rmse);

%% ---- Plot: compare experimental vs prediction at each IA and FZ
uniqueIA = unique(IA_all);
figure;
cols = lines(numel(bins));
for iai = 1:numel(uniqueIA)
    ia = uniqueIA(iai);
    subplot(1,numel(uniqueIA),iai); hold on; grid on;
    title(sprintf('IA = %.1f deg', rad2deg(ia)));
    for i = 1:numel(bins)
        idx = (abs(IA_all - ia) < 1e-6) & (FZ_all == bins(i));
        if ~any(idx), continue; end
        scatter(rad2deg(alpha_all(idx)), FY_all(idx), 12, cols(i,:), 'filled');
        [a_sort, ord] = sort(alpha_all(idx));
        fy_fit = pacejka(P_opt, L, FZ_all(idx), IA_all(idx), a_sort);
        plot(rad2deg(a_sort), fy_fit, 'Color', cols(i,:), 'LineWidth', 1.5);
    end
    xlabel('Slip Angle [deg]'); ylabel('FY [N]');
    legend(arrayfun(@(x)sprintf('FZ=%d',x), bins, 'uni',0), 'Location','best');
end
sgtitle(sprintf('Pacejka fits with IA (RMSE=%.2f)', rmse));

% Save optimized parameters
disp('Optimized P:');
disp(P_opt);

%% ---- Stage 1 helper subfunction
function r = stage1_residuals(x, free_idx, P_fixed, Llocal, FZloc, IAloc, alphaloc, FYloc)
    P = P_fixed;
    P(free_idx) = x;
    r = pacejka(P, Llocal, FZloc, IAloc, alphaloc) - FYloc;
end
