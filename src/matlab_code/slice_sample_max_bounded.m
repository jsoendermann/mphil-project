function samples = slice_sample_max_bounded(N, burn, logdist, xx, widths, ...
                                    step_out, max_attempts, bounds, ...
                                    varargin)
%SLICE_SAMPLE simple axis-aligned implementation of slice sampling for vectors
%
%     samples = slice_sample(N, burn, logdist, xx, widths, step_out, varargin)
%
% Inputs:
%             N  1x1  Number of samples to gather
%          burn  1x1  after burning period of this length
%       logdist  @fn  function logprobstar = logdist(xx, varargin{:})
%            xx  Dx1  initial state (or array with D elements)
%        widths  Dx1  or 1x1, step sizes for slice sampling
%      step_out bool  set to true if widths may sometimes be far too small
%      varargin   -   any extra arguments are passed on to logdist
%
% Outputs:
%      samples  DxN   samples stored in columns (regardless of original shape)
%
% Iain Murray May 2004, tweaks June 2009, a diagnostic added Feb 2010
% See Pseudo-code in David MacKay's text book p375
%
% Modified by James Lloyd, May 2012 - max attempts
% Modified by James Lloyd, Jan 2015 - bounds
%
% User can specify number of slice attempts before giving up via
% max_attempts input
%
% Prevents algorithm from becoming very slow in peaky posterior but
% reduces mixing

% startup stuff
D = numel(xx);
samples = zeros(D, N);
if numel(widths) == 1
    widths = repmat(widths, D, 1);
end
log_Px = feval(logdist, xx, varargin{:});

% Main loop
for ii = 1:(N+burn)
%     ii
    %fprintf('Iteration %d                 \r', ii - burn);
    log_uprime = log(rand) + log_Px;
    
    % display(log_Px);
    % display(log_uprime);

    % Sweep through axes (simplest thing)
    for dd = randperm(D)
%         dd
        x_l = xx;
        x_r = xx;
        xprime = xx;

        % Create a horizontal interval (x_l, x_r) enclosing xx
        rr = rand;
        x_l(dd) = max(xx(dd) - rr*widths(dd), bounds(dd, 1));
        x_r(dd) = min(xx(dd) + (1-rr)*widths(dd), bounds(dd, 2));
        if step_out
            % Typo in early editions of book. Book said compare to u, but it should say u'
            steps = 0;
            while (feval(logdist, x_l, varargin{:}) > log_uprime) && ...
                  (x_l(dd) > bounds(dd, 1)) && (steps < max_attempts)
                x_l(dd) = max(x_l(dd) - widths(dd), bounds(dd, 1));
                steps = steps + 1;
            end
            steps = 0;
            while (feval(logdist, x_r, varargin{:}) > log_uprime) && ...
                  (x_r(dd) < bounds(dd, 2)) && (steps < max_attempts)
                x_r(dd) = min(x_r(dd) + widths(dd), bounds(dd, 2));
                steps = steps + 1;
            end
        end

        % Inner loop:
        % Propose xprimes and shrink interval until good one found
        zz = 0;
        num_attempts = 0;
        while 1
            zz = zz + 1;
            %fprintf('Iteration %d   Step %d       \r', ii - burn, zz);
            xprime(dd) = rand()*(x_r(dd) - x_l(dd)) + x_l(dd);
            log_Px = feval(logdist, xprime, varargin{:});
            if log_Px > log_uprime
                xx(dd) = xprime(dd);
                break;
            else
                % Shrink in
                num_attempts = num_attempts + 1;
                if num_attempts >= max_attempts
                    break;
                elseif xprime(dd) > xx(dd)
                    x_r(dd) = xprime(dd);
                elseif xprime(dd) < xx(dd)
                    x_l(dd) = xprime(dd);
                else
                    %error('BUG DETECTED: Shrunk to current position and still not acceptable.');
                    break;
                end
            end
        end
    end

    % Record samples
    if ii > burn
        samples(:, ii - burn) = xx(:);
    end
end
%fprintf('\n');

