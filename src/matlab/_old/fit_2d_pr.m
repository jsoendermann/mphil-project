%% Kernel
exp1 = {@covMask, {[1 0], @covExpMixture1d}};
exp2 = {@covMask, {[0 1], @covExpMixture1d}};
prod = {@covProd, {exp1, exp2}};
covfunc = {@covSum, {prod, @covConst}};
covfunc_plus_noise = {@covSum, {covfunc, @covNoise}};

hyp.cov = log([1 1 1 1 1 1 1 0.001]);

%% Load real data

L = load('../../data/rnd_forest-10x10x10/data_rnd_forest_synth___n_features-75__n_informative-20__n_classes-10__n_samples-2500.mat');
D = L.D;
d = D(D(:,3)==1000,:);


xx = d(:,[2;4]);
x1 = unique(xx(:,1));
x2 = unique(xx(:,2));
y = d(:,6);

z1 = [x1; linspace(max(x1), max(x1) * 2, length(x1))'];
z2 = [x2; linspace(max(x2), max(x2) * 2, length(x2))'];
[X,Y] = meshgrid(z1, z2);
zz = [X(:) Y(:)];

nlmlfunc = @(hyps, x, y) -0.5 * log(det(feval(covfunc_plus_noise{:}, hyps, x, x))) -0.5 * y' * (feval(covfunc_plus_noise{:}, hyps, x, x) \ y);


%% Generate artificial data

x1 = linspace(0.1, 1, 20)';
x2 = linspace(0.1, 1, 20)';
[X,Y] = meshgrid(x1, x2);
xx = [X(:) Y(:)];

z1 = linspace(0.1, 2, 30)';
z2 = linspace(0.1, 2, 30)';
[X,Y] = meshgrid(z1, z2);
zz = [X(:) Y(:)];


% Generate K
K_f = @(hyps, xx) feval(covfunc_plus_noise{:}, hyp.cov, xx) + 0.01 * eye(size(xx, 1));

K = K_f(hyp.cov, xx);
y = chol(K)' * randn(size(xx, 1), 1);

nlmlfunc  = @(hyps, xx, y) -0.5 * log(det(K_f(hyps, xx))) -0.5 * y' * (K_f(hyps, xx) \ y);
%% Plot y
clf;
hold on;
mesh(x1, x2, reshape(y, [length(x1), length(x2)]));
rotate3d on;

%% Plot NLML function
par_ind = 2;

hyps = hyp.cov;
v = exp(hyps(par_ind));
delta = 10;
r = linspace(v-delta, v+delta, 100);

N = nan(size(r));
for i = 1:length(r)
    p = r(i);
    hyps(par_ind) = log(p);
    N(i) = nlmlfunc(hyps, xx, y);
end

plot(r,N);

%% Optimise manually
hyp_opt = fminunc(@(hyps) nlmlfunc(hyps, xx, y), hyp.cov);

%% Infer using gpml

meanfunc = @meanZero; 
hyp.mean = [];

covfunc = @covSEiso;
hyp.cov = log([1 1]);

% exp1 = {@covMask, {[1 0], @covExpMixture1d}};
% exp2 = {@covMask, {[0 1], @covExpMixture1d}};
% prod = {@covProd, {exp1, exp2}};
% covfunc = {@covSum, {prod, @covConst}};
% hyp.cov = log([1 1 1 1 1k 1 1]);

likfunc = @likGauss; 
hyp.lik = [0.1];

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, xx, y);
exp(hyp_opt.cov)

%%
slice_optimisation(
@(hypcov) gp(struct('cov', hypcov(1:length(hypcov)-1), 'mean', [], 'lik', hypcov(length(hypcov))), @infExact, meanfunc, covfunc, likfunc, xx, y), 
[1 1 1 1 1 1 1 0.1], 1000)

%% Predict

 hyp_opt.cov=[0.2102   -5.2608    2.0376   -0.4723   -0.1536    1.1491   -0.5293];
 hyp_opt.lik = [-4.8580];

[~, ~, m, sd] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, xx, y, zz);
nlml = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, xx, y);
nlml
-exp(nlml)
%% Plot 

surf(z1, z2, reshape(m, [length(z1), length(z2)]));