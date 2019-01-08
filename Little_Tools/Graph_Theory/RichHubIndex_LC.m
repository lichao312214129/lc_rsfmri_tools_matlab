function RichHubIndex_LC
%用法:1. 把这个代码的放在MATLAB的工作路径下： cd ('path')
%2. 输入 RichHubIndex_LC或者右键RichHubIndex_LC，然后点击run
% ===================================================================
disp('Running=============================')
% load('X1.mat');%location of rich hub node
% load rich hub location
[file_name_richhub,path_source_richhub,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','Rich hub的位置');
% load  networks
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','每个被试的网络（相关矩阵）');
% rich hub location vector
loc_rich=load([path_source_richhub,char(file_name_richhub)]);
loc_rich= loc_rich.X;
%number of subjects
if iscell(file_name)
    n_sub=length(file_name);
else
    n_sub=1;
end
%
loc_local=setdiff(1:90,loc_rich);% only for 90 nodes

for i=1:n_sub
    if iscell(file_name)
        struct_matrix_temp=load([path_source,char(file_name(i))]);
    else
        struct_matrix_temp=load([path_source,char(file_name)]);
    end
    matrix_data_temp=struct_matrix_temp.Data_wei_ROI;
    matrix_rich_temp=triu(matrix_data_temp(loc_rich,loc_rich));
    matrix_local_temp=triu(matrix_data_temp(loc_local,loc_local));
    %binary
    num_rich_bi(i)=sum(sum(matrix_rich_temp~=0));
    num_local_bi(i)=sum(sum(matrix_local_temp~=0));
    num_feeder_bi(i)=sum(sum(triu(matrix_data_temp)~=0))-num_rich_bi(i)-num_local_bi(i);
    ratio_richVSfreeder_bi(i)=num_rich_bi(i)/num_feeder_bi(i);
    ratio_richVSlocal_bi(i)=num_rich_bi(i)/num_local_bi(i);
    %weighted
    num_rich_w(i)=sum(sum(matrix_rich_temp));
    num_local_w(i)=sum(sum(matrix_local_temp));
    num_feeder_w(i)=sum(sum(triu(matrix_data_temp)))-num_rich_w(i)-num_local_w(i);
    ratio_richVSfreeder_w(i)=num_rich_w(i)/num_feeder_w(i);
    ratio_richVSlocal_w(i)=num_rich_w(i)/num_local_w(i);
    %average
    num_rich_av(i)=mean(matrix_rich_temp(:));
    num_local_av(i)=mean(matrix_local_temp(:));
    num_feeder_av(i)=(sum(sum(triu(matrix_data_temp)))-sum(matrix_rich_temp(:))-sum(matrix_local_temp(:)))/...
                      (combntns(90,2)-combntns(numel(loc_rich),2)-combntns(numel(loc_local),2));%分母
    ratio_richVSfreeder_av(i)=num_rich_av(i)/num_feeder_av(i);
    ratio_richVSlocal_av(i)=num_rich_av(i)/num_local_av(i);
end
%% write to excel and save results
time_lc=datestr(now,30);
filename_ex = [path_source_richhub,'results_RichHub',time_lc,'.xlsx'];
data_ex = {'subject name','num_rich_bi','num_local_bi','num_feeder_bi','ratio_richVSfreeder_bi','ratio_richVSlocal_bi',...
    'num_rich_w','num_local_w','num_feeder_w','ratio_richVSfreeder_w','ratio_richVSlocal_w',...
     'num_rich_av','num_local_av','num_feeder_av','ratio_richVSfreeder_av','ratio_richVSlocal_av'};
sheet = 1;
xlRange = 'A1';
xlswrite(filename_ex,data_ex,sheet,xlRange)
%
if iscell(file_name)
    data_ex=char(file_name');
    data_ex=data_ex(:,1:end-5);
    data_ex=cellstr(data_ex);
else
    data_ex=file_name;
    data_ex=data_ex(1:end-5);
    data_ex=cellstr(data_ex);
end
sheet = 1;
xlRange = 'A2';
xlswrite(filename_ex,data_ex,sheet,xlRange)
%
data_ex = [num_rich_bi',num_local_bi',num_feeder_bi',ratio_richVSfreeder_bi',ratio_richVSlocal_bi',...
    num_rich_w',num_local_w',num_feeder_w',ratio_richVSfreeder_w',ratio_richVSlocal_w',...
    num_rich_av',num_local_av',num_feeder_av',ratio_richVSfreeder_av',ratio_richVSlocal_av'];
sheet = 1;
xlRange = 'B2';
xlswrite(filename_ex,data_ex,sheet,xlRange)
%save results
save([path_source_richhub filesep 'results_RichHub',time_lc,'.mat'],...
    'num_rich_bi','num_local_bi','num_feeder_bi','ratio_richVSfreeder_bi','ratio_richVSlocal_bi',....
    'num_rich_w','num_local_w','num_feeder_w','ratio_richVSfreeder_w','ratio_richVSlocal_w',...
    'num_rich_av','num_local_av','num_feeder_av','ratio_richVSfreeder_av','ratio_richVSlocal_av');
%
disp('Completed!')
end