function  bar_errorbar3( Matrix )
%此函数用来绘制带有误差的柱状图，同时标记双样本t检验的p值,目前的代只适用与两组被试。
%input:
% Matrix 为一个cell，里面包含每个组的数据信息
% 假设Matrix{1}为病人的变量矩阵，比如有病人组被试数=N，且有2个变量（age，education）
% 那么该变量矩阵应该是一个N行2列的矩阵；以下是一个矩阵的表格形式；
%            age     education
% subject1    15         9
% subject2    20         12
% .           .           .
% .           .           .
% .           .           .
% subjectN    16         15
%那么输入的矩阵形式为[15 20 . . . 16;9  12 . . . 15]
%类似的输入对照组的变量矩阵
%% =================================================================
showXTickLabels=1;
showYLabel=0;
showLegend=0;
%% =================================================================
% Matrix={Matrix1, Matrix2,Matrix3,Matrix4};
Mean=cell2mat(cellfun(@(x) mean(x,1),Matrix,'UniformOutput',false)')';
Std=cell2mat(cellfun(@(x) std(x),Matrix,'UniformOutput',false)')';

h = bar(Mean,0.6,'grouped','EdgeColor','k','LineWidth',1.5);
% h(1).FaceColor=[0.2,0.2,0.2];h(2).FaceColor='w';
% h(1).Visible='off';h(2).Visible='off';
% set(gca,'YTick',-0.01:0.00001:0.02);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
coordinate_x=f(get(h,{'xoffset','xdata'}));
hold on
% errorbar(coordinate_x,cell2mat(get(h,'ydata')).',...
%            Std,'s','MarkerSize',0.0001,'linewidth',1.5,'Color','k');%Std是误差矩阵,除以2是为了只显示一半
%画误差线
for i=1:numel(Mean)
    if Mean(i)>=0
        line([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)+Std(i)],'linewidth',2);
    else
        line([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)-Std(i)],'linewidth',2);
%         errorbar([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)-Std(i)],'linewidth',2);
    end
end
ax = gca;
set(ax,'LineWidth',2.5);
box off

ax.XTick =  1:size(Matrix{1},1);

% x轴的label
if showXTickLabels
    ax.XTickLabels = ...
        {'左侧额中回/额上回 ','右侧额上回（靠内)','右侧前扣带回 ','右侧尾状核','左侧尾状核',...
        '右侧putamen','左侧putamen','右侧岛叶/frontal Operculum Corter','左侧岛叶/frontal Operculum Corter',...
        '右侧杏仁核 ','左侧杏仁核 ','右侧海马','左侧海马','右侧海马旁回','左侧海马旁回',...
        ' 右侧舌回',' 左侧舌回','右侧cuneus','左侧cuneus','右侧angular gyrus','右侧中央后回'};
    
    set(ax,'Fontsize',10);%设置ax标尺大小
    % set(ax,'ytick',-0.1:0.05:0.1);
    ax.XTickLabelRotation = 45;
    % Yrang_max=max(max(Mean + Std));
    % ax.YLim=[-0.1 0.1];%设置y轴范围
    %设置x轴范围
    % xlabel('variables','FontName','Times New Roman','FontSize',20);
end

% y轴的labe
if showYLabel
    ylabel('dALFF','FontName','Times New Roman','FontWeight','bold','FontSize',20);
end

% legend
if showLegend
    h=legend('HC','SZ','BD','MDD','Orientation','horizontal');%根据需要修改
    set(h,'Fontsize',15);  % 设置legend字体大小
    set(h,'Box','off');
    % h.Location='best';
    box off
    % grid on
    % grid minor
end
end

