clf; hold on;

x = [0.001, 0.002, 0.003, 0.004];
y = [0.12;
z = linspace(0, 1, 100)';

meanfunc =  @meanConst; hyp.mean = 0;
covfunc = {@covSum, {@covExpMixture1d, @covConst}}; 
hyp.cov = log([1 1 1 1]);
likfunc = @likGauss; hyp.lik = 1;

res = slice_sample_wrapper('exp', x, y, z);%gp_wrapper('exp', x, y, z);

for i = 1:length(res)
    model = res{i};
    m = model.m;
    sd = model.sd;
    
    plot(z, m);
    
end


% f = [m+2*sd; flipdim(m-2*sd,1)];
% fill([z; flipdim(z,1)], f, [7 7 7]/8)
% plot(z, m);
% plot(x, y, 'b+');
