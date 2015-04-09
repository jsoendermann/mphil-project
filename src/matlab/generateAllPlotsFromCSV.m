files = dir('*.csv');

f = files(1)

D = csvread(f.name, 1);

u_t = unique(D(:,2));
u_l = unique(D(:,3));
u_d = unique(D(:,4));

% Data
% for i_t = 1:length(u_t)
%     n_t = u_t(i_t);
%     
%     for i_l = 1:length(u_l)
%         n_l = u_l(i_l);
%         
%         d = D(and(D(:,2)==n_t, D(:,3)==n_l),:);
%         
%         clf;
%         hold on;
%         [ax,p1,p2]=plotyy(d(:,4), d(:,5), d(:,4), d(:,6), 'plot','plot');
%         ylabel(ax(1),'Time') % label left y-axis
%         ylabel(ax(2),'Score') % label right y-axis
%         xlabel(ax(1),'% data') % label x-axis
%         grid(ax(2),'on')
%         title(sprintf('Trees: %d; Leafs:%d', n_t, n_l));
% 
%         print('-dpng', sprintf('vis_out/data_trees-%d_leafs-%d.png', n_t, n_l));
%     end
% end

% Leafs
% for i_t = 1:length(u_t)
%     n_t = u_t(i_t);
%     
%     for i_d = 1:length(u_d)
%         n_d = u_d(i_d);
%         
%         d = D(and(D(:,2)==n_t, D(:,4)==n_d),:);
%         
%         clf;
%         hold on;
%         [ax,p1,p2]=plotyy(d(:,3), d(:,5), d(:,3), d(:,6), 'plot','plot');
%         ylabel(ax(1),'Time') % label left y-axis
%         ylabel(ax(2),'Score') % label right y-axis
%         xlabel(ax(1),'Number of leafs') % label x-axis
%         grid(ax(2),'on')
%         title(sprintf('Trees: %d; %% Data:%d', n_t, n_d));
% 
%         print('-dpng', sprintf('vis_out/leafs_trees-%d_data-%f.png', n_t, n_d));
%     end
% end

% Trees
for i_l = 1:length(u_l)
    n_l = u_l(i_l);
    
    for i_d = 1:length(u_d)
        n_d = u_d(i_d);
        
        d = D(and(D(:,3)==n_l, D(:,4)==n_d),:);
        
        clf;
        hold on;
        [ax,p1,p2]=plotyy(d(:,2), d(:,5), d(:,2), d(:,6), 'plot','plot');
        ylabel(ax(1),'Time') % label left y-axis
        ylabel(ax(2),'Score') % label right y-axis
        xlabel(ax(1),'Number of trees') % label x-axis
        grid(ax(2),'on')
        title(sprintf('Leafs: %d; %% Data:%d', n_l, n_d));

        %print('-dpng', sprintf('vis_out/trees_leafs-%d_data-%f.png', n_l, n_d));
    end
end