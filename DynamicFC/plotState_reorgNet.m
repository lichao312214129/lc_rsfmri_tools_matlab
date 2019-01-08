j=[4 3 2 1];
for i =1:4
    file=['Cluster_',num2str(j(i)),'.mat'];
    load(file);
    reorgNet=lc_ReorganizeNetForYeo17NetAtlas(squareMat);
    reorgNet(eye(114)==1)=1;
    subplot(2,2,i)
    lc_InsertSepLineToNet(reorgNet);
    colorbar
    axis off;
    axis square;
end
% set(gcf,'outerposition',get(0,'screensize'));
% set(gcf,'outerposition',get(0,'screensize'));
set(gcf,'Position',get(0,'ScreenSize'))
name=['allState20_4'];
print(gcf,'-dtiff','-r300',name)