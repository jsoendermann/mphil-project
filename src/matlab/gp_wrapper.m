function [hyp_opt, m, sd] = gp_wrapper(function_type, x, y, z, hyp_opt)

if nargin < 4, z = linspace(0, 1, 100)'; end

meanfunc = @meanZero;
likfunc = @likGauss;
switch function_type
    case 'linear'
        covfunc = {@covSum, {@covLIN, @covConst}}
    case 'exp'
        covfunc = {@covSum, {@covExpMixture1d, @covConst}};
end

if nargin < 5 
    hyp.mean = [];
    hyp.lik = log(0.1);
    switch function_type
        case 'linear'
            hyp.cov = log(1);
        case 'exp'
            hyp.cov = log([1 1 1 1]);
    end
    
    nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, x, y); 
    hyp_opt = hyps_vec_to_struct(slice_optimisation(nlmlfunc, hyps_struct_to_vec(hyp), 20));
end

% TODO first or second pair of m, s2
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y, z);

sd = 2 .* sqrt(s2);
end