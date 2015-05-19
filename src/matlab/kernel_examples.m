meanfunc =  @meanConst; hyp.mean = 0;

covfunc = @covExpMixture1d; 
hyp.cov = log([1 10 1]);

likfunc = @likGauss; hyp.lik = 0.1;

n = 1000;
x = linspace(0, 20, n)';

clf;
hold on; 

i = 0

for i = 1:5
K = feval(covfunc, hyp.cov, x);
K = K + 1e-6*eye(n);


y = chol(K)'*randn(n, 1);

plot(x, y);

end
