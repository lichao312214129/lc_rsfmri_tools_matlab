function lc_plotbar(all_mean,error)
% Plot bar and add errorbar
% Inputs:
% 	mean_all: all mean values with N row by M column matrix (N variables, M groups), each row is one variable of all group
% 	error_all: all error values with N row by M column matrix(N variables, M groups), each row is one variable of all group
%   error_all could be STD or SSE etc.
% clear matrix
% ng = 4;
% for i = 1:ng
%     matrix{i}=rand(10,3);
% end
% all_mean=cell2mat(cellfun(@(x) mean(x,1),matrix,'UniformOutput',false)')';
% error=cell2mat(cellfun(@(x) std(x),matrix,'UniformOutput',false)')';
% Example:
% error = [0.0398, 0.0424, 0.0196, 0.0312;...
%     		0.0875, 0.0990, 0.1034, 0.0939;...
%     		0.09, 0.0990, 0.1034, 0.0939];
% 
% all_mean = [0.9186, 0.9460, 0.9552, 0.9533;...
% 			0.6090, 0.6663, 0.7170, 0.7165;...
% 			0.6, 0.633, 0.5170, 0.6165];
% lc_plotbar(all_mean, error)

% set color of each bar
h = bar(all_mean, 'grouped');
num_subh = length(h);
color = linspace(1,0,num_subh);
for i = 1:num_subh
    set(h(i), 'facecolor', repmat(color(i),1,3),'EdgeColor','k','LineWidth',2,'FaceAlpha',0.8);
end
% set(h(2), 'facecolor', [0.8,0.8,0.8],'EdgeColor','k','LineWidth',2,'FaceAlpha',.6);
% set(h(3), 'facecolor', [0.5,0.5,0.5],'EdgeColor','k','LineWidth',2,'FaceAlpha',.8);
% set(h(4), 'facecolor', [0.1,0.1,0.1],'EdgeColor','k','LineWidth',2,'FaceAlpha',.8);

set(gca,'XTickLabel',{''}, 'FontSize', 15);
ylabel('');
hold on

numgroups = size(all_mean, 1); 
numbars = size(all_mean, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, all_mean(:,i),error(:,i), 'k', 'linestyle', 'none', 'lineWidth', 2);
end

set(gca,'LineWidth',2);
set(gca,'tickdir','out');
box off
% set(gca, 'Ytick', [0.5:0.05:1]);
legend({'','','',''}, 'Location', 'northoutside','Orientation','horizon')
legend('boxoff');

end