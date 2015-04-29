% for n_s = 5000:5000:25000
%     RF = csvread(sprintf('data_rnd_forest_synth___n_features-500__n_classes-2__n_samples-%d.csv',n_s), 1);
%     LR = csvread(sprintf('data_log_reg_synth___n_features-500__n_classes-2__n_samples-%d.csv',n_s), 1);
%     
%     clf;
%     hold on;
%     [ax,p1,p2]=plotyy(RF(:,3), RF(:,4), LR(:,3), LR(:,4), 'plot','plot');
%     ylabel(ax(1),'Random forest score') % label left y-axis
%     ylabel(ax(2),'Logistic regression score') % label right y-axis
%     xlabel(ax(1),'time') % label x-axis
%     grid(ax(2),'on')
%     title(sprintf('#samples: %d', n_s));
%     
%     print('-dpng', sprintf('vis_out/%d.png', n_s));
% end

name = 'abalone';
 name = 'car';
 name = 'germancredit';
 name = 'krvskp';
 name = 'mnist';
 name = 'semeion';
% name = 'shuttle';
% name = 'waveform';
% name = 'winequalitywhite';

    LR = csvread(sprintf('data_log_reg_%s.csv', name), 1);
    RF = csvread(sprintf('data_rnd_forest_%s.csv', name), 1);
    
    RF = RF(and(RF(:,2)==512, RF(:,3)==1024),:);
    
    d = D(D(:,3)==1000,:);
    
    clf;
    hold on;
    [ax,p1,p2]=plotyy(RF(:,5), RF(:,6), LR(:,3), LR(:,4), 'plot','plot');
    ylabel(ax(1),'Random forest score') % label left y-axis
    ylabel(ax(2),'Logistic regression score') % label right y-axis
    xlabel(ax(1),'time') % label x-axis
    grid(ax(2),'on')
    %title(sprintf('#samples: %d', n_s));
    
    %print('-dpng', sprintf('vis_out/%d.png', n_s));
