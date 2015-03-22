%% Set up inputs and kernel

x = linspace(0.1, 1, 100)';
z = linspace(0.1, 2, 100)';
hyp.cov = [1 1 1];
K_xx = covExpMixture1d(hyp.cov, x);
noise = 0.001 * max(max(K_xx));
K_xx = K_xx + noise * eye(size(K_xx));
K_xz = covExpMixture1d(hyp.cov, x, z);
K_zz = covExpMixture1d(hyp.cov, z);
% K_zz = K_zz + noise * eye(size(K_zz));

%% Generate data

y = chol(K_xx)' * randn(size(x, 1), 1);
plot(x, y, 'o');

%% Infer manually

m = K_xz' * (K_xx \ y);
v = K_zz - K_xz' * (K_xx \ K_xz);
sd = sqrt(diag(v));

%% Infer using gpml

meanfunc = @meanZero; hyp.mean = [];
covfunc = @covExpMixture1d;
likfunc = @likGauss; hyp.lik = 0;
hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, x, y);
[~, ~, m, sd] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y, z);

%% Plot

plot(x, y, 'bo');
hold on;
plot(z, m, 'r+');
plot(z, m + 2 * sd, 'k-');
plot(z, m - 2 * sd, 'k-');
hold off;