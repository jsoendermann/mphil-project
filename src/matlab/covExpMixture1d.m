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
psi = exp(hyp(2));
xi =  exp(hyp(3));

x_mat = repmat(x, 1, numel(z));
z_mat = repmat(z', numel(x), 1);

if nargin < 4
    if dg
        K = sf2 * (1/(psi*xi)) ^ (1/xi) ./ (x + x + (1/(psi*xi))) .^ (1/xi);
    else
        K = sf2 * (1/(psi*xi)) ^ (1/xi) ./ (x_mat + z_mat + (1/(psi*xi))) .^ (1/xi);
    end
    
else                                           % derivatives
    if i == 1                                  % sf
        K = 2 * sf2 * (1/(psi*xi)) ^ (1/xi) ./ ((x_mat + z_mat + (1/(psi*xi))) .^ (1/xi));
    elseif i == 2                              % psi
        K = sf2 * (1/(psi*xi^2) * (1/(psi*xi))^(1/xi) * 1./(x_mat + z_mat + 1/(psi*xi)).^(1/xi+1) - ...
            1/(psi*xi^2) * (1/(psi*xi))^(1/xi-1) * 1./(x_mat + z_mat + 1/(psi*xi)).^(1/xi));
        
    elseif i == 3                              % xi
        s1 = (1/(psi*xi))^(1/xi) * (-1/xi*log(1/(psi*xi))-1/xi) * 1./(x_mat+z_mat+1/(psi*xi)).^(1/xi);
        s2 = (1/(psi*xi))^(1/xi) * 1./(x_mat + z_mat + 1/(psi*xi)).^(1/xi) * ...
            (1./((x_mat + z_mat + 1/(psi*xi))*psi*xi^2) + 1/xi*log(x_mat + z_mat + 1/(psi*xi)));
        
        K = sf2 * (s1+s2);
    else
        error('Unknown hyperparameter')
    end
end
end