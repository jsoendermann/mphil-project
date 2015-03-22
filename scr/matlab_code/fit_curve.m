%% Load data

D = csvread('../data/all-numeric-datasets_random-forest_proportion-of-data-used.csv');

y = D(2,:)';
l = numel(y);
x = linspace(0, 1, l)';

x_train = x(1:l/2,1);
x_test = x(l/2+1:l,1);

y_train = y(1:l/2,1);
y_test = y(l/2+1:l,1);

%% Set up kernel
meanfunc = @meanZero;
hyp.mean = [];

covfunc = {@covSum, {@covExpMixture1d, @covConst, @covNoise}};
hyp.cov = log([1 1 1 1 1]);

% covfunc = {@covSEiso};
% hyp.cov = log([1 1]);

%covfunc = {@covSum, {@covExpMixture1d, @covMaterniso}};
%hyp.cov = log([0.1 1.5 2 0.05 0.02]);
% matern, matern + exp mixt, matern * exp mixture
% try different synthetic exp decay

likfunc = @likGauss;
hyp.lik = log(0.1);

%% Fit GP
z = linspace(0, 1, 100)';

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, x_train, y_train);
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x_train, y_train, z);

%% Show optimised hyperparameters
hyp_opt.mean
exp(hyp_opt.cov)
exp(hyp_opt.lik)

%% Show result
clf;
hold on; 
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([z; flipdim(z,1)], f, [7 7 7]/8)
plot(z, m); 
plot(x_train, y_train, '+');
plot(x_test, y_test, 'x');