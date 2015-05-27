meanfunc =  @meanConst; hyp.mean = 0;

covfunc = @covExpMixture1d; 
hyp.cov = log([1 10 2]);

likfunc = @likGauss; hyp.lik = 1;

x_max = 5;

n = 100;
x = linspace(0, x_max, n)';

%clf;
hold on; 

%range = 0.5:0.5:2;
for i = 1:30
    K = feval(covfunc, [1 1 10], x);
    K = K + 1e-6*eye(n);

    y = chol(K)'*randn(n, 1);

    plot(x, y, 'k');
    axis([0,x_max,-5,5])
end
%legend(arrayfun(@(x) sprintf('psi = %.1f', x), range, 'UniformOutput', false))