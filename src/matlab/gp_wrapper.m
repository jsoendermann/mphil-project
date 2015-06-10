function [hyp_opt, m, sd] = gp_wrapper(function_type, x, y, z, hyp_opt, restarts)

% A wrapper around the gp function that selects hyperparameters and makes predictions

if nargin < 4, z = linspace(0, 1, 100)'; end
if nargin < 5, restarts = 5; end

meanfunc = @meanZero;
likfunc = @likGauss;
switch function_type 
    case 'linear'
        covfunc = {@covSum, {{@covProd, {@covConst, @covLIN}}, @covConst}};
    case 'exp'
        covfunc = {@covSum, {@covExpMixture1d, @covConst}};
end

if nargin < 5 
    hyp.mean = [];
    hyp.lik = log(1);
    switch function_type % The two types of models currently used
        case 'linear'
            hyp.cov = log([1 1]);
        case 'exp'
            hyp.cov = log([1 2 1 1]);
    end
    
    % Hyperparameter selection
    nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, x, y); 
    hyp_opt = hyps_vec_to_struct(slice_optimisation_with_restarts(restarts, nlmlfunc, hyps_struct_to_vec(hyp), 200));
end

% Make predictions
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y, z);

sd = sqrt(s2);
end
