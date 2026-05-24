clear all; clc; close all;

% Parameters

time = 200; 

params.omega_a = 0.3; 
params.omega_m = 0.4; 
params.omega_s = 0.3;

params.c_bar_a = -0.05; 
params.c_bar_m = 0;
params.c_bar_s = 0.1;   

params.epsilon = 0.999; 

params.gamma_w = 0.01;

prices = [1.5, 1.0, 1.2];

W0 = 10;         

% Calibration

target_share = 0.3190; 
gamma_trial = 0.01;

[~, ~, Real_Shares_s, Wsim] = calculate_real_shares(W0, prices, params, time);

f_obj = @(g) calibrate_gamma_w (g, W0, prices, params, time, target_share);
options = optimset('Display', 'iter');

[gamma_w_optimal, fval] = fzero (f_obj,gamma_trial,options);

fprintf('\n Result Calibration \n');
fprintf('Original gamma (gamma_w):       %.5f (%.2f%%)\n', params.gamma_w, params.gamma_w*100);
fprintf('Calibrated gamma (gamma_w_optimal):     %.5f (%.2f%%)\n', gamma_w_optimal, gamma_w_optimal*100);
fprintf('To achieve the same share of services (%.4f) as the fiscal policy,\n', target_share);
fprintf('income in the benchmark economy would need to grow at %.2f%% per year.\n', gamma_w_optimal*100);
fprintf('Final calibration error (fval): %g\n', fval);