function plot_TCS_dynconn(TCS,A,TMask,TR)
% plot time courses and dynamic connectivity matrices for all subjects
%
% IN:
%   TCS: cell array with the time courses of all subjects
%   A: cell with dynamic connectivity for all subjects
%    windowSize: length of window for dependency calculation
% optional
%     TR: to label axis in TRs instead of windows
% 
% v1.0 March 2013 Nora Leonardi, Dimitri Van De Ville

if nargin<4, TR=1; xlab='Scans (TR)';
else xlab='Time (s)';
end
if isempty(TMask), TMask=cell(length(TCS),1); end

% plot time course & CM
disp('Press the space bar to see the next subject');
figure; set(gcf,'position',[ 5   730   900   350]);

for s=1:length(A)
    subplot(121)
    tc=TCS{s};
    N=size(tc,1); T=size(tc,2);
    if isempty(TMask{s}), TMask{s}=1:T; end
    tc=tc(:,TMask{s});    
    imagesc((1:sum(TMask{s}))*TR,1:N,tc);
    caxis([-1 1]*max(abs(tc(:))))
    cbar=colorbar;
    ylabel(cbar,'Activity')
    xlabel(xlab); ylabel('Brain region')
    title('Brain activity')
    set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.02 .02] , ...
     'YMinorTick'  , 'on');
    set(gca, 'OuterPosition', [0 0 0.5 .95]) 
     
    subplot(122);   
    imagesc((1:size(A{s},2))*TR,1:size(A{s},1),A{s}); axis square; 
    caxis([-1 1]*max(A{s}(:)))
    cbar=colorbar;
    ylabel(cbar,'Correlation (z)')
    xlabel(xlab); ylabel('Correlation pairs')
    title('Dynamic connectivity')
    set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.02 .02] , ...
     'YMinorTick'  , 'on');
    set(gca, 'OuterPosition', [0.5 0 0.5 .95])
    
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 0.95,['Subject ' num2str(s)],'HorizontalAlignment','center','VerticalAlignment', 'top')   
    
    pause
end 