% Funzione
function [C, K, Y, r, w] = growthmodel(params, time, K0, A0)

% --- Recupera i parametri ---
theta   = params.theta;   
delta   = params.delta;   
gamma_a = params.gamma_a;
beta    = params.beta;

% --- Inizializzare i vettori ---
K = zeros(time, 1);
A = zeros(time, 1);
Y = zeros(time, 1);
C = zeros(time, 1);
r = zeros(time, 1);
w = zeros(time, 1);

% --- Condizioni iniziali ---
A(1) = A0;
K(1) = K0;
Y(1) = K(1)^theta * A(1)^(1-theta);
r(1) = theta * K(1)^(theta-1) * A(1)^(1-theta); 
w(1) = (1-theta) * K(1)^theta * A(1)^(1-theta);
C(1) = Y(1) - (gamma_a + delta) * K(1);

% --- Ciclo For ---
for t = 1 : time-1
    % Sul BGP, tutte le quantità crescono a tasso gamma_a 
    A(t+1) = A(t) * (1 + gamma_a);
    K(t+1) = K(t) * (1 + gamma_a);
    Y(t+1) = Y(t) * (1 + gamma_a);
    C(t+1) = C(t) * (1 + gamma_a);
    w(t+1) = w(t) * (1 + gamma_a);

    % r è costante perché K/A è costante
    r(t+1) = theta * K(t+1)^(theta-1) * A(t+1)^(1-theta);
end

end