function [x] = gradient_based_optimisation(f, grad_f, x, iterations, width)

y = f(x);
if nargin<4, iterations = 100; end
if nargin<5, width = 1; end


for i = 1:iterations
    fprintf('Iteration: %d; current value: %f\n', i, y);
    
    grad = -grad_f(x);
    
    dist = width; 
    while dist > 0.01
        x_prime = x + dist * grad;
        y_prime = f(x_prime);
        if y_prime < y
            y = y_prime;
            x = x_prime;
            break;
        end
        
        dist = dist / 2;
    end
end