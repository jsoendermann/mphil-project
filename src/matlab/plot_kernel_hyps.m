meanfunc =  @meanConst; hyp.mean = 0;

covfunc = @covExpMixture1d; 
hyp.cov = log([1 10 2]);

likfunc = @likGauss; hyp.lik = 0.1;

x_max = 10000;

n = 1000;
x = linspace(0, x_max, n)';

clf;
hold on; 

i = 0

for i = 1:5
K = feval(covfunc, hyp.cov, x);
K = K + 1e-6*eye(n);


y = chol(K)'*randn(n, 1);

plot(x, y);
axis([0,x_max,-3,3])

end
