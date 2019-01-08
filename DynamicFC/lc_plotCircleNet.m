% 把有差异的连接画出来,并保存

% 统计
[tValue, p, p_fdr, h_fdr]=StatisticalAnalysis_InterROI_LC(1:114,0.05);

% 按网络排序
[index,sortedNetIndex,sorted_h_fdr]=lc_ReorganizeNetForYeo17NetAtlas(h_fdr);

% 图
figure;
% sorted_h_fdr=double(rand(114)>0.99);
myColorMap=zeros(114,3);
% lines，hsv
% color=jet(7);
load('I:\dynamicFC\netColor\color.mat');
for i=1:114
     myColorMap(i,:)=color(sortedNetIndex(i),:);
end

myLabel = cell(length(sorted_h_fdr));
[~,label,~]=xlsread('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\17network_label.xlsx');
label=label(:,2);
[label_noFileSep,alpha]=cellfun(@(x) fileparts(x), label,'UniformOutput',false);
for i=1:length(label)
    if label_noFileSep{i}
        label{i}=[label_noFileSep{i},alpha{i}(end)];
    end
end
for i = 1:length(sorted_h_fdr)
  myLabel{i} =label{index(i)};
end

circularGraph(sorted_h_fdr,'Colormap',myColorMap,'Label',myLabel);

% save picture
% print('-dtiff','-r300','state4_17_MDDvsHC')  
