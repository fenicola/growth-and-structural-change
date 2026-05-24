%Main script ex.3b
clear
clc
close all

%% Calibration setting

% Initial guess 
gamma_As_initial = 0.01; 
beta_initial     = 0.99;
epsilon_initial  = 0.5;

x0 = [gamma_As_initial; beta_initial; epsilon_initial];


% Use fminsearch

options_calib = optimset('Display', 'off', ...
                         'TolFun', 1e-8, ...
                         'MaxIter', 500);  

disp('Starting calibration...');


% Call the objective function @objective_sse_3b
[p_calib, sse_min, exitflag, output] = fminsearch(@objective_sse_3b, x0, options_calib);


% Calibration results

gamma_As_calib = p_calib(1);
beta_calib     = p_calib(2);
epsilon_calib  = p_calib(3);

% Direct result of fminsearch
resnorm = sse_min; 

disp('Calibration results');
fprintf('Growth rates in service (gamma_s): %.3f\n', gamma_As_calib);
fprintf('Discount factor (beta): %.3f\n', beta_calib);
fprintf('Ekaticity of substitution (epsilon): %.3f\n', epsilon_calib);
fprintf('Least squadre sum: %.2e\n', resnorm);




% Simulate the model with the calibrated parameters.
disp('Plot simulation...');
share_s_nom_calib = simulate_model_3b(p_calib);

% Plot
figure('Name','Calibrated model');
hold on; 
plot(1:150, share_s_nom_calib, 'g-', 'LineWidth', 2);

% Targets
target_periods = [1, 67, 121];
target_values = [0.250699, 0.362325, 0.455087];

scatter(target_periods, target_values, 100, 'r', 'filled', 'DisplayName', 'Target values');
hold off;

title('Nominal services share: Calibration');
xlabel('Period (t)');
ylabel('Nominal services share (share\_s)');
legend('Calibrated model', 'Target values', 'Location', 'SouthEast');
grid on;
box on;
