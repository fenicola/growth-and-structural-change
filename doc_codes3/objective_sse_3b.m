function sse = objective_sse_3b(p)

% Target values
target_share_s(1) = 0.250699; % t=1
target_share_s(2) = 0.362325; % t=67
target_share_s(3) = 0.455087; % t=121

% Periods
periods = [1, 67, 121];

% Simulate the model
% Call the function but with target periods
share_s_nom_simulated = simulate_model_3b(p);

% Extract simulated shares
simulated_share_s(1) = share_s_nom_simulated(periods(1));
simulated_share_s(2) = share_s_nom_simulated(periods(2));
simulated_share_s(3) = share_s_nom_simulated(periods(3));

% Errores vectors
errors(1) = simulated_share_s(1) - target_share_s(1);
errors(2) = simulated_share_s(2) - target_share_s(2);
errors(3) = simulated_share_s(3) - target_share_s(3);

% Calculate the sum of squared errors

sse = sum(errors.^2);

end