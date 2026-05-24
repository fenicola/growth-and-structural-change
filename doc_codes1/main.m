clear; clc; close all

%% 1. Parametri, Condizioni Iniziali, Funzione
time = 200;

params.theta   = 0.3;    % Quota capitale
params.delta   = 0.1;    % Deprezzamento
params.gamma_a = 0.01;   % Tasso crescita A_t
params.beta    = 0.96;   % Pazienza

A0 = 1;

theta   = params.theta;
beta    = params.beta;
gamma_a = params.gamma_a;
delta   = params.delta;

K0 = ( (theta * beta) / (1 + gamma_a - beta * (1 - delta)) )^(1 / (1 - theta)) * A0;


[C, K, Y, r, w] = growthmodel(params, time, K0, A0);

%% 2. Grafici

time_axis = 1:time;

% --- Grafico 1: Evoluzione di Consumo, Capitale e Output ---
figure(1)
plot(time_axis, log(Y), 'b-', 'LineWidth', 2)
hold on
plot(time_axis, log(K), 'r--', 'LineWidth', 2)
plot(time_axis, log(C), 'g:', 'LineWidth', 2)
hold off
title('Graph 1: Evolution of Quantity (Log Scale)')
xlabel('Time (t)')
ylabel('Value (log)')
legend('Output (log Y)', 'Capital (log K)', 'Consumption (log C)', 'Location', 'northwest')
grid on

% --- Grafico 2: Evoluzione Tasso Interesse e Salario ---
figure(2)
yyaxis left
plot(time_axis, r, 'r-', 'LineWidth', 2)
xlabel('Time (t)')
ylabel('Interest Rate (r)')
ylim([r(1)*0.99, r(1)*1.01]) % Usiamo un limite stretto per vedere la stabilità
ax = gca;
ax.YColor = 'r';

yyaxis right
plot(time_axis, log(w), 'b--', 'LineWidth', 2)
ylabel('Wage (log w)')
ax = gca;
ax.YColor = 'b';

title('Graph 2: Evolution of Factor Prices')
legend('Interest Rate (r)', 'Wage (log w)', 'Location', 'northwest')
grid on