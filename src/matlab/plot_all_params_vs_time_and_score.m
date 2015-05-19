files = dir('*.csv');

for i = 1:length(files)
    file = files(i);
    D = csvread(file.name, 1);
    
    if size(D, 2) == 4
        plot_one_param_vs_time_and_score(D, 2, 3, 4, file.name, '% data used');
        print('-dpdf', sprintf('vis_out/%s.pdf', file.name));
        
    elseif size(D, 2) == 6
        plot_one_param_vs_time_and_score(D, 4, 5, 6, file.name, '% data used');
        print('-dpdf', sprintf('vis_out/%s.pdf', file.name));
    end
end