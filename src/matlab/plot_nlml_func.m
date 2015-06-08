meanfunc =  @meanZero;% hyp.mean = 0;

covfunc = @covExpMixture1d; 
hyp.cov = log([1 3 1]);

likfunc = @likGauss; 
hyp.lik = 1;

x_max = 3;

n = 100;
x = linspace(0, x_max, n)';

K = feval(covfunc, hyp.cov, x);
K = K + 1e-6*eye(n);

y = chol(K)'*randn(n, 1);


nlmlfunc = @(psi) gp(hyps_vec_to_struct(log([1 psi 1 1])), @infExact, meanfunc, covfunc, likfunc, x, y);

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, x, y);

fplot(nlmlfunc, [0.01, 3]);
