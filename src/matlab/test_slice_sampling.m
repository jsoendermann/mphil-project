%% Load data

zz = xx;
%% Plot data
clf;
hold on;
plot(xx,yy,'o');


%% Kernel & other gp params

meanfunc = @meanZero; 
hyp.mean = [];

covfunc = {@covSum, {@covExpMixture1d, @covConst}};
hyp.cov = log([1 1 1 1]);

likfunc = @likGauss; 
hyp.lik = log(1);


%% Sample & plot

bounds = [-inf, inf;
          -inf, inf;
          -inf, inf;
          -inf, inf;
          -inf, inf];

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, xx, yy);

for dummy = 1:1
    hyp_vec = slice_sample_max_bounded(1, 10, nlmlfunc, hyps_struct_to_vec(hyp), 0.25, true, 10, bounds);
    
    hyp_sample = hyps_vec_to_struct(hyp_vec);
    [~, ~, m, s2] = gp(hyp_sample, @infExact, meanfunc, covfunc, likfunc, xx, yy, zz);
    
    hold on;
    plot(xx, yy, 'ko');
    plot(zz, m);
    plot(zz, m + 2*sqrt(s2));
    plot(zz, m - 2*sqrt(s2));
    hold off;
end