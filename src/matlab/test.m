%% Load data

L = csvread('../../data/log-reg_mnist/data_log_reg_mnist.csv', 1);
d = L;%D(D(:,3)==1000,:);

t = d(:,2);
y = d(:,4);
t_star = t;%((0:(2*length(y)))')/10;

%% Subset

% t = t(1:5);
% y = y(1:5);
% t_star = t_star(1:10);

%% :pynfcg typ sfblddukd

% t = t(:,1);
% t_star = t_star(:,1);

%% Add a redundant dimension

t = [t, rand(size(t))];


%% Test = train

t_star = t;

%% Set up kernel
meanfunc = @meanZero;
hyp.mean = [];

covfunc = {@covSum, {{@covProd, ...
                      {{@covMask, {[1, 0], @covExpMixture1d}}, ...
                      {@covMask, {[0, 1], @covExpMixture1d}}}},...
                    @covConst}};
hyp.cov = log([1 1 1 1 1 1 1]);

K = feval(covfunc{:}, hyp.cov + randn(size(hyp.cov)), t);
K = K + eye*max(max(K))/100;
y = chol(K)' * randn(size(t, 1), 1);

% covfunc = @covSEiso;
% hyp.cov = log([1 1]);

likfunc = @likGauss;
hyp.lik = log(0.1);

%% Fit GP

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, t, y);
nlml = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y);
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);
% [m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);

% hyp_opt.mean
% exp(hyp_opt.cov)
% exp(hyp_opt.lik)

exp(hyp.cov)
exp(hyp_opt.cov)
nlml

% plot gp w/ different hyperparams
% fit 1d data

%% Show result
clf;
hold on; 
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([t_star(:,1); flipdim(t_star(:,1),1)], f, [7 7 7]/8)
plot(t_star(:,1), m); 
plot(t(:,1), y, '+');