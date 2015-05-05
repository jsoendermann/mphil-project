x = [0.1 0.2 0.3 0.4]';
y = [1.1 2.2 3.3 4.4]';
z = linspace(0, 3, 100)';


meanfunc = @meanZero;
likfunc = @likGauss;
covfunc = {@covSum, {{@covProd, {@covConst, @covLIN}}, @covConst}};

hyp.mean = [];
hyp.lik = log(0.1);
hyp.cov = log([1 1]);

nlmlfunc = @(hyps) gp(hyps_vec_to_struct(hyps), @infExact, meanfunc, covfunc, likfunc, x, y); 
hyp_opt = hyps_vec_to_struct(slice_optimisation(nlmlfunc, hyps_struct_to_vec(hyp), 20));

[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x, y, z);
sd = 2 .* sqrt(s2);

hold on;
plot(x, y, 'bo');
plot(z, m);
plot(z, m + 2 * sd);
plot(z, m - 2 * sd);