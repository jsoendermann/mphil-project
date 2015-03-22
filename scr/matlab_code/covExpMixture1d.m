function K = covExpMixture1d(hyp, x, z, i)

% Exponential mixture kernel from freeze thaw paper reparameterised with
% psi = E(x) = a/b and xi = Var(x)/E^2(x) = a/b^2 * b^2/a^2 = 1/a
%
% hyp = [ log(sf)
%         log(psi)
%         log(xi) ]
%
% Copyright (c) by James Robert Lloyd & Jan Soendermann, 2015


if nargin<2, K = '3'; return; end              % report number of parameters
if nargin<3 || numel(z) == 0, z = x; end       % make sure z exists
dg = strcmp(z,'diag') && numel(z)>0;           % determine mode


sf2 = exp(2*hyp(1));
%sf2 = exp(hyp(1))^2;
psi = exp(hyp(2));
xi =  exp(hyp(3));

h2 = hyp(2);
h3 = hyp(3);

x_mat = repmat(x, 1, numel(z));
z_mat = repmat(z', numel(x), 1);

if nargin < 4
    if dg
        K = sf2 * ones(size(x, 1), 1);
    else
        % disp(sprintf('psi: %d', psi));
        % disp(sprintf('xi: %d', xi));
        K = sf2 * (1/(psi*xi)) ^ (1/xi) ./ ((x_mat + z_mat + (1/(psi*xi))) .^ (1/xi));
        %K = sf2 * exp(-h2-h3) ^ exp(-h3) ./ ((x_mat + z_mat + exp(-h2-h3)) .^ exp(-h3));
    end
    
else                                           % derivatives
%     delta = 1e-10;
%     hyp_min = hyp;
%     hyp_pls = hyp;
%     hyp_min(i) = hyp(i)- delta/2;
%     hyp_pls(i) = hyp(i)+ delta/2;
%     
%     v_min = covExpMixture1d(hyp_min, x, z);
%     v_pls = covExpMixture1d(hyp_pls, x, z);
%     
%     disp(sprintf('v_m: %f; v_p: %f', v_min, v_pls));
%     
%     K = (v_pls - v_min) ./ delta;
%     
%     disp(sprintf('covExpMixture1d(log([%f %f %f]), %f, %f, %d) = %f', exp(hyp(1)), exp(hyp(2)), exp(hyp(3)), x, z, i, K));
    
    
    if i == 1                                    % sf
        
        K = 2 * sf2 * (1/(psi*xi)) ^ (1/xi) ./ ((x_mat + z_mat + (1/(psi*xi))) .^ (1/xi));
        
    elseif i == 2                                % psi
        % TODO express this in terms of psi and xi
        
        K = sf2 * (exp(-2*h3-h2)*exp(-h2-h3)^exp(-h3)*(exp(-h3-h2)+x_mat+z_mat).^(-exp(-h3)-1) - ...
            exp(-2*h3-h2) * exp(-h3-h2)^(exp(-h3)-1)*(exp(-h3-h2) + x_mat+z_mat).^(-exp(-h3)));
        
    elseif i == 3                                % xi
        
        % TODO express this purely in terms of psi and xi
        s_1 = (1/(xi*psi))^(1/xi)*(1/xi*(h2+h3)-1/xi)*(x_mat+z_mat+1/(xi*psi)).^(-exp(-h3));
        s_2 = exp(-h2-h3)^exp(-h3)*(x_mat + z_mat + exp(-h2-h3)).^(-exp(-h3)) .* ...
            (exp(-h3)*log(exp(-h3-h2)+x_mat+z_mat) + exp(-2*h3-h2) ./ (x_mat + z_mat + exp(-h2-h3)));
        
        %disp(sprintf('s_1: %d', s_1));
        %disp(sprintf('s_2: %d', s_2));
        
        K = sf2 * (s_1+s_2);
        
        
    else
        error('Unknown hyperparameter')
    end
end
end