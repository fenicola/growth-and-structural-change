%% EXERCISE 3.a.

clear
clc
close all

%% Parameters

time = 150; 

% Parameters from main_growth_4
beta     = 0.99;
theta    = 0.3; 
delta    = 0.1;
gamma_Ax = 0.03; 
gamma_Aa = 0.08; 
gamma_Am = 0.03; 
gamma_As = 0.01; 

% Vectors for pre allocation
k       = zeros(time+1, 1);
y       = zeros(time, 1);
x       = zeros(time, 1);
PC      = zeros(time, 1); 

p_a     = zeros(time, 1);
p_m     = zeros(time, 1);
p_s     = zeros(time, 1);

c_a_num = zeros(time, 1); 
c_m_num = zeros(time, 1);
c_s_num = zeros(time, 1);

Ax      = zeros(time+1, 1);
Aa      = zeros(time+1, 1);
Am      = zeros(time+1, 1);
As      = zeros(time+1, 1);

share_a_num = zeros(time, 1);
share_m_num = zeros(time, 1);
share_s_num = zeros(time, 1);
share_invs_num = zeros(time, 1);

% Preferences params

params.epsilon = 0.5;   
params.omega_a = 0.33;   
params.omega_m = 0.33;
params.omega_s = 1 - params.omega_a - params.omega_m;
params.c_bar_a  = 0; 
params.c_bar_m  = 0;
params.c_bar_s  = 0; 

% Initial conditions
Ax(1)    = 1; 
Aa(1)    = 1; 
Am(1)    = 1; 
As(1)    = 1; 
k(1) = (beta * theta / ((1 + gamma_Ax) - beta * (1 - delta)))^(1 / (1 - theta)) * Ax(1); 

% Options for fsolve 
fsolve_options = optimoptions('fsolve', 'Display', 'none');

% Income at time = 1
y_t1 = k(1)^theta * Ax(1)^(1 - theta);
x_t1 = k(1) * (1 + gamma_Ax) - (1 - delta) * k(1);
income_t1 = y_t1 - x_t1; 

% Prices at t1 = 1
prices_t1 = [1; 1; 1];

% Initial guess
vars_guess = [income_t1 / (3 * prices_t1(1)); ...
              income_t1 / (3 * prices_t1(2)); ...
              income_t1 / (3 * prices_t1(3)); ...
              1.0]; 


% Numerical solution
disp('Starting numeric simulation...');

for t = 1 : time
      
    % Aggregate variables and prices
    y(t)     = k(t)^theta * Ax(t)^(1 - theta);
    x(t)     = k(t) * (1 + gamma_Ax) - (1 - delta) * k(t); 
    PC(t)    = y(t) - x(t); 
  
    p_a(t)   = (Ax(t) / Aa(t))^(1 - theta);
    p_m(t)   = (Ax(t) / Am(t))^(1 - theta);
    p_s(t)   = (Ax(t) / As(t))^(1 - theta);
    
    % We put toghether in a single vecor the three prices
    prices_t = [p_a(t); p_m(t); p_s(t)];
         
    % Use an anonymous function to pass parameters to the solver
    fun = @(vars) solve_consumption_foc(vars, PC(t), prices_t, params);
    
    % Call fsolve
    [solution, ~, exitflag] = fsolve(fun, vars_guess, fsolve_options);
    
    if exitflag <= 0
        warning('fsolve did not find a solution for the period %d', t);
    end
   
    % Results
    c_a_num(t) = solution(1);
    c_m_num(t) = solution(2);
    c_s_num(t) = solution(3);

    % Update the guess for next period
    vars_guess = solution; 
    
    % Nominal shares
    share_a_num(t) = p_a(t) * c_a_num(t) / y(t);
    share_m_num(t) = p_m(t) * c_m_num(t) / y(t);
    share_s_num(t) = p_s(t) * c_s_num(t) / y(t);
    share_invs_num(t) = x(t) / y(t);

    % Update variables for t+1
    k(t+1)      = x(t) + (1 - delta) * k(t); 
    Ax(t+1)     = Ax(t) * (1 + gamma_Ax); 
    Aa(t+1)     = Aa(t) * (1 + gamma_Aa); 
    Am(t+1)     = Am(t) * (1 + gamma_Am); 
    As(t+1)     = As(t) * (1 + gamma_As); 
           
end

disp('Numeric simuation complete.');




% Real shares 
disp('Calculating real shares ...');

% Preferences params
epsilon = params.epsilon;
omega_a = params.omega_a;
omega_m = params.omega_m;
omega_s = params.omega_s;



P_index = (omega_a * p_a.^(1 - epsilon) + ...
           omega_m * p_m.^(1 - epsilon) + ...
           omega_s * p_s.^(1 - epsilon)).^(1 / (1 - epsilon));


C_index = PC ./ P_index;

% Calculate the actual quotas as the ratio between quantity and aggregate C(t)

real_share_a_num = c_a_num ./ C_index;
real_share_m_num = c_m_num ./ C_index;
real_share_s_num = c_s_num ./ C_index;

disp('Real shares calculation completed.');

% Analytical simulation (from main_growth_struct_trasformation_4.)
disp('Startin analytical simulation for comparison');

k_an = k(1:time);
Ax_an = Ax(1:time);
Aa_an = Aa(1:time);
Am_an = Am(1:time);
As_an = As(1:time);

c_a_an = zeros(time, 1); c_m_an = zeros(time, 1); c_s_an = zeros(time, 1);
p_a_an = zeros(time, 1); p_m_an = zeros(time, 1); p_s_an = zeros(time, 1);
PC_an  = zeros(time, 1); y_an   = zeros(time, 1); x_an   = zeros(time, 1);

for t = 1 : time
    y_an(t)   = k_an(t)^theta * Ax_an(t)^(1 - theta);
    x_an(t)   = k_an(t) * (gamma_Ax + delta); 
    PC_an(t)  = y_an(t) - x_an(t);
  
    p_a_an(t) = (Ax_an(t) / Aa_an(t))^(1 - theta);
    p_m_an(t) = (Ax_an(t) / Am_an(t))^(1 - theta);
    p_s_an(t) = (Ax_an(t) / As_an(t))^(1 - theta);
    
    % Analytical solution
    num_c_a = PC_an(t)/p_a_an(t) + p_m_an(t)*params.c_bar_m/p_a_an(t) ...
                 + p_s_an(t)*params.c_bar_s/p_a_an(t) - params.c_bar_a * ...
                 ( (p_m_an(t)/p_a_an(t))^(1-params.epsilon)*(params.omega_m/params.omega_a) + ...
                   (p_s_an(t)/p_a_an(t))^(1-params.epsilon)*(params.omega_s/params.omega_a) );
             
    den_c_a = 1 + (p_m_an(t)/p_a_an(t))^(1-params.epsilon) * (params.omega_m/params.omega_a) + ...
                  (p_s_an(t)/p_a_an(t))^(1-params.epsilon) * (params.omega_s/params.omega_a);

    c_a_an(t) = num_c_a / den_c_a;
    c_m_an(t) = (p_m_an(t)/p_a_an(t))^(-params.epsilon)*(params.omega_m/params.omega_a)*(c_a_an(t)+params.c_bar_a)-params.c_bar_m;
    c_s_an(t) = (p_s_an(t)/p_a_an(t))^(-params.epsilon)*(params.omega_s/params.omega_a)*(c_a_an(t)+params.c_bar_a)-params.c_bar_s;
end
disp('Analytical simulation completed.');

fprintf('\n--- Error approximation in all periods ---\n');

% We calculate errors in absolute value, we are interested in the value, not the sign.

err_a = abs(c_a_num - c_a_an)
err_m = abs(c_m_num - c_m_an);
err_s = abs(c_s_num - c_s_an);

% Max error
max_err_a = max(err_a);
max_err_m = max(err_m);
max_err_s = max(err_s);

% Average error
mean_err_a = mean(err_a);
mean_err_m = mean(err_m);
mean_err_s = mean(err_s);

fprintf('Maximum error (Max|Num - An|):\n');
fprintf(' Agricolture (c_a): %e\n', max_err_a);
fprintf(' Manifacture (c_m): %e\n', max_err_m);
fprintf(' Services (c_s):     %e\n\n', max_err_s);

fprintf('Mean absolute error (Mean|Num - An|):\n');
fprintf(' Agricolture (c_a): %e\n', mean_err_a);
fprintf(' Manifacture (c_m): %e\n', mean_err_m);
fprintf(' Services (c_s):  %e\n\n', mean_err_s);


%% Plot

figure(1);
plot(1:time, share_a_num, 'r-', 'LineWidth', 2); hold on;
plot(1:time, share_m_num, 'b-', 'LineWidth', 2);
plot(1:time, share_s_num, 'g-', 'LineWidth', 2);
plot(1:time, share_invs_num, 'k-.', 'LineWidth', 2); hold off;
title('Exercise 3.a: Nominal expenditure shares');
xlabel('Periods'); ylabel('Share of GDP');
legend('Agriculture', 'Manufacture', 'Services', 'Investments', 'Location', 'best');
grid on; ylim([0,0.6]); 

figure(2);
plot(1:time, real_share_a_num, 'r-', 'LineWidth', 2); hold on;
plot(1:time, real_share_m_num, 'b-', 'LineWidth', 2);
plot(1:time, real_share_s_num, 'g-', 'LineWidth', 2); hold off;
title('Exercise 3.a: Real expenditure Shares');
xlabel('Periods'); ylabel('Share of Real Expenditure');
legend('Agriculture', 'Manufacture', 'Services', 'Location', 'best');
grid on;

