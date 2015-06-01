files = dir('*.csv');

Ml = [];

for i = 12
    file = files(i);
    D = csvread(file.name, 1);
    disp(file.name);
    
    id = D(1,1);
    x = D(:,2);
    y = D(:,4);
    z = linspace(0.1, 2, 50)';
    
    

    [hyp_opt, m, sd] = gp_wrapper('exp', x, y);
    nlml_exp = gp(hyp_opt, @infExact, @meanZero, {@covSum, {@covExpMixture1d, @covConst}}, @likGauss, x, y);
    
    hyp2.cov = log([1 1]);
    hyp2.lik = log(1);
    hyp2_opt = minimize(hyp2, @gp, -100, @infExact, [], @covSEiso, likfunc, x, y);
    nlml_se = gp(hyp2_opt, @infExact, [], @covSEiso, likfunc, x, y);
    
    fprintf('Exp: %.3f; SE: %.3f\n', nlml_exp, nlml_se);
    
    Ml = [Ml; [id nlml_exp nlml_se (nlml_exp-nlml_se)]];
    
    [~,~,m_exp, var_exp] = gp(hyp_opt, @infExact, [], {@covSum, {@covExpMixture1d, @covConst}}, @likGauss, x, y, z);
    [~,~,m_se, var_se] = gp(hyp2_opt, @infExact, [], covfunc, likfunc, x, y, z);
    
    clf;
    %f_exp = [m_exp+2*sqrt(var_exp); flipdim(m_exp-2*sqrt(var_exp),1)];
    %fill([z; flipdim(z,1)], f_exp, [7 7 7]/8);
    
    %f_se = [m_se+2*sqrt(var_se); flipdim(m_se-2*sqrt(var_se),1)];
    %fill([z; flipdim(z,1)], f_se, [7 7 7]/8);
    
    sd_exp = sqrt(var_exp);
    sd_se = sqrt(var_se);
    
    hold on; 
    plot(x, y, 'k+')
    
    plot(z, m_exp,'r');
    plot(z, m_exp + 2*sd_exp, 'r:');
    plot(z, m_exp - 2*sd_exp, 'r:');
    
    plot(z, m_se, 'b');
    plot(z, m_se + 2*sd_se, 'b:');
    plot(z, m_se - 2*sd_se, 'b:');
    
    hold off;
    print('-dpdf', sprintf('fits_out/%s.pdf', file.name));
    
end