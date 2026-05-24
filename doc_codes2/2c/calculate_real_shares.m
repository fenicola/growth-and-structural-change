 function [Real_Shares_a, Real_Shares_m, Real_Shares_s, W] = calculate_real_shares(W0,prices, params,time)

c_a = zeros (time, 1);
c_m = zeros (time, 1);
c_s = zeros (time, 1);

term_a = zeros(time, 1);
term_m = zeros(time, 1);
term_s = zeros(time, 1);

tot_quantity = zeros(time, 1);

Real_Shares_a = zeros(time, 1);
Real_Shares_m = zeros(time, 1);
Real_Shares_s = zeros(time, 1);

W = zeros(time, 1);
W(1) = W0;

options = optimoptions ('fsolve', 'Display', 'off');

x0 = [W(1)/(3*prices(1)), W(1)/(3*prices(2)), W(1)/(3*prices(3)), 1];

for t = 1:time
        if t > 1
        W(t) = W(t-1) * (1 + params.gamma_w);
    end
    
    solution = fsolve(@(x) solve_consumption_foc(x, W(t), prices, params), x0, options);
    
    ca = solution(1);
    cm = solution(2);
    cs = solution(3);
   
    c_a(t) = ca;
    c_m(t) = cm;
    c_s(t) = cs;
 
term_a(t) = ((params.omega_a^(1/params.epsilon))*(ca + params.c_bar_a)^((params.epsilon-1)/params.epsilon));
term_m(t) = ((params.omega_m^(1/params.epsilon))*(cm + params.c_bar_m)^((params.epsilon-1)/params.epsilon));
term_s(t) = ((params.omega_s^(1/params.epsilon))*(cs + params.c_bar_s)^((params.epsilon-1)/params.epsilon));

tot_quantity(t) = term_a(t) + term_m(t) + term_s(t);

Ct(t) = (tot_quantity(t)).^(params.epsilon/(params.epsilon-1));
 
    Real_Shares_a(t) = ca / Ct(t);
    Real_Shares_m(t) = cm / Ct(t);
    Real_Shares_s(t) = cs / Ct(t);

    x0 = solution;
end