%the input function is assumed to have only non-negative values
function [ mean_time ] = v_mean( time_vec, fun_vec)
mean_time=sum(time_vec.*fun_vec)/sum(fun_vec);
