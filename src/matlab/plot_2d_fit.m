%% Load

D = csvread('data_rnd_forest_amazon.csv', 1);
x = D(:,[2,3]);
x1 = unique(D(:,2));
x2 = unique(D(:,3));
y = D(:,5);

z1 = [x1; linspace(max(x1), max(x1) * 2, length(x1))'];
z2 = [x2; linspace(max(x2), max(x2) * 2, length(x2))'];
[X,Y] = meshgrid(z1, z2);
z = [X(:) Y(:)];

%% Plot

clf;
hold on;
surf(x1, x2, reshape(y, [length(x1), length(x2)]));
xlabel('# trees');
ylabel('% data');
zlabel('Score');
rotate3d on;

%% Kernel & other gp params

meanfunc = @meanZero; 
hyp.mean = [];

exp1 = {@covMask, {[1 0], @covExpMixture1d}};
exp2 = {@covMask, {[0 1], @covExpMixture1d}};
prod = {@covProd, {exp1, exp2}};
covfunc = {@covSum, {prod, @covConst}};
hyp.cov = log([1 1 1 1 1 1 1]);

covfunc = @covSEiso;
hyp.cov = log([1 1]);

likfunc = @likGauss; 
hyp.lik = log(1);


%% Fit & plot

hyp_opt = minimize(hyp, @gp, -100, @infExact, [], covfunc, likfunc, x, y);
gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y)
[~, ~, m, sd] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y, z);

surf(z1, z2, reshape(m, [length(z1), length(z2)]));