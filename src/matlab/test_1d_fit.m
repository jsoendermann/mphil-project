%% Load data

zz = xx;%linspace(0,1,100)';
%% Plot y
clf;
hold on;
plot(xx,yy);


%% Kernel & other gp params

meanfunc = @meanZero; 
hyp.mean = [];

covfunc = {@covSum, {@covExpMixture1d, @covConst}};
hyp.cov = log([1 1 1 1]);

likfunc = @likGauss; 
hyp.lik = log(1);

%% Optimise using slice optimisation

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, xx, yy);
      
hyp_opt = hyps_vec_to_struct(slice_optimisation_with_restarts(3, nlmlfunc, hyps_struct_to_vec(hyp), 200));

%% Optimise using gradient based optimisation

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, xx, y);
gradfunc = @(hyps) nlmlfunc_grad(hyps_vec_to_struct(hyps), meanfunc, covfunc, likfunc, xx, y);

hyp_opt = hyps_vec_to_struct(gradient_based_optimisation(nlmlfunc, gradfunc, hyps_struct_to_vec(hyp), 20));

%% Predict & print nlml

[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, xx, yy, zz);
nlml = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, xx, yy)

%% Plot 

hold on;
plot(xx, yy, 'ko');
plot(zz, m);
plot(zz, m + 2*sqrt(s2));
plot(zz, m - 2*sqrt(s2));

% min samples leaf 1->50
% gp
% svm time polynomial
% anytime algorithm
% utility = Expected improvement of ((gaussian at target - gaussian at
% current best) truncated at 0)
% utipity of sth that takes longer than time limet: 0
% exp_utily/time
% modelling is interesting

% var of residuals / var of data
% plot residuals against fitted value 2d->1d

