function lc_plotbar()
% Plot bar and add errorbar
% Inputs:
% 	mean_all: all mean values with N row by M column matrix (N variables, M groups), each row is one variable of all group
% 	error_all: all error values with N row by M column matrix(N variables, M groups), each row is one variable of all group
%   error_all could be STD or SSE etc.
% mean_all=cell2mat(cellfun(@(x) mean(x,1),matrix,'UniformOutput',false)')';
% Std=cell2mat(cellfun(@(x) std(x),Matrix,'UniformOutput',false)')';

error_all = [0.0398, 0.0424, 0.0196, 0.0312;...
    		0.0875, 0.0990, 0.1034, 0.0939;...
    		0.09, 0.0990, 0.1034, 0.0939];

mean_all = [0.9186, 0.9460, 0.9552, 0.9533;...
			0.6090, 0.6663, 0.7170, 0.7165;...
			0.6, 0.633, 0.5170, 0.6165];

% set color of each bar
h = bar(mean_all, 'grouped');
set(h(1), 'facecolor', [1,1,1],'EdgeColor','k','LineWidth',2,'FaceAlpha',.7);
set(h(2), 'facecolor', [0.8,0.8,0.8],'EdgeColor','k','LineWidth',2,'FaceAlpha',.6);
set(h(3), 'facecolor', [0.5,0.5,0.5],'EdgeColor','k','LineWidth',2,'FaceAlpha',.8);
set(h(4), 'facecolor', [0.1,0.1,0.1],'EdgeColor','k','LineWidth',2,'FaceAlpha',.8);

set(gca,'XTickLabel',{'LIVE', 'TID2013'}, 'FontSize', 15);
ylabel('SRC');
hold on

numgroups = size(mean_all, 1); 
numbars = size(mean_all, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, mean_all(:,i),error_all(:,i), 'k', 'linestyle', 'none', 'lineWidth', 2);
end

set(gca,'LineWidth',2);
box off
% set(gca, 'Ytick', [0.5:0.05:1]);
legend('25','50','100','200', 'Location', 'northoutside','Orientation','horizon')
legend('boxoff');

end