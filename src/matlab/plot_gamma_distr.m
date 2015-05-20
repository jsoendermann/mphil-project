distr = @(x, psi, xi) pdf('Gamma', x, 1/xi, 1/(psi*xi));

hold on;
for psi = 1:2:10
    fplot(@(x) distr(x, psi,1.5), [0,2.5,0,4], 'k');
end
hold off;

hold on;
for xi = 1:2:10
    fplot(@(x) distr(x, 1.5, xi), [0,2.5,0,4], 'r');
end
hold off;