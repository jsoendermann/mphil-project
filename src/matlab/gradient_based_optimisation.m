function [x] = gradient_based_optimisation(f, grad_f, x, iterations)

y = f(x);
if nargin<4, iterations = 100; end

for i = 1:iterations
    fprintf('Iteration: %d; current value: %f\n', i, y);
    
    grad = -grad_f(x);
    
    dist = 1 / norm(grad); % Plot in direction of gradient; for report plot nlmlfunc
    for j = 1:10
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