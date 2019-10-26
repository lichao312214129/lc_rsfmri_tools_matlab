CONST_WRITE_PLOTS=0; % export figures as EPS files
CONST_WRITE_PATH=''; % export path

theta = pi/16; % paper used values of 0,pi/4,pi/16

CONST_FREQ=0.005:0.001:0.3;
CONST_DELTA=2:1:75;
CONST_WINDOW=2*CONST_DELTA+1;
CONST_SHIFT=1:250;
CONST_TR=1;
CONST_WINDOW_SEC=CONST_WINDOW*CONST_TR;

FC=fun_dynFC_ana(theta,CONST_FREQ,CONST_DELTA,CONST_SHIFT,CONST_TR);

CONST_ALPHA=0.05;
CONST_DOF=CONST_WINDOW-2;
tval=tinv(1-CONST_ALPHA/2,CONST_DOF);
rval=tval./sqrt(CONST_DOF+tval.^2);

CONST_DOF_TR2=floor(CONST_WINDOW/2)-2;
tval_TR2=tinv(1-CONST_ALPHA/2,CONST_DOF_TR2);
rval_TR2=tval./sqrt(CONST_DOF_TR2+tval.^2);

CONST_DOF_TR3=max(round(CONST_WINDOW/3)-2,0);
tval_TR3=tinv(1-CONST_ALPHA/2,CONST_DOF_TR3);
rval_TR3=tval./sqrt(CONST_DOF_TR3+tval.^2);

%%
[~,idx_f1]=min((CONST_FREQ-0.010).^2);
[~,idx_f2]=min((CONST_FREQ-0.025).^2);
[~,idx_f3] =min((CONST_FREQ-0.05).^2);
[~,idx_f4] =min((CONST_FREQ-0.10).^2);

figure(1);
set(gcf,'Color',[1 1 1]);

h1=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.value(1,idx_f2,:,:),4)),'-r');
set(h1,'LineWidth',2);
hold on;

for iter=1:length(CONST_SHIFT),
    plot(CONST_WINDOW_SEC,squeeze(FC.full.value(1,idx_f2,:,iter)),'r--');
end;

axis([min(CONST_WINDOW_SEC) max(CONST_WINDOW_SEC) -1.5 1.5]);

xlabel('window length [sec]','FontSize',14);
ylabel('covariance','FontSize',14);

plot([1/0.025 1/0.025],[-1.5 1.5],'r:');

colormap(jet);
hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-depsc2',sprintf('%sdynFC-shifts-phase%d.eps',CONST_WRITE_PATH,round(pi/theta)));
end;

%%

if 0,
figure(2);

t=0:CONST_TR:200; 
w=31; w2=(w-1)/2;
x1=cos(2*pi*0.035*t);
x2=cos(2*pi*0.035*t+pi/6).*cos(2*pi*0.005*t);

dfc=zeros(size(x1));
dfc(:)=NaN;

tmp=corrcoef(x1,x2);
fc=tmp(1,2);

for iter=w2+1:length(t)-w2-1,
    x1seg=x1(iter-w2:iter+w2);
    x2seg=x2(iter-w2:iter+w2);
    tmp=corrcoef(x1seg,x2seg);
    dfc(iter)=tmp(1,2);
end;

set(gcf,'Color',[1 1 1]);

tvis=1:200;
subplot(3,1,1); 
h1=plot(t(tvis),x1(tvis),'r-');
axis([min(tvis) max(tvis) -1 1]);
axis off;
set(h1,'LineWidth',2);
hold on;
area(1:w,ones(w),'FaceColor',[0 0 0],'EdgeColor',[1 1 1]);
area(1:w,-ones(w),'FaceColor',[0 0 0],'EdgeColor',[1 1 1]);
alpha(.25);
hold off;

subplot(3,1,2); 
h2=plot(t(tvis),x2(tvis),'r-');
axis([min(tvis) max(tvis) -1 1]);
axis off;
set(h2,'LineWidth',2);
hold on;
area(1:w,ones(w),'FaceColor',[0 0 0],'EdgeColor',[1 1 1]);
area(1:w,-ones(w),'FaceColor',[0 0 0],'EdgeColor',[1 1 1]);
alpha(.25);
hold off;

subplot(3,1,3); 
h3=plot(t(tvis),dfc(tvis),'k-');
axis([min(tvis) max(tvis) -1 1]);
axis off;
set(h3,'LineWidth',2);
hold on;
h3=plot(t(tvis),fc*ones(size(tvis)),'b:');
set(h3,'LineWidth',2);
plot(t(w2+1),dfc(w2+1),'ko','MarkerSize',6);
h=line([2 1 1 2 1 1 2],[1 1 0 0 0 -1 -1]);
set(h,'Color',[0 0 0],'LineWidth',1.5);
h=line([min(t) max(t)],[0 0]);
set(h,'Color',[0 0 0],'LineWidth',0.5,'LineStyle',':');
colormap(jet);
hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-dpng',sprintf('%sexample.png',CONST_WRITE_PATH));
end;
end;

%%
figure(2);
set(gcf,'Color',[1 1 1]);

% hTR3=area(CONST_WINDOW,rval_TR3,0);
% set(hTR3,'FaceColor',0.85*[1 1 1]);
% set(hTR3,'EdgeColor','none');
% 
% hold on;
% 
% h=area(CONST_WINDOW,-rval_TR3,0);
% set(h,'FaceColor',0.85*[1 1 1]);
% set(h,'EdgeColor','none');
% %child=get(h,'Children');
% %set(child,'FaceAlpha',0.5);
% 
% hTR2=area(CONST_WINDOW,rval_TR2,0);
% set(hTR2,'FaceColor',0.65*[1 1 1]);
% set(hTR2,'EdgeColor','none');
% h=area(CONST_WINDOW,-rval_TR2,0);
% set(h,'FaceColor',0.65*[1 1 1]);
% set(h,'EdgeColor','none');
% 
% hTR1=area(CONST_WINDOW,rval,0);
% set(hTR1,'FaceColor',0.5*[1 1 1]);
% set(hTR1,'EdgeColor','none');
% h=area(CONST_WINDOW,-rval,0);
% set(h,'FaceColor',0.5*[1 1 1]);
% set(h,'EdgeColor','none');

%errorbar(CONST_DELTA,mean(FC.full.value(1,idx_f001,:,:),4),std(FC.full.value(1,idx_f001,:,:),[],4)) 
h1=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.value(1,idx_f1,:,:),4)),'-b');
set(h1,'LineWidth',2);
hold on;

%plot(CONST_DELTA,squeeze(min(FC.full.value(1,idx_f001,:,:),[],4)),'-r');
%errorbar(CONST_DELTA,mean(FC.full.value(1,idx_f005,:,:),4),std(FC.full.value(1,idx_f005,:,:),[],4),'r') 
h2=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.value(1,idx_f2,:,:),4)),'-r');
set(h2,'LineWidth',2);

h3=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.value(1,idx_f3,:,:),4)),'-g');
set(h3,'LineWidth',2);

h4=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.value(1,idx_f4,:,:),4)),'-k');
set(h4,'LineWidth',2);

plot(CONST_WINDOW_SEC,squeeze(min(FC.full.value(1,idx_f1,:,:),[],4)),'b--');
plot(CONST_WINDOW_SEC,squeeze(max(FC.full.value(1,idx_f1,:,:),[],4)),'b--');

plot(CONST_WINDOW_SEC,squeeze(min(FC.full.value(1,idx_f2,:,:),[],4)),'r--');
plot(CONST_WINDOW_SEC,squeeze(max(FC.full.value(1,idx_f2,:,:),[],4)),'r--');

plot(CONST_WINDOW_SEC,squeeze(min(FC.full.value(1,idx_f3,:,:),[],4)),'g--');
plot(CONST_WINDOW_SEC,squeeze(max(FC.full.value(1,idx_f3,:,:),[],4)),'g:');

plot(CONST_WINDOW_SEC,squeeze(min(FC.full.value(1,idx_f4,:,:),[],4)),'k--');
plot(CONST_WINDOW_SEC,squeeze(max(FC.full.value(1,idx_f4,:,:),[],4)),'k--');

%h=legend([h1 h2 h3 h4 hTR1 hTR2 hTR3],{'0.01','0.025','0.05','0.10','TR=1s','TR=2s','TR=3s'},'Location','SouthEast');
h=legend([h1 h2 h3 h4],{'0.01','0.025','0.05','0.10'},'Location','SouthEast');
set(h,'FontSize',14);
xlabel('window length [sec]','FontSize',14);
ylabel('covariance','FontSize',14);
axis([min(CONST_WINDOW_SEC) max(CONST_WINDOW_SEC) -1.5 1.5]);

plot([1/0.01 1/0.01],[-1.5 1.5],'b:');
plot([1/0.025 1/0.025],[-1.5 1.5],'r:');
plot([1/0.05 1/0.05],[-1.5 1.5],'g:');
plot([1/0.1 1/0.1],[-1.5 1.5],'k:');

colormap(jet);
hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-depsc2',sprintf('%sdynFC-freqs-phase%d.eps',CONST_WRITE_PATH,round(pi/theta)));
end;

%%
[x1,x2]=ndgrid(CONST_WINDOW_SEC,CONST_FREQ);

figure(3);
set(gcf,'Color',[1 1 1]);

surf(x1,x2,squeeze(mean(FC.full.value(1,:,:,:),4)).');
hold on;

shading interp;
view(0,90);
axis([min(x1(:)) max(x1(:)) min(x2(:)) max(x2(:))]);
colorbar
caxis([0 1]);
ylabel('frequency [Hz]','FontSize',14);
xlabel('window length [sec]','FontSize',14);

h=plot3(CONST_WINDOW_SEC,1./(CONST_WINDOW_SEC*CONST_TR),ones(size(CONST_WINDOW)),'w:');
set(h,'LineWidth',2.5);

colormap(jet);
hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-depsc2',sprintf('%sdynFC-mean.eps',CONST_WRITE_PATH));
end;

%%
[x1,x2]=ndgrid(CONST_WINDOW_SEC,CONST_FREQ);

figure(30);
set(gcf,'Color',[1 1 1]);

surf(x1,x2,squeeze(mean(FC.full.nvalue(1,:,:,:),4)).');
hold on;

shading interp;
view(0,90);
axis([min(x1(:)) max(x1(:)) min(x2(:)) max(x2(:))]);
colorbar
caxis([0 1]);
ylabel('frequency [Hz]','FontSize',14);
xlabel('window length [sec]','FontSize',14);

h=plot3(CONST_WINDOW_SEC,1./(CONST_WINDOW_SEC*CONST_TR),ones(size(CONST_WINDOW)),'w:');
set(h,'LineWidth',2.5);

colormap(jet);
hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-depsc2',sprintf('%sdynFC-mean-corr.eps',CONST_WRITE_PATH));
end;

%%
[x1,x2]=ndgrid(CONST_WINDOW_SEC,CONST_FREQ);

figure(4);
set(gcf,'Color',[1 1 1]);

surf(x1,x2,squeeze(max(FC.full.value(1,:,:,:),[],4)).'-squeeze(min(FC.full.value(1,:,:,:),[],4)).');
hold on;

shading interp;
view(0,90);
axis([min(x1(:)) max(x1(:)) min(x2(:)) max(x2(:))]);
colormap hot;
caxis([0 1]);
colorbar;
ylabel('frequency [Hz]','FontSize',14);
xlabel('window length [sec]','FontSize',14);

h=plot3(CONST_WINDOW_SEC,1./(CONST_WINDOW_SEC*CONST_TR),ones(size(CONST_WINDOW)),'w:');
set(h,'LineWidth',2.5);

hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-depsc2',sprintf('%sdynFC-max-min.eps',CONST_WRITE_PATH));
end;

%%
figure(5);
set(gcf,'Color',[1 1 1]);

hTR3=area(CONST_WINDOW_SEC,rval_TR3,0);
set(hTR3,'FaceColor',0.85*[1 1 1]);
set(hTR3,'EdgeColor','none');

hold on;

h=area(CONST_WINDOW_SEC,-rval_TR3,0);
set(h,'FaceColor',0.85*[1 1 1]);
set(h,'EdgeColor','none');
%child=get(h,'Children');
%set(child,'FaceAlpha',0.5);

hTR2=area(CONST_WINDOW_SEC,rval_TR2,0);
set(hTR2,'FaceColor',0.65*[1 1 1]);
set(hTR2,'EdgeColor','none');
h=area(CONST_WINDOW_SEC,-rval_TR2,0);
set(h,'FaceColor',0.65*[1 1 1]);
set(h,'EdgeColor','none');

hTR1=area(CONST_WINDOW_SEC,rval,0);
set(hTR1,'FaceColor',0.5*[1 1 1]);
set(hTR1,'EdgeColor','none');
h=area(CONST_WINDOW_SEC,-rval,0);
set(h,'FaceColor',0.5*[1 1 1]);
set(h,'EdgeColor','none');

%errorbar(CONST_DELTA,mean(FC.full.value(1,idx_f001,:,:),4),std(FC.full.value(1,idx_f001,:,:),[],4)) 
h1=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.nvalue(1,idx_f1,:,:),4)),'-b');
set(h1,'LineWidth',2);

%plot(CONST_DELTA,squeeze(min(FC.full.value(1,idx_f001,:,:),[],4)),'-r');
%errorbar(CONST_DELTA,mean(FC.full.value(1,idx_f005,:,:),4),std(FC.full.value(1,idx_f005,:,:),[],4),'r') 
h2=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.nvalue(1,idx_f2,:,:),4)),'-r');
set(h2,'LineWidth',2);

h3=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.nvalue(1,idx_f3,:,:),4)),'-g');
set(h3,'LineWidth',2);

h4=plot(CONST_WINDOW_SEC,squeeze(mean(FC.full.nvalue(1,idx_f4,:,:),4)),'-k');
set(h4,'LineWidth',2);

plot(CONST_WINDOW_SEC,squeeze(max(min(FC.full.nvalue(1,idx_f1,:,:),[],4),-1)),'b--');
plot(CONST_WINDOW_SEC,squeeze(min(max(FC.full.nvalue(1,idx_f1,:,:),[],4),+1)),'b--');

plot(CONST_WINDOW_SEC,squeeze(max(min(FC.full.nvalue(1,idx_f2,:,:),[],4),-1)),'r--');
plot(CONST_WINDOW_SEC,squeeze(min(max(FC.full.nvalue(1,idx_f2,:,:),[],4),+1)),'r--');

plot(CONST_WINDOW_SEC,squeeze(max(min(FC.full.nvalue(1,idx_f3,:,:),[],4),-1)),'g--');
plot(CONST_WINDOW_SEC,squeeze(min(max(FC.full.nvalue(1,idx_f3,:,:),[],4),+1)),'g:');

plot(CONST_WINDOW_SEC,squeeze(max(min(FC.full.nvalue(1,idx_f4,:,:),[],4),-1)),'k--');
plot(CONST_WINDOW_SEC,squeeze(min(max(FC.full.nvalue(1,idx_f4,:,:),[],4),+1)),'k--');

h=legend([h1 h2 h3 h4 hTR1 hTR2 hTR3],{'0.01','0.025','0.05','0.10','TR=1s','TR=2s','TR=3s'},'Location','SouthEast');
set(h,'FontSize',14);
xlabel('window length [sec]','FontSize',14);
ylabel('correlation','FontSize',14);
axis([min(CONST_WINDOW_SEC) max(CONST_WINDOW_SEC) -1 1]);

plot([1/0.01 1/0.01],[-1.5 1.5],'b:');
plot([1/0.025 1/0.025],[-1.5 1.5],'r:');
plot([1/0.05 1/0.05],[-1.5 1.5],'g:');
plot([1/0.1 1/0.1],[-1.5 1.5],'k:');

colormap(jet);
hold off;

if CONST_WRITE_PLOTS,
    print(gcf,'-depsc2',sprintf('%sdynFC-corr-freqs-phase%d.eps',CONST_WRITE_PATH,round(pi/theta)));
end;
