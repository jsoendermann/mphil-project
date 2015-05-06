function [r] = slice_optimisation_with_restarts(restarts, f, x_in, iterations, width, return_when_flat)

if nargin<4, iterations = 100; end
if nargin<5, width = 1; end
if nargin<6, return_when_flat = true; end

X = {};
Y = nan(restarts, 1);
for i = 1:restarts
    fprintf('Restart %d; ', i);
    [x, y] = slice_optimisation(f, x_in, iterations, width, return_when_flat);
    X{i} = x;
    Y(i) = y;
end

[~,i] = min(Y);
fprintf('Best run: %d\n', i);
r = X{i};