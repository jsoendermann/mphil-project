meanfunc = @meanConst; 
hyp.mean = 0;
covfunc = @covExpMixture1d;
hyp.cov = log([1 1 1]);
likfunc = @likGauss;
hyp.lik = 0;

z = linspace(0, 1, 100)';

K = feval(covfunc, hyp.cov, z);
K = K + 1e-5*eye(100);
y = chol(K)'*randn(100, 1);

clf;
hold on; 
plot(z, y);

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, z, y);
[~, ~, m, s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, z, y, z);
[~, ~, m_opt, s2_opt] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, z, y, z);

clf;
hold on; 

f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([z; flipdim(z,1)], f, [7 7 7]/8);

f_opt = [m_opt+2*sqrt(s2_opt); flipdim(m_opt-2*sqrt(s2_opt),1)];
fill([z; flipdim(z,1)], f_opt, [8 8 7]/8);

plot(z, m, 'x');
plot(z, m_opt, '-');
plot(z, y, 'o');