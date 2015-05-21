%% SE
x = linspace(-3, 3);
y = exp(-x.^2 / 2);

plot(x, y, 'b', 'LineWidth', 6);
axis([-3,3,0,1.05]);

set(gca,'YTick',[]);
set(gca,'XTick', [0]);

ax = gca;
ax.XTickLabel = {''};

%% SE w/ different l's

x = linspace(-3, 3);

clf;
hold on;
for l = 0.5:0.5:1.5
    y = exp(-x.^2 / (2*l^2));

    plot(x, y, 'LineWidth', 6);    
end

axis([-3,3,0,1.05]);

set(gca,'YTick',[]);
set(gca,'XTick', [0]);

ax = gca;
ax.XTickLabel = {''};
hold off;

%% Linear
c = -1;

x = linspace(-3, 3);
y = -c .* (x - c);

plot(x, y, 'b', 'LineWidth', 6);
%axis([0,1,0,1]);

%set(gca,'YTick',[]);
%set(gca,'XTick', [0]);

ax = gca;
%ax.XTickLabel = {''};