function [x] = slice_optimisation(f, x, iterations, width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% startup stuff
D = numel(x);
y = f(x);
if nargin<3, iterations = 100; end
if nargin<4, width = 1; end


for i = 1:iterations
    fprintf('Iteration: %d; current value: %f\n', i, y);
    
    for dim = randperm(D)
        x_l = x;
        x_r = x;
        xprime = x;

        r = rand;
        x_l(dim) = x(dim) - r * width;
        x_r(dim) = x(dim) + (1-r) * width;

        for i = 1:15
            xprime(dim) = rand() * (x_r(dim) - x_l(dim)) + x_l(dim);
            y_new = f(xprime);
            
            if y_new < y
                y = y_new;
                x(dim) = xprime(dim);
                break;
            else
                if xprime(dim) > x(dim)
                    x_r(dim) = xprime(dim);
                elseif xprime(dim) < x(dim)
                    x_l(dim) = xprime(dim);
                else
                    break;
                end
            end
        end
    end
end

