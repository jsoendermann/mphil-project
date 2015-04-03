files = dir('*.csv');

for f = files'
    Ds = csvread(f.name, 1);

    
    d = Ds(and(Ds(:,2)==512, Ds(:,3)==1000),:);
    
    
    clf;
    hold on;
    [ax,p1,p2]=plotyy(d(:,4), d(:,5), d(:,4), d(:,6), 'plot','plot');
    ylabel(ax(1),'Time') % label left y-axis
    ylabel(ax(2),'Score') % label right y-axis
    xlabel(ax(1),'% data') % label x-axis
    grid(ax(2),'on')
    title(f.name);
    
    print('-dpng', sprintf('vis_out/%s.png', f.name));
end

%log reg
%lasso reg
%geometric

%on server: synth
%on com: lin reg

%covMask
%ignore time to think b/c it's constant, for large dtsets it doesn't matter
%investigate time hinge