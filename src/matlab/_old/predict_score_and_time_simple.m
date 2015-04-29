d = D(and(D(:,2)==512, D(:,3)==1000),:);

x = d(:,4);
y = d(:,6);

z = x;
x_s = x(1:5);
y_s = y(1:5);


meanfunc = @meanZero;
hyp.mean = [];

covfunc = {@covSum, {@covTest, @covConst}};
hyp.cov = log([2 2 1 1]);

likfunc = @likGauss;
hyp.lik = log(0.1);

hyp_opt = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, x_s, y_s);
[~, ~, m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, x_s, y_s, z);

sd = sqrt(s2);

clf;
hold on; 
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([t_star; flipdim(t_star,1)], f, [7 7 7]/8)
plot(z, m);
plot(x, y, 'bo');
plot(x_s, y_s, 'rx');
%plot(z, y, '+');
% plot(t_star, y_test, 'x');