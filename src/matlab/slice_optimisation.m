function [x, y] = slice_optimisation(f, x, iterations, width, return_when_flat)

% startup stuff
D = numel(x);
try
    y = f(x);
catch
	y = intmax;
    fprintf(' cholesky error!\n');
	return
end
Y = nan(iterations, 1);
if nargin<3, iterations = 100; end
if nargin<4, width = 1; end
if nargin<5, return_when_flat = true; end

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
            try
                y_new = f(xprime);
            catch
                y = intmax;
                fprintf(' cholesky error!\n');
                return
            end
            
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
    
    Y(i) = y;
    
    if i > 5 && return_when_flat
        if abs(y - Y(i - 5)) < 0.01
            fprintf(' flat. Returning %f\n', y);
            return
        end
    end
end

%fprintf('\n(%.2f -> %.2f)\n', Y(1), y);
fprintf('\n');


