randn('seed', 10);

 
% x = abs(randn(1000, 1)) * 100;
% z = abs(randn(900, 1)) * 10;
% hyp = log([20 1 5]);
% 
% V_old = feval(@covExpMixture1d_old, hyp, x, z, 1);
% V_new = feval(@covExpMixture1d_conv, hyp, x, z, 1);
% 
% max(max(V_old - V_new))



delta = 0.00001;
kernel = @covExpMixture1d; 
hyp = log([2 2 2]);
param_index = 2;

%randn('seed', 10);

% x = abs(randn(1000, 1)) * 100;
% z = abs(randn(900, 1)) * 10;

x = linspace(0.1, 0.2, 500)';
z = linspace(0.1, 0.4, 500)';

%x = linspace(0, 100, 100)';
%z = linspace(0, 10, 100)';

hyp_minus = hyp;
hyp_plus = hyp;
hyp_minus(param_index) = log(exp(hyp_minus(param_index)) - delta/2);
hyp_plus(param_index) = log(exp(hyp_plus(param_index)) + delta/2);


v_minus = feval(kernel, hyp_minus, x, z);
v_plus  = feval(kernel, hyp_plus,  x, z);

v_deriv_man = (v_plus - v_minus)/delta;
v_deriv_auto = feval(kernel, hyp, x, z, param_index);

diff = v_deriv_man - v_deriv_auto;

max(max(abs(diff)))
