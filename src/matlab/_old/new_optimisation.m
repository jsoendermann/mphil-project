%% Load 1D data

L = csvread('../../data/log-reg_mnist/data_log_reg_mnist.csv', 1);
d = L;%D(D(:,3)==1000,:);

t = d(:,2);
y = d(:,4);
t_star = t;%linspace(0, 2, 20)';

%% Load 2D data

L = load('../../data/rnd_forest-10x10x10/data_rnd_forest_synth___n_features-75__n_informative-20__n_classes-10__n_samples-2500.mat');
D = L.D;
d = D(D(:,3)==1000,:);

t = d(:,[2;4]);
y = d(:,6);
t_star = t;

%% Create kernel function and likelihood function and params

% Exp mixture decrease

% k_t_t                  = @(xx) covExpMixture1d([xx(1), xx(2), xx(3)], t,      t)      + covConst(xx(5), t)          + covNoise(xx(4), t);
% k_tstar_tstar_no_noise = @(xx) covExpMixture1d([xx(1), xx(2), xx(3)], t_star, t_star) + covConst(xx(5), t_star);
% k_t_tstar              = @(xx) covExpMixture1d([xx(1), xx(2), xx(3)], t,      t_star) + covConst(xx(5), t, t_star);

% ll = @(xx) -0.5 * log(det(k_t_t(xx))) -0.5 * y' * (k_t_t(xx) \ y);

covfunc = {@covSum, {{@covProd, ...
                      {{@covMask, {[1, 0], @covExpMixture1d}}, ...
                      {@covMask, {[0, 1], @covExpMixture1d}}}},...
                    @covConst}};

covfunc = {@covExpMixture1d};
covfunc_plus_noise = {@covSum, {covfunc, @covNoise}};

ll = @(hyps) -0.5 * log(det(feval(covfunc_plus_noise{:}, hyps, t, t))) -0.5 * y' * (feval(covfunc_plus_noise{:}, hyps, t, t) \ y);


hyps = log([1 1 1 1]);
      
%% Plot NLML function
par_ind = 4;
v = exp(hyps(par_ind));
delta = 50;
r = linspace(v-delta, v+delta, 100);

N = nan(size(r));
for i = 1:length(r)
    p = r(i);
    hyps(3) = log(p);
    N(i) = ll(hyps);
end

plot(r,N);
%% Optimise

hyps_opt = anneal(ll, hyps);
exp(hyps_opt)

%% Predict
meanfunc = @meanZero;
hyp.mean = [];
hyp.cov = hyps_opt(1:length(hyps_opt)-1);
likfunc = @likGauss;
hyp.lik = hyps_opt(length(hyps_opt));

hyp = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, t, y);
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, t, y);
[~, ~, m, s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, t, y, t_star);
%% Plot 1d

clf;
hold on; 
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([t_star; flipdim(t_star,1)], f, [7 7 7]/8)
plot(t_star, m); 
plot(t, y, '+');