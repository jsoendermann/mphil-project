r = 0;

while ~isnan(r) && r < 1e-3
xi = unifrnd(0, 100);
x = unifrnd(0, 100);
y = unifrnd(0, 100);

r = checkgrad('wrapCovExpMixture1d', log(xi), 1e-5, log([1 1 1]), 1, x, y);

disp(sprintf('xi: %f; h3: %f; x: %f; y: %f; r: %g', xi, log(xi), x, y, r));
end