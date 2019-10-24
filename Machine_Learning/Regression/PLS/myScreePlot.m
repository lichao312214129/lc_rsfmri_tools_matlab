function myScreePlot(SS,K,XAX,lam)

% Adapted for PLS-SVD

% IN:
%   SS: singular values values
%   K: cut-off
%   XAX: x axis limits
%   lam: null distribution lambda

if nargin<3
    XAX=[1 length(SS)]; 
end

% pos=get(gcf,'position');
% set(gcf,'Position',[pos(1) pos(2) 1300 300])

title('Scree plot')
EV=cumsum(SS.^2/sum(SS.^2))*100;
a=find(EV>80);

%plot(EV,'b-*','Linewidth',1)
% hold on;
% plot(SS.^2/sum(SS.^2)*100,'k-o','Linewidth',1);
% line([K K],[0 100],'Color','r');
% line([1 length(SS)],[1 1]*100/length(SS),'Color','b');
% axis tight
% ylim([0 SS(1).^2/sum(SS.^2)*101]);
% xlabel('Eigenvalue number'); ylabel('Percent explained variance')
% legend({'Variance','Selected cut-off'},'Location','NorthEast')
% grid on
% set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.02 .02] ,'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on','YTick' , 10:10:100);

% plot(SS,'b-o','MarkerSize',4)
% hold on
% line([K K],[0 max(SS)],'Color','r')
% axis tight
% ylim([0 max(SS)])
% %xlim([1 a(1)])
% xlabel('Eigenvalue number'); ylabel('Eigenvalue')
% le=legend({'Eigenvalue','Selected cut-off'},'Location','NorthEast');
% legend(le,'boxoff')
% %grid on
% set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.02 .02] ,'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on','YTick' , 10:10:max(SS));


[AX,H1,H2] = plotyy(1:length(SS),SS,1:length(SS),EV,'plot','plot');
hold on; stem(SS,'color','k');
set(get(AX(1),'Ylabel'),'String','Singular value','fontsize',16) 
set(get(AX(2),'Ylabel'),'String','Explained covariance','fontsize',16) 
xlabel('Latent variable','fontsize',16);
axes(AX(1))
ylim([0 1.01*max(SS)]); xlim(XAX)
%set(H1,'LineStyle','-','Marker','o')
set(H1,'color','w');
set(H2,'color','b'); set(AX,{'ycolor'},{'k';'b'}) 
set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.01 .01] ,'XMinorTick'  , 'on'      , ...
     'YMinorTick'  , 'on'); %,'YTick' , 100:100:700);
if exist('lam','var')
     hold on; 
    %errorbar(1:XAX(2), mean(lam(:,1:XAX(2))), std(lam(:,1:XAX(2))),'color','k');
%     plot(prctile(lam(:,1:XAX(2)),95),'k.-');
     line(XAX,[1 1]*prctile(max(lam),95),'color','k')
%     a=find(SS(1:size(lam,2))'>prctile(lam,95));
%     plot(a(end),SS(a(end)),'r','Marker','o','MarkerFaceColor','r')
%     disp(a(end))
     a=find(SS(1:length(lam))'>prctile(max(lam),95));
    plot(a(end),SS(a(end)),'r','Marker','o','MarkerFaceColor','r')
    disp(a(end))
end
 
 
axes(AX(2))
ylim([0 100]); xlim(XAX)
set(H2,'LineStyle','-')
if exist('K','var')
    hold on; line([K K],[0 100],'Color','k');
end
%grid on
set(gca,'YGrid','on');
%set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.01 .01] ,'XMinorTick'  , 'on'      , ...
%    'YMinorTick'  , 'on','YTick' , 10:10:100);
set(gca,'Box', 'off','TickDir', 'out','TickLength'  , [.01 .01] ,'XMinorTick'  , 'on'      , ...
    'YMinorTick' , 'on');

