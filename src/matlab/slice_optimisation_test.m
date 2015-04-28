%f = @(x) x^2;
%slice_optimisation(f, 30, 10000)

f = @(x) x(1)^2 + x(2) ^ 2;
slice_optimisation(f, [200 -300], 10000)