meanfunc =  @meanConst; hyp.mean = 0;

covfunc = @covExpMixture1d; 
hyp.cov = log([1 1 1]);

likfunc = @likGauss; hyp.lik = 1;

psi = 100;
xi = 1;

x_max = 5 * psi;

n = 100;
x = linspace(0, x_max, n)';

clf;
hold on; 

%range = ;
for i = 0.5:0.5:2
    K = feval(covfunc, [1 psi xi], x);
    K = K + 1e-6*eye(n);

    y = chol(K)'*randn(n, 1);

    plot(x, y, 'k');
    axis([0,x_max,-5,5])
end
%legend(arrayfun(@(x) sprintf('psi = %.1f', x), range, 'UniformOutput', false))