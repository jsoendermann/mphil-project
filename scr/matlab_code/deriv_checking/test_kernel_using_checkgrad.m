r = 0;

while ~isnan(r) && r < 1e-3
    for p = 1:3
        xi = unifrnd(0, 100);
        x = unifrnd(0, 100);
        y = unifrnd(0, 100);
        
        r = checkgrad('wrapCovExpMixture1d', log(xi), 1e-5, log([1 1 1]), p, x, y);
        
        fprintf('p: %d; xi: %f; h3: %f; x: %f; y: %f; r: %g\n', p, xi, log(xi), x, y, r);
    end
end