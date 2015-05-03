function [m, sd] = model_linear_function(x, y, z)

if nargin < 3, z = linspace(0, 1, 100)'; end

meanfunc = @meanZero; 
hyp.mean = [];

covfunc = {@covSum, {@covLIN, @covConst}};
hyp.cov = log([1]);

likfunc = @likGauss; 
hyp.lik = log(0.1);

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, x, y);
      
hyp_opt = hyps_vec_to_struct(slice_optimisation(nlmlfunc, hyps_struct_to_vec(hyp), 20));

% TODO first or second pair of m, s2
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y, z);

sd = 2 .* sqrt(s2);
end