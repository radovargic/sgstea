%the input function is assumed to have only non-negative values
function [ median_time ] = v_median( time_vec, fun_vec)
mylen=length(fun_vec);
fun_half_sum = sum(fun_vec)/2;
mysum=0;
for i=1:mylen
    mysum=mysum+fun_vec(i);
    if mysum > fun_half_sum
        median_time = time_vec(i);
        return
    end
end
