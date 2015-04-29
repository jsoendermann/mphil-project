function plot_one_param_vs_time_and_score(D, parameter_index, time_index, score_index, label_table, label_x, label_y1, label_y2)

if nargin<7, label_y1 = 'Time'; end
if nargin<8, label_y2 = 'Score'; end


[ax, ~, ~]=plotyy(D(:,parameter_index), ...
                    D(:,time_index), ...
                    D(:,parameter_index), ...
                    D(:,score_index), 'plot','plot');

title(label_table); % label table
xlabel(ax(1), label_x) % label x-axis
ylabel(ax(1), label_y1) % label left y-axis
ylabel(ax(2), label_y2) % label right y-axis

grid(ax(2),'on')

end