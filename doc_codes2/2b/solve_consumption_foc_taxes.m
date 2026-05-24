function [optimal_quantities, optimal_lambda] = solve_consumption_foc_taxes(income, market_prices, tax_wedges, params)

    % Calcolo dei prezzi effettivi 
    effective_prices = market_prices .* tax_wedges;
    pa = effective_prices(1);
    pm = effective_prices(2);
    ps = effective_prices(3);
    
    % Estrazione parametri
    eps = params.epsilon;
    c_bar_a = params.c_bar_a;
    c_bar_m = params.c_bar_m;
    c_bar_s = params.c_bar_s;
    
    omega_a = params.omega_a;
    omega_m = params.omega_m;
    omega_s = params.omega_s;

    % Esponenti
    pow_eps = -1 / eps;                     % (c_i + c_bar_i)^(-1/epsilon)
    w_pow_eps_a = omega_a^(1/eps);
    w_pow_eps_m = omega_m^(1/eps);
    w_pow_eps_s = omega_s^(1/eps);

    % Eq1
    F1 = @(x) (w_pow_eps_m * (x(2) + c_bar_m)^(pow_eps)) / ...
              (w_pow_eps_a * (x(1) + c_bar_a)^(pow_eps)) - (pm / pa);
              
    % Eq2
    F2 = @(x) (w_pow_eps_s * (x(3) + c_bar_s)^(pow_eps)) / ...
              (w_pow_eps_a * (x(1) + c_bar_a)^(pow_eps)) - (ps / pa);
              
    % Eq3
    F3 = @(x) income - (pa * x(1) + pm * x(2) + ps * x(3));
    
    % Combina in un'unica funzione per fsolve
    f_system = @(x) [F1(x); F2(x); F3(x)];
    
    % Stima iniziale (x0) per [ca, cm, cs]
    x0 = [income / (3 * pa), ...
          income / (3 * pm), ...
          income / (3 * ps)]; 
          
    options = optimoptions('fsolve', 'Display', 'off');
    
    % Evitiamo errori se ca+c_bar_a diventa negativo (con c_bar_a = 0 non succede)
    % Assicuriamoci che x0 sia positivo
    x0(x0 <= 0) = 1e-6; 

    [solution, ~, exitflag] = fsolve(f_system, x0, options);
    
    if exitflag <= 0
       warning('fsolve non ha trovato la soluzione.');
       optimal_quantities = [NaN, NaN, NaN];
       optimal_lambda = NaN;
       return;
    end
    
% Risultati
    optimal_quantities = solution(1:3); % [ca, cm, cs]
    
% non calcoliamo il lambda (non ci dovrebbe servire)
    optimal_lambda = NaN; 

end