function [models] = slice_sample_wrapper(function_type, x, y, z, n_samples)

if nargin < 4, z = linspace(0, 1, 100)'; end
if nargin < 5, n_samples = 5; end

meanfunc = @meanZero;
likfunc = @likGauss;
switch function_type
    case 'linear'
        covfunc = {@covSum, {{@covProd, {@covConst, @covLIN}}, @covConst}};
        hyp_vec = log([1 1 1]);
        n_hyps = 3;
    case 'exp'
        covfunc = {@covSum, {@covExpMixture1d, @covConst}};
        hyp_vec = log([1 1 1 1 1]);
        n_hyps = 5;
end


nlmlfunc_ = @(hyp_vec) -nlmlfunc(hyp_vec, meanfunc, covfunc, likfunc, x, y);
hyp_samples = nan(n_hyps, n_samples);

bounds = [-inf, inf;
          -inf, inf;
          -inf, inf;
          -inf, inf;
          -inf, inf];
      
fprintf('Sampling');
for i = 1:n_samples
    hyp_vec = slice_sample_max_bounded(1, 10, nlmlfunc_, hyp_vec, 0.25, true, 10, bounds);
    hyp_samples(:,i) = hyp_vec;
    fprintf('.');
end
fprintf('Done\n');

hold on;
plot(x, y, 'ko');
    
models = {};
for i = 1:n_samples
    hyp_vec = hyp_samples(:,i);
    [~, ~, m, s2] = gp(hyps_vec_to_struct(hyp_vec), @infExact, meanfunc, covfunc, likfunc, x, y, z);
    models{i} = struct('m', m', 'sd', sqrt(s2)');
    plot(z, m, 'r-');
end
    
    
%     plot(z, models{1}.m + 2 * models{1}.sd, 'r-');
%     plot(z, models{1}.m - 2 * models{1}.sd, 'b-');

end
