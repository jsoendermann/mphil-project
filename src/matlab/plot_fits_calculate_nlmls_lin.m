files = dir('*.csv');

Ml = [];

for i = 1:length(files)
    % Load data
    file = files(i);
    D = csvread(file.name, 1);
    disp(file.name);
    id = D(1,1);
    x = D(:,2);
    y = D(:,3);
    z = linspace(0.1, 2, 50)';
    
    % Fit linear kernel
    [hyp_opt, m, sd] = gp_wrapper('linear', x, y);
    nlml_lin = gp(hyp_opt, @infExact, @meanZero, {@covSum, {{@covProd, {@covConst, @covLIN}}, @covConst}}, @likGauss, x, y);
    
    % Fit SE
    hyp2.cov = log([1 1]);
    hyp2.lik = log(1);
    hyp2_opt = minimize(hyp2, @gp, -100, @infExact, [], @covSEiso, @likGauss, x, y);
    nlml_se = gp(hyp2_opt, @infExact, [], @covSEiso, @likGauss, x, y);
    
    fprintf('Lin: %.3f; Se: %.3f\n', nlml_lin, nlml_se);
    
    Ml = [Ml; [id nlml_lin nlml_se (nlml_lin-nlml_se)]];
    
    % Make predictions
    [~,~,m_lin, var_lin] = gp(hyp_opt, @infExact, [], {@covSum, {{@covProd, {@covConst, @covLIN}}, @covConst}}, @likGauss, x, y, z);
    [~,~,m_se, var_se] = gp(hyp2_opt, @infExact, [], @covSEiso, @likGauss, x, y, z);
     
    sd_exp = sqrt(var_lin);
    sd_se = sqrt(var_se);
    
    % Plot
    clf;
    hold on; 
    plot(x, y, 'k+')
    
    plot(z, m_lin,'r');
    plot(z, m_lin + 2*sd_exp, 'r:');
    plot(z, m_lin - 2*sd_exp, 'r:');
    
    plot(z, m_se, 'b');
    plot(z, m_se + 2*sd_se, 'b:');
    plot(z, m_se - 2*sd_se, 'b:');
    
    hold off;
    print('-dpdf', sprintf('lin_fits_out/%s.pdf', file.name));
end
