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

%% Plot y
clf;
hold on;
mesh(x1, x2, reshape(y, [length(x1), length(x2)]));
rotate3d on;


%% Kernel & other gp params

meanfunc = @meanZero; 
hyp.mean = [];

exp1 = {@covMask, {[1 0], @covExpMixture1d}};
exp2 = {@covMask, {[0 1], @covExpMixture1d}};
prod = {@covProd, {exp1, exp2}};
covfunc = {@covSum, {prod, @covConst}};
hyp.cov = log([1 1 1 1 1 1 1]);

likfunc = @likGauss; 
hyp.lik = log([0.1]);

%% Optimise using slice optimisation

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, xx, y);
          j     
hyp_opt = hyps_vec_to_struct(slice_optimisation(nlmlfunc, hyps_struct_to_vec(hyp)));

%% Optimise using gradient based optimisation

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, xx, y);
gradfunc = @(hyps) nlmlfunc_grad(hyps_vec_to_struct(hyps), meanfunc, covfunc, likfunc, xx, y);

hyp_opt = hyps_vec_to_struct(gradient_based_optimisation(nlmlfunc, gradfunc, hyps_struct_to_vec(hyp)));

%% Predict & print nlml

[~, ~, m, sd] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, xx, y, zz);
nlml = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, xx, y)

%% Plot 

surf(z1, z2, reshape(m, [length(z1), length(z2)]));