function share_s_nom_series = simulate_model_3b(p)


% Parameteres to be calibrated
gamma_As_test = p(1);
beta_test     = p(2); 
epsilon_test  = p(3); 

time     = 150;    

% Fixed parameters
theta    = 0.31; 
delta    = 0.12;
gamma_Ax = 0.04;
gamma_Aa = 0.052; 
gamma_Am = 0.033; 

% Preferences parameters
params.omega_a = 0.3;   
params.omega_m = 0.4;
params.omega_s = 1 - params.omega_a - params.omega_m;
params.c_bar_a = 0; 
params.c_bar_m = 0;
params.c_bar_s = 0; 
params.epsilon = epsilon_test; 

% Vectors
k       = zeros(time+1, 1);
Ax      = zeros(time+1, 1); Aa=zeros(time+1, 1); Am=zeros(time+1, 1); As=zeros(time+1, 1);
c_a_num = zeros(time, 1); c_m_num=zeros(time, 1); c_s_num=zeros(time, 1); 
y       = zeros(time, 1); x=zeros(time, 1); PC=zeros(time, 1); 
p_a     = zeros(time, 1); p_m=zeros(time, 1); p_s=zeros(time, 1);
share_s_nom_series = zeros(time, 1);

% Initial conditions 
Ax(1)    = 1; Aa(1) = 1; Am(1) = 1; As(1) = 1; 

% Initial capital with beta test
k(1) = (beta_test * theta / ((1 + gamma_Ax) - beta_test * (1 - delta)))^(1 / (1 - theta)) * Ax(1);

% Initial guess for fsolve
y_t1 = k(1)^theta * Ax(1)^(1 - theta);
x_t1 = k(1) * (1 + gamma_Ax) - (1 - delta) * k(1);
income_t1 = y_t1 - x_t1;
vars_guess = [income_t1 / 3; income_t1 / 3; income_t1 / 3; 1.0]; 

% Fsolve options
fsolve_options = optimoptions('fsolve', 'Display', 'none');

% Simulation loop
for t = 1 : time
      
    
    y(t)     = k(t)^theta * Ax(t)^(1 - theta);
    x(t)     = k(t) * (1 + gamma_Ax) - (1 - delta) * k(t); 
    PC(t)    = y(t) - x(t); 
  
    p_a(t)   = (Ax(t) / Aa(t))^(1 - theta);
    p_m(t)   = (Ax(t) / Am(t))^(1 - theta);
    p_s(t)   = (Ax(t) / As(t))^(1 - theta);
    
   
    prices_t = [p_a(t); p_m(t); p_s(t)];
    
   
    fun = @(vars) solve_consumption_foc(vars, PC(t), prices_t, params);
    [solution, ~, exitflag] = fsolve(fun, vars_guess, fsolve_options);
    
    if exitflag <= 0 
        
        solution = vars_guess; 
    end

    c_a_num(t) = solution(1);
    c_m_num(t) = solution(2);
    c_s_num(t) = solution(3);
    vars_guess = solution; 

    
    share_s_nom_series(t) = p_s(t) * c_s_num(t) / y(t);


    k(t+1)     = x(t) + (1-delta)*k(t); 

    Ax(t+1)     = Ax(t)*(1+ gamma_Ax); 
    Aa(t+1)     = Aa(t)*(1+ gamma_Aa); 
    Am(t+1)     = Am(t)*(1+ gamma_Am); 
    As(t+1)     = As(t)*(1+ gamma_As_test); 
end

end