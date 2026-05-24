 function diff = calibrate_gamma_w(gamma_trial, W0, prices,params, time, target_share)

params.gamma_w = gamma_trial;

[~, ~, Real_Share_s] = calculate_real_shares(W0 ,prices, params, time);


diff = Real_Share_s(200) - target_share;

end 