% 用途： 将以subject为单位的.mat数据合并为一个文件，从而可以进行后续的统计分析
[name,path,~] = uigetfile({'*.mat;*.txt;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select files');
data_temp=importdata([path,name{1}]);
data=zeros(length(name),2);
for i=1:length(name)
    d=importdata([path,name{i}]);
    data(i,:)=[d(1,2),d(1,3)];
end
