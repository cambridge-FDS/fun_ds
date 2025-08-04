load ./results/estimate_distance_june25_2
load ./results/parameters_all_june25_2.mat

[M,I] = min(estimate_distance2);

params_opt = parameters_all2(I,:);

save('./results/params_opt.mat', "params_opt")
