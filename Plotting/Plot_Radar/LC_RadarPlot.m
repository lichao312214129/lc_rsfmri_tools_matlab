function  LC_RadarPlot(X,opt)
% input:
%     X: 1D array
%%
% LC_RadarPlot([.82,0.79,0.84,0.85])
if nargin <2 && ~exist('opt','var')
    fprintf('no opt')
    opt.linewidth=2;
    opt.linestyle='-';
    opt.color='b';
    opt.TickLabel={''};
else
    if ~isfield(opt,'linewidth')
        opt.linewidth=2;
    end
    if ~isfield(opt,'linestyle')
        opt.linestyle='-';
    end
    if ~isfield(opt,'color')
        opt.color='b';
    end
    if ~isfield(opt,'TickLabel')
        opt.TickLabel={''};
    end
end
%% =========================数据准备===============================
X=reshape(X,[],1);
% theta=linspace(0,360,numel(X));
X=[X;X(1)];
theta=linspace(0,360,numel(X));
NumOfTickLabel = deg2rad(theta);
%% =========================TickLabel===============================
TickLabel=opt.TickLabel;
%% =========================画雷达图===============================
polarplot(NumOfTickLabel,X,...
    'linewidth',opt.linewidth,'linestyle',opt.linestyle,'color',opt.color);
% polarplot(NumOfTickLabel,X,...
%     'linewidth',opt.linewidth,'linestyle',opt.linestyle);
%% ==================设置图片显示格式==============================
ax=gca;

% 背景
ax.Color ='w';%雷达图背景的颜色。

% 坐标范围
ax.ThetaLim = [0 360];%坐标轴的范围。

% 字体
ax.FontSize =10;%字体大小
ax.ThetaColor = 'k';%改变坐标字符颜色

% 网格
ax.ThetaGrid = 'on';%向外的直线网格显示与否。
ax.RGrid = 'on';%环形的网格显示与否。
ax.LineWidth = 1.5;%雷达图网的粗细。
ax.GridLineStyle = '-';%网格的显示方式。
ax.GridColor ='k';%网格的颜色。
% ax.RTick=linspace(0,max(X),5);%网格环线刻度
% ax.RTick=[0,0.2,0.3,0.4,0.9];%网格环线刻度
% TickLabel
ax.ThetaTickLabel = TickLabel;%改变坐标的字符
ax.ThetaTick = theta;% 显示的坐标点
ax.ThetaZeroLocation = 'top';% 0度所在位置

% R
ax.RAxisLocation = 0;% R轴的位置
% ax.RTickLabel = {'a','b','c','d','e'};%R轴的坐标
ax.RTickLabelRotation =0;% R轴坐标字符旋转
ax.RColor = 'k' ;% 改变R轴坐标字符的颜色
% legend({'AUC'},'Location',[0.8 0.7 0.15 0.15],'FontSize',10);
% set(hl,'Orientation','horizon');
% title('不同脑区及算法的分类性能比较','Color','k','FontSize',15,'FontWeight','bold');
% print('a.tif','-dtiff','-r300bpi')
end

