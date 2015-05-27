%% Load data
xx = linspace(0, 0.1, 5)';
yy = log(xx);
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
% covfunc = {@covSum, {@covConst, {@covProd, {@covLIN, @covConst}}}};
% hyp.cov = log([1 1]);

likfunc = @likGauss; 
hyp.lik = log(1);


%% Sample & plot

bounds = [-inf, inf;
          -inf, inf;
          -inf, inf;
          -inf, inf;
          -inf, inf];

nlmlfunc_ = @(hyp_vec) -nlmlfunc(hyp_vec, meanfunc, covfunc, likfunc, xx, yy);


%% loop

clf;
hold on;

%plot(xx,yy,'o');
for dummy = 1:10
    hyp_vec = slice_sample_max_bounded(1, 10, nlmlfunc_, hyps_struct_to_vec(hyp), 0.25, true, 10, bounds);
    
    hyp_sample = hyps_vec_to_struct(hyp_vec);
    [~, ~, m, s2] = gp(hyp_sample, @infExact, meanfunc, covfunc, likfunc, xx, yy, zz);
    
    
    disp(m);
    plot(xx, yy, 'ko');
    plot(zz, m, 'g-');
    plot(zz, m + 2*sqrt(s2), 'b-');
    plot(zz, m - 2*sqrt(s2), 'y-');
   
end