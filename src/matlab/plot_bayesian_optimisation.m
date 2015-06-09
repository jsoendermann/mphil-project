%% Set up kernel
meanfunc =  @meanConst; hyp.mean = 0;

covfunc = @covSEiso; 
hyp.cov = log([1 1]);

likfunc = @likGauss; hyp.lik = 0.1;


%% Generate data
x_max = 10;
n = 100;

x = linspace(0, x_max, n)';

K = feval(covfunc, hyp.cov, x);
K = K + 1e-6*eye(n);
y = chol(K)'*randn(n, 1);

z = x;
% fit & plot


points = [x y];
seen_points = points([5,27,40,52,63,71,80],:);
sx = seen_points(:,1);
sy = seen_points(:,2);



hyps_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, sx, sy);
[~,~,m,s2] = gp(hyps_opt, @infExact, meanfunc, covfunc, likfunc, sx, sy, z);

s = sqrt(s2);

f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)]; 

clf;
%win = figure;

subplot(3,1,1);
hold on; 
grid on;
fill([z; flipdim(z,1)], f, [7 7 7]/8)
plot(z, m, 'r');
plot(x, y, 'b--')
plot(sx, sy, 'k+');

axis([0,x_max,-2,2.3])
hold off;

fmax = max(sy);
gamma = (m - fmax) ./ s;
pi = normcdf(gamma);

ei = nan(100,1);
for i = 1:100
    ei(i) = integral(@(y)((y-fmax)*normpdf((y-m(i))/s(i))),fmax,Inf)
    
end

%alpha = (fmax - m) ./ s;
%ei = m + s .* normpdf(alpha) ./ normcdf(-alpha) - fmax .* normcdf(-alpha)
%ei = s .* (gamma .* normcdf(gamma)) + normpdf(gamma);

subplot(3,1,2);
title('Probability of improvement');
hold on; 
grid on;
plot(x, pi);
hold off;


subplot(3,1,3);
title('Expected improvement');
hold on; 
grid on;
plot(x, ei);
hold off;