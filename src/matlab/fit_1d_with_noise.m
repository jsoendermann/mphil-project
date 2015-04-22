%% Load data

L = csvread('../../data/log-reg_mnist/data_log_reg_mnist.csv', 1);
d = L;%D(D(:,3)==1000,:);

t = d(:,2);
y = d(:,4);
t_star = t;%((0:(2*length(y)))')/10;

%% Add additional dimension

t_s = [repmat(t, 10, 1) randn(100, 1)];
y_s = repmat(y, 10, 1);
t_star = t_s;

%% Set up kernel
meanfunc = @meanZero;
hyp.mean = [];

covfunc = {@covSum, {{@covMask, {[1 0], @covExpMixture1d}}, @covConst}};
hyp.cov = log([2 2 1 1]);

% exp1 = {@covMask, {[1 0], @covExpMixture1d}};
% exp2 = {@covMask, {[0 1], @covExpMixture1d}};
% covfunc = {@covSum, {{@covProd, {exp1, exp2}}, @covConst}};
% hyp.cov = log([2 2 1 2 2 1 1]);

% covfunc = @covSEiso;
% hyp.cov = log([1 1]);

likfunc = @likGauss;
hyp.lik = log(0.1);

%% Fit GP

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, t_s, y_s);
nlml = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t_s, y_s);
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);
% [m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);

% hyp_opt.mean
% exp(hyp_opt.cov)
% exp(hyp_opt.lik)

exp(hyp_opt.cov)
nlml

% plot gp w/ different hyperparams
% fit 1d data

%% Show result
clf;
hold on; 
% f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
% fill([t_star; flipdim(t_star,1)], f, [7 7 7]/8)
% plot(t_star, m); 
% plot(t, y, '+');

surf(t, 1:10, reshape(y_s, [10, 10]));
mesh(t, 1:10, reshape(m, [10, 10]));
rotate3d on;
