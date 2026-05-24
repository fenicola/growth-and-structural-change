clc; clear all; close all;

% Parametri imposti (regole del gioco dell'economia)
params.epsilon = 0.999;           % 0.999

params.c_bar_a = -0.05;           % -0.05
params.c_bar_m = 0;               % 0
params.c_bar_s = 0.1;             % 0.1

params.omega_a = 0.3;             % 0.3
params.omega_m = 0.4;             % 0.4
params.omega_s = 0.3;             % 0.3

gamma_w = 0.01;                   % 0.01

market_prices = [1.5, 1, 1.2];    % 1.5, 1, 1.2

% Parametri arbitrari
w0 = 10;
T = 200;

gamma_tau_a = 0.00005;  % Tassa su agricoltura cresce
gamma_tau_m = 0.00;      % Manifattura non tassata
gamma_tau_s = 0.0005;    % Sussidio su servizi cresce

% --- Inizializzazione Vettori per Simulazione ---
time_vec = 1:T;
w_vec = w0 * (1 + gamma_w).^(time_vec - 1); % Vettore redditi

% Tasse
tau_vec_policy = ones(T, 3); % [tau_a, tau_m, tau_s]
% Inizializzazione condizioni iniziali t=1

% Array per risultati Benchmark
nominal_shares_bench = zeros(T, 3);
real_shares_bench = zeros(T, 3);

% Array per risultati Policy Case
nominal_shares_policy = zeros(T, 3);
real_shares_policy = zeros(T, 3);

% Funzione helper per calcolare C aggregato (per quote reali)
% C_t = [w_a^(1/e)(c_a + c_bar_a)^((e-1)/e) + ... ]^(e/(e-1))
calc_C = @(c, p) ( ...
    p.omega_a^(1/p.epsilon) * (c(1) + p.c_bar_a)^((p.epsilon - 1) / p.epsilon) + ...
    p.omega_m^(1/p.epsilon) * (c(2) + p.c_bar_m)^((p.epsilon - 1) / p.epsilon) + ...
    p.omega_s^(1/p.epsilon) * (c(3) + p.c_bar_s)^((p.epsilon - 1) / p.epsilon) ...
    )^(p.epsilon / (p.epsilon - 1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Loop di Simulazione ---
for t = 1:T
    income = w_vec(t);
    
    % --- A. Scenario Benchmark (No Policy) ---

    tax_bench = [1, 1, 1];
    % Usiamo la funzione creata nell'esercizio
    [c_bench, ~] = solve_consumption_foc_taxes(income, market_prices, tax_bench, params);
    
    % Calcolo quote nominali (p_i * c_i / w)
    expenditure_bench = market_prices .* c_bench;
    nominal_shares_bench(t, :) = expenditure_bench / income;
    
    % Calcolo quote reali (c_i / C)
    C_bench = calc_C(c_bench, params);
    real_shares_bench(t, :) = c_bench ./ C_bench;
    
    % --- B. Scenario Policy ---
    
    if t > 1
        % Aggiorna le tasse secondo le leggi di moto
        tau_vec_policy(t, 1) = tau_vec_policy(t-1, 1) * (1 + gamma_tau_a);
        tau_vec_policy(t, 2) = tau_vec_policy(t-1, 2) * (1 + gamma_tau_m)^(-1); % Rimane 1
        tau_vec_policy(t, 3) = tau_vec_policy(t-1, 3) / (1 + gamma_tau_s);
    end

    current_taxes = tau_vec_policy(t, :);
    
    [c_policy, ~] = solve_consumption_foc_taxes(income, market_prices, current_taxes, params);
    
   % Calcolo quote nominali
     expenditure_policy = market_prices .* c_policy;
     nominal_shares_policy(t, :) = expenditure_policy / sum(expenditure_policy);
    
    % Calcolo quote reali
    C_policy = calc_C(c_policy, params);
    real_shares_policy(t, :) = c_policy ./ C_policy;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Figura 1: Quote di Spesa NOMINALI (Tutti i settori)
% Del totale di euro che ho speso, quale percentuale è andata all'agricoltura, quale alla manifattura e quale ai servizi?
figure('Name', 'Comparison of Nominal Expenditure Shares', 'NumberTitle', 'off');
hold on;
% Plot Benchmark (Linee Solide)
plot(time_vec, nominal_shares_bench(:, 1), 'b-', 'LineWidth', 2, 'DisplayName', 'Agriculture (Benchmark)');
plot(time_vec, nominal_shares_bench(:, 2), 'g-', 'LineWidth', 2, 'DisplayName', 'Manufacturing (Benchmark)');
plot(time_vec, nominal_shares_bench(:, 3), 'r-', 'LineWidth', 2, 'DisplayName', 'Services (Benchmark)');
% Plot Policy (Linee Tratteggiate)
plot(time_vec, nominal_shares_policy(:, 1), 'b--', 'LineWidth', 2, 'DisplayName', 'Agriculture (Policy)');
plot(time_vec, nominal_shares_policy(:, 2), 'g--', 'LineWidth', 2, 'DisplayName', 'Manufacturing (Policy)');
plot(time_vec, nominal_shares_policy(:, 3), 'r--', 'LineWidth', 2, 'DisplayName', 'Services (Policy)');
hold off;

title('Evolution of Nominal Expenditure Shares (Benchmark vs Policy)', 'FontSize', 14);
ylabel('Nominal Expenditure Share');
xlabel('Period (t)');
legend('show', 'Location', 'best');
grid on;
box on;

% Figura 2: Quote di Spesa REALI (Tutti i settori)
figure('Name', 'Comparison of Actual Expenditure Shares', 'NumberTitle', 'off');
hold on;
% Plot Benchmark (Linee Solide)
plot(time_vec, real_shares_bench(:, 1), 'b-', 'LineWidth', 2, 'DisplayName', 'Agriculture (Benchmark)');
plot(time_vec, real_shares_bench(:, 2), 'g-', 'LineWidth', 2, 'DisplayName', 'Manufacturing (Benchmark)');
plot(time_vec, real_shares_bench(:, 3), 'r-', 'LineWidth', 2, 'DisplayName', 'Services (Benchmark)');
% Plot Policy (Linee Tratteggiate)
plot(time_vec, real_shares_policy(:, 1), 'b--', 'LineWidth', 2, 'DisplayName', 'Agriculture (Policy)');
plot(time_vec, real_shares_policy(:, 2), 'g--', 'LineWidth', 2, 'DisplayName', 'Manufacturing (Policy)');
plot(time_vec, real_shares_policy(:, 3), 'r--', 'LineWidth', 2, 'DisplayName', 'Services (Policy)');
hold off;

title('Evolution of Real Expenditure Shares (Benchmark vs Policy)', 'FontSize', 14);
ylabel('Actual Expenditure Share');
xlabel('Period (t)');
legend('show', 'Location', 'best');