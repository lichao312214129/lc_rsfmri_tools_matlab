function bar_graduation
AUC=[0.9700    0.9200    0.6500    0.6400    0.6200    0.6100    0.5500];
Specificity=[0.90   0.92   0.53  0.43   0.60   0.53   0.45];
Sensitivity=[ 0.9000    0.8400    0.7200    0.7400    0.6200    0.5600    0.6000];
Accuracy=[0.9000    0.8780    0.6300    0.6000    0.6110    0.5440    0.5330];
%%
x=1:4;%changed item，变量数量。
Mean=[AUC;Specificity;Sensitivity;Accuracy];
h = bar(x,Mean,0.6);%画bar
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';
x_kedu=f(get(h,{'xoffset','xdata'}));%获取每一个柱状图中线的x坐标。
%%
%设置以及加入文字等
ax = gca;
ax.XTickLabels = {'AUC','Specificity','Sensitivity','Accuracy'};
set(ax,'XColor','k');%x坐标的颜色
set(ax,'Fontsize',15);%设置ax标尺大小
ax.XTickLabelRotation = 0;
% ax.YLim=[-0.8 2];%设置y轴范围
% title('The classifier performance using different seed region or ALFF algorithm',...
%                      'Fontsize',20,'FontWeight','bold');
xlabel('','Fontsize',15,'FontWeight','bold','color','k');
ylabel('Performances','Fontsize',15,'FontWeight','bold');
h1=legend('ventral-RAIns-x2y','ventral-RAIns-y2x','dorsal-RAIns-x2y',...
         'dorsal-RAIns-y2x','ventral-LAIns-x2y','ventral-LAIns-y2x','ALFF');%根据需要修改
h1.Location='northeast';
line([0,5],[0.5,0.5],'linewidth',3,'color',[0.5,0.5,0.5]);
line([0,5],[0.8,0.8],'linewidth',3,'color',[0.8,0.2,0.2]);
% line([0,5],[0.9,0.9],'linewidth',3,'color',[0.8,0.2,0.2]);
%%
% %画饼图，但是本饼图不适宜，因为大于百分之百，可能用
% mc=mean(data_c(:,3));
% mpf=mean(data_p_f(:,3));
% mps=mean(data_p_s(:,3));
% perc1=(mpf-mc)/mc;%治疗前，病人中央后回神经活动的绝对值较对照组增加的百分比
% perc2=(mps-mc)/mc;%治疗后，病人中央后回神经活动的绝对值较对照组增加的百分比
% ax1 = subplot(1,2,1);
% i=perc1*100;i=round(i);%保留2位小数
% label1 = {'',['治疗前(',num2str(i),'%)']};
% p1=pie(ax1,[1-perc1,perc1],label1);
% t = p1(2);
% t.FontSize = 30;%设置label大小
% % colormap([0,0,1]);%颜色
% ax2 = subplot(1,2,2);
% i=perc2*100;i=round(i);%保留2位小数
% label2 = {'',['治疗后(',num2str(i),'%)']};
% p2=pie(ax2,[1-perc2,perc2],label2);
% t = p2(2);
% t.FontSize = 30;%设置label大小
% % colormap([0,0,1])%颜色
% fig=suptitle('治疗前后正常与异常自发脑活动的比值变化');
% set(fig,'Fontsize',40,'FontWeight','bold');

end

