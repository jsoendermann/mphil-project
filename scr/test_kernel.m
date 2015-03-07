delta = 0.01;
kernel = @covExpMixture1d; 
hyp = log([1 200 20]);
param_index = 2;

% randn('seed', 10);
% x = abs(randn(1000, 1)) * 100;
% z = abs(randn(900, 1)) * 10;

x = linspace(0.1, 0.2, 500)';
z = linspace(0.1, 0.4, 500)';

% set up hyperparameters
hyp_minus = hyp;
hyp_plus = hyp;
hyp_minus(param_index) = hyp_minus(param_index) - delta/2;
hyp_plus(param_index) = hyp_plus(param_index) + delta/2;

% compute derivatives twice
v_minus = feval(kernel, hyp_minus, x, z);
v_plus  = feval(kernel, hyp_plus,  x, z);
v_deriv_man = (v_plus - v_minus)/delta;
v_deriv_auto = feval(kernel, hyp, x, z, param_index);

% compute difference
diff = v_deriv_man - v_deriv_auto;
max(max(abs(diff)))
