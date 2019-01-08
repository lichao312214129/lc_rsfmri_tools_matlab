function pie3_LC
%UNTITLED2 此处显示有关此函数的摘要
%% 设置饼图颜色。
figure('color',[0.2 0.6 0.4]);%背景颜色
cm = [0 0.8 0.6; 0.5 0.5 0.5];%饼图分区的颜色
colormap(cm)
%% 画饼图
label={'Sleep',''};
h=pie3([0.1,0.9],[1,0]);
%% 设置text的大小
t = h(4);
t.FontSize = 60;%设置label大小
t.Color='white';%text的颜色
set(gcf, 'InvertHardCopy', 'off');%设置后背景才能一同被保存出来。
end

