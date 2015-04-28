r = 0;

while ~isnan(r) && r < 1e-3
    for p = 1:7
        param = unifrnd(0, 100);
        x = [unifrnd(0, 100) unifrnd(0, 100)];
        y = [unifrnd(0, 100) unifrnd(0, 100)];
        
        r = checkgrad('wrapCovExpMixture2d', log(param), 1e-5, log([1 1 1 1 1 1 1]), p, x, y);
        
        fprintf('r: %f\n', r);
    end
end