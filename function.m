clc, clearvars, clear all

inFile = "R20_ordered_tire_pressure_and_speed.csv";
data = readtable(inFile);

pressure = data.TirePressure;
FZ = data.NormalForce;
IA = data.InclinationAngle;
alpha = data.SlipAngle;
FYMeasured = data.LateralForce;

P0 = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
L = ones(1, 8);

functionObject = @(P) pacejka(P, L, FZ, IA, alpha) - FYMeasured;

options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxFunctionEvaluations', 5000);
[pacejkaFit, resnorm] = lsqnonlin(functionObject, P0, [], [], options);

disp('Estimated Pacejka coefficients:');
disp(pacejkaFit);

FYPredicted = pacejka(pacejkaFit, L, FZ, IA, alpha);

figure;
scatter(alpha, FYMeasured, 'k.');
hold on;
scatter(alpha, FYPredicted, 'r.');
xlabel("Slip Angle (deg)");
ylabel("Lateral Force (N)");
legend('Measured', 'Pacejka Fit');
title("Pacejka Fit Comparison)");
grid on;