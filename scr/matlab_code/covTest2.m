function K = covExpMixture1d(hyp, x, z, i)

% Exponential mixture kernel from freeze thaw paper
%
% hyp = [ log(sqrt(sf2))
%         log(alpha)
%         log(beta) ]
%
% Copyright (c) by James Robert Lloyd 2015

if nargin<2, K = '3'; return; end             % report number of parameters
if nargin<3, z = x; end                               % make sure, z exists
dg = strcmp(z,'diag') && numel(z)>0;                       % determine mode

sf2 = exp(2*hyp(1));
alpha = exp(hyp(2));
beta = exp(hyp(3));

if nargin < 4
    if dg                                                      % vector kxx
      K = sf2 * ones(size(x,1),1);
    else                                                      % covariances
      K = sf2 * (beta ^ alpha) ./ ((repmat(x, 1, numel(z)) + ...
                              repmat(z', numel(x), 1) + beta) .^ alpha);
    end
else % derivatives
  error('Derivatives not implemented yet')
end