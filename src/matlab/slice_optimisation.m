function [x] = slice_optimisation(f, x, iterations, width)

% startup stuff
D = numel(x);
y = f(x);
initial_y = y;
if nargin<3, iterations = 100; end
if nargin<4, width = 1; end

%fprintf('Optimising: %7.2f', y);
fprintf('Optimising: %.2f', y);

for i = 1:iterations
    %fprintf('Iteration: %d; current value: %f\n', i, y);
    if mod(i, 5) == 0
        %fprintf('%7.2f', y);
        fprintf('%.2f', y);
    else
        fprintf('.');
    end
    
    for dim = randperm(D)
        x_l = x;
        x_r = x;
        xprime = x;

        r = rand;
        x_l(dim) = x(dim) - r * width;
        x_r(dim) = x(dim) + (1-r) * width;

        for j = 1:15
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

%fprintf('\n(%.2f -> %.2f)\n', initial_y, y);
fprintf('\n');


