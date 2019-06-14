% bar
y = rand(20,1);
h = bar(y, 0.01, 'EdgeColor',[.5, .5, .5],'FaceColor', [.5 .5 .5]);
ax = gca;
box off
ax.XTick =  1:length(y);
ax.XTickLabels ={'right amagydala '};
set(ax,'Fontsize',10);%设置ax标尺大小
% set(ax,'ytick',-0.1:0.05:0.1);
ax.XTickLabelRotation = 90;

% circle
hold on;
h1 = plot(1:length(y),y, 'o');
h1.MarkerSize=10;
h1.MarkerFaceColor='g';
h1.Color='g';

% save
print(gcf,'-dtiff', '-r300','bartext.tif')