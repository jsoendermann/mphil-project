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
    
    threshold = y;
   
    dimensionUpdated = zeros(size(D));
    
    % Sweep through axes (simplest thing)
    for dim = randperm(D)
        
        x_l = x;
        x_r = x;
        xprime = x;

        % Create a horizontal interval (x_l, x_r) enclosing x
        r = rand;
        x_l(dim) = x(dim) - r * width;
        x_r(dim) = x(dim) + (1-r) * width;
        
        %fprintf(' Dimension %d; x(dim): %f; x_l(dim): %f; x_r(dim): %f\n', dim, x(dim), x_l(dim), x_r(dim));

        % Inner loop:
        % Propose xprimes and shrink interval until good one found
        for i = 1:15
            
            
            xprime(dim) = rand() * (x_r(dim) - x_l(dim)) + x_l(dim);
            y = f(xprime);
            
            %fprintf('  Step: %d; y: %f;\n', i, y);
            
            if y < threshold
                x(dim) = xprime(dim);
                dimensionUpdated(dim) = 1;
                break;
            else
                if xprime(dim) > x(dim)
                    x_r(dim) = xprime(dim);
                elseif xprime(dim) < x(dim)
                    x_l(dim) = xprime(dim);
                else
                    error('BUG DETECTED: Shrunk to current position and still not acceptable.');
                    %break;
                end
            end
        end
    end
    
    stayInMainLoop = any(dimensionUpdated);
end

