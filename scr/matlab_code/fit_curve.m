%% Load data

D = csvread('../../data/all-numeric-datasets_random-forest_proportion-of-data-used.csv');

y = D(2,:)';
t = (1:length(y))';
t_star = (1:(2*length(y)))';

% y = D(2,:)';
% l = numel(y);
% x = linspace(0, 1, l)';
% 
% x_train = x(1:l/2,1);
% x_test = x(l/2+1:l,1);
% 
% y_train = y(1:l/2,1);
% y_test = y(l/2+1:l,1);
%% Subset

t = t(1:10);
y = y(1:10);
t_star = t_star(1:20);

%% Create kernel function and likelihood function and params

% Exp mixture decrease

k_t_t     = @(xx) covExpMixture1d([xx(1), xx(2), xx(3)], t, t) + covNoise(xx(4), t) + covConst(xx(5), t);
k_tstar_tstar_no_noise = @(xx) covExpMixture1d([xx(1), xx(2), xx(3)], t_star, t_star) + covConst(xx(5), t_star);
k_t_tstar = @(xx) covExpMixture1d([xx(1), xx(2), xx(3)], t, t_star) + covConst(xx(5), t, t_star);

% k_t_t     = @(xx) covTest([xx(1), xx(2), xx(3)], t, t) + covNoise(xx(4), t) + covConst(xx(5), t);
% k_tstar_tstar_no_noise = @(xx) covTest([xx(1), xx(2), xx(3)], t_star, t_star) + covConst(xx(5), t_star);
% k_t_tstar = @(xx) covTest([xx(1), xx(2), xx(3)], t, t_star) + covConst(xx(5), t, t_star);

ll = @(xx) -0.5 * log(det(k_t_t(xx))) -0.5 * y' * (k_t_t(xx) \ y);

alpha = log(2);
beta = log(2);
scale = 1;
noise = 0.1;
const = 1;
xx = [log(scale), alpha, beta, log(noise), log(const)];

bounds = [-inf, inf;
          -inf, inf;
          -inf inf;
          -inf, inf;
          -inf, inf];
      
 %% Slice sample and plot

for dummy = 1:1
%     xx = slice_sample_max_bounded(1,10,ll,xx,0.25,true,10,bounds);
    
    exp(xx)
    
    K_t_t = k_t_t(xx);
    K_t_tstar = k_t_tstar(xx);
    K_tstar_tstar = k_tstar_tstar_no_noise(xx);
    
    mean = K_t_tstar' * (K_t_t \ y);
    covar = K_tstar_tstar - K_t_tstar' * (K_t_t \ K_t_tstar);
    var = diag(covar);
    
    plot(t, y, 'o');
    hold on;
    plot(t_star, mean);
    hold off;
    
    close all;
    figure();
    hold on;
    set(gca,'Layer','top');
    plot(t, y, 'o', 'color', colorbrew(1));
    plot(t_star, mean, '-', 'color', colorbrew(2));
    % Plot confidence bears.
    jbfill( t_star', ...
            mean' + 1 * sqrt(var)', ...
            mean' - 1 * sqrt(var)', ...
            colorbrew(2), 'none', 1, 0.2);
    hold off;
    drawnow;
end

%% Set up kernel
meanfunc = @meanZero;
hyp.mean = [];

covfunc = {@covSum, {@covTest, @covConst}};
hyp.cov = log([2 2 1 1]);

likfunc = @likGauss;
hyp.lik = log(0.1);

%% Fit GP
z = linspace(0, 1, 100)';

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, t, y);
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);
% [m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);

% hyp_opt.mean
% exp(hyp_opt.cov)
% exp(hyp_opt.lik)

xx = [hyp_opt.cov(1:3), hyp_opt.lik, hyp_opt.cov(4)];
exp(xx)

%% Show result
clf;
hold on; 
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([t_star; flipdim(t_star,1)], f, [7 7 7]/8)
plot(t_star, m); 
plot(t, y, '+');
% plot(t_star, y_test, 'x');