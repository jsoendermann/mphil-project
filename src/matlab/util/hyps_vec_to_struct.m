function [s] = hyps_vec_to_struct(vec)
s.mean = [];
s.cov = vec(1:length(vec)-1);
s.lik = vec(length(vec));
end

