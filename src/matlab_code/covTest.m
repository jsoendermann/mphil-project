function K = covTest(hyp, x, z, i)

% Exponential mixture kernel from freeze thaw paper
%
% hyp = [ log(sqrt(sf2))
%         log(alpha)
%         log(beta) ]
%
% Copyright (c) by James Robert Lloyd 2015

if nargin<2, K = '3'; return; end             % report number of parameters
if nargin<3 || numel(z) == 0, z = x; end                               % make sure, z exists
dg = strcmp(z,'diag') && numel(z)>0;                       % determine mode

sf2 = exp(2*hyp(1));
alpha = exp(hyp(2));
beta = exp(hyp(3));

x_mat = repmat(x, 1, numel(z));
z_mat = repmat(z', numel(x), 1);

if nargin < 4
    if dg                                                      % vector kxx
      K = sf2 * (beta ^ alpha) ./ ((x + x + beta) .^ alpha);
    else                                                      % covariances
      K = sf2 * (beta ^ alpha) ./ ((x_mat + z_mat + beta) .^ alpha);
    end
else                                           % derivatives
    K = sf2 * (beta ^ alpha) ./ ((x_mat + z_mat + beta) .^ alpha);
    if i == 1                                  % sf
        K = 2 * K;
    elseif i == 2                              % psi
        K = K .* (log(beta) * alpha - alpha*log(beta + x_mat + z_mat));
        
    elseif i == 3                              % xi
        K = K .* (alpha - alpha*beta./(x_mat + z_mat + beta));
    else
        error('Unknown hyperparameter')
    end
end
end