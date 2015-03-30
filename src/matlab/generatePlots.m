ids = unique(D(:,1));

for i = 1:length(ids)
    ds_id = ids(i);
    Ds = D(D(:,1)==ds_id,:);
    
    d = Ds(and(Ds(:,2)==512, Ds(:,3)==2048),:);
    
    
    clf;
    hold on;
    [ax,p1,p2]=plotyy(d(:,4), d(:,5), d(:,4), d(:,6), 'plot','plot');
    ylabel(ax(1),'Time') % label left y-axis
    ylabel(ax(2),'Score') % label right y-axis
    xlabel(ax(1),'% data') % label x-axis
    grid(ax(2),'on')
    
    print('-dpng', sprintf('vis_out/ds_%02d.png', ds_id));
end

log reg
lasso reg
geometric

on server: synth
on com: lin reg