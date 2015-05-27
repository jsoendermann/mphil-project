distr = @(x, psi, xi) pdf('Gamma', x, 1/xi, 1/(psi*xi));

clf; hold on;

if true
    range = 0.5:0.5:3;
    
    for psi = range
        fplot(@(x) distr(x, psi,1.1), [0,2,0,4]);
    end
    legend(arrayfun(@(x) sprintf('psi = %.1f', x), range, 'UniformOutput', false));
else
    range = 0.5:0.5:3;
    
    for xi = range
        fplot(@(x) distr(x, 1.1, xi), [0,2,0,4]);
    end
    legend(arrayfun(@(x) sprintf('xi = %.1f', x), range, 'UniformOutput', false));
end