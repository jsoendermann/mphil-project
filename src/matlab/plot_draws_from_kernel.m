meanfunc =  @meanConst; hyp.mean = 0;

%covfunc = @covExpMixture1d; 
%hyp.cov = log([1 10 2]);

%covfunc = {@covSum, {@covSEiso, @covLINiso}}; 
%hyp.cov = log([1 1 1]);

covfunc = {@covProd, {@covLINiso, @covLINiso}};
hyp.cov = log([1 1]);

likfunc = @likGauss; hyp.lik = 1;

x_max = 10;

n = 100;
x = linspace(0, x_max, n)';

clf;
hold on; 

for i = 1:3
K = feval(covfunc{:}, hyp.cov, x);
K = K + 1e-6*eye(n);

y = chol(K)'*randn(n, 1);

plot(x, y);
%axis([0,x_max,-3,3])

end
