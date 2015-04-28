%% Load data

L = load('../../data/rnd_forest-10x10x10/data_rnd_forest_synth___n_features-75__n_informative-20__n_classes-10__n_samples-2500.mat');
D = L.D;
d = D(D(:,3)==1000,:);

t = d(:,[2;4]);
y = d(:,6);
t_star = t;%((0:(2*length(y)))')/10;

%% Set up kernel
meanfunc = @meanZero;
hyp.mean = [];

exp1 = {@covMask, {[1,0], @covExpMixture1d}};
exp2 = {@covMask, {[0,1], @covExpMixture1d}};
prod = {@covProd, {exp1, exp2}};
covfunc = {@covSum, {prod, @covConst}};
hyp.cov = log([1 1 1 1 1 1 1]);

likfunc = @likGauss;
hyp.lik = 0;

%% Fit GP

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, t, y);
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, t, y);
[~, ~, m, s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);

exp(hyp_opt.cov)
nlml


%% Plot NLML function
par_ind = 3;
v = exp(hyp_opt.cov(par_ind));
delta = 0.0001;
r = linspace(v-delta, v+delta, 100);

N = nan(size(r));
for i = 1:length(r)
    p = r(i);
    hyp_opt.cov(3) = log(p);
    N(i) = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, t, y);
end

plot(r,N);

%% Show result
clf;
hold on; 
% f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
% fill([t_star; flipdim(t_star,1)], f, [7 7 7]/8)
% plot(t_star, m); 
% plot(t, y, '+');

surf(unique(d(:,2)), unique(d(:,4)), reshape(y, [10, 10]));
mesh(unique(d(:,2)), unique(d(:,4)), reshape(m, [10, 10]));
rotate3d on;
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
            mean' + 2 * sqrt(var)', ...
            mean' - 2 * sqrt(var)', ...
            colorbrew(2), 'none', 1, 0.2);
    hold off;
    drawnow;
end

