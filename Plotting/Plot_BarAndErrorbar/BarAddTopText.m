bar(abs(weight_sort(1:50)),'BarWidth',0.5,'Horizontal','off','EdgeColor',[.5 .5 .5],'FaceColor',[.7 .7 .7],...
    'LineStyle','-');
ax=gca;
% x
% nColors = numel(ax.XTickLabel);
% cm = jet(nColors);
% for i = 1:nColors
%     ax.XTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', cm(i,:), ax.XTickLabel{i});
% end
set(gca,'xtick',[],'xticklabel',[])
% y
% label
ylabel('Classification Weight')
xlabel('Radiomics')
% top
for i=1:50
h=text(i,abs(weight_sort(i))+0.01,num2str(i),'VerticalAlignment','bottom','HorizontalAlignment','center');
set(h,'FontSize',10);
end
%
set(gca,'FontSize',15);
box off