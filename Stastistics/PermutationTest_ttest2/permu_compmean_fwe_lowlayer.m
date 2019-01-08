function permu_compmean_fwe_lowlayer(Nperm,cov,idt_colrow)
% 用途：用置换检验的方式来检验两组统计量的差值是否有统计学意义，结果经过了FWE校正。
% 特别注意：此代码使用了GRETNA中的部分代码，来去协变量（请务必引用GRETNA）。
% 2018年02月08日 By Lichao lichao19870617@gmail.com
%%
msgbox(['注意:',char(10),'  1. 每一列应为一个统计量，每一行为一个被试!!!',...
    char(10),'  2. 请引用GRETNA']);
disp('Running=============================>>>')
tic
%% current path
currentFolder = pwd;
%%
if nargin<2
    Nperm=5000;
    cov='不加协变量';
    idt_colrow='每一行一个被试';
end
%% 加载指标Metrics
%load patients' data
[file_name_p,path_source_p,~] = uigetfile({'*.mat;*.txt','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','第一个变量文件');
Variable1=importdata([path_source_p,char(file_name_p)]);
% load  controls' data
[file_name_c,path_source_c,~] = uigetfile({'*.mat;*.txt;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','第二个变量文件');
Variable2=importdata([path_source_c,char(file_name_c)]);
%
if  strcmp(idt_colrow,'每一列一个被试')
    Variable1=Variable1';Variable2=Variable2';
end
%% 协变量
% 第一个协变量
if strcmp(cov,'加协变量')
    [file_name_cov,path_source_cov,~] = uigetfile({'*.txt;*.mat','All Image Files';...
        '*.*','All Files'},'MultiSelect','off','第一个统计量的协变量');
    CovariateVariable1=importdata([path_source_cov,char(file_name_cov)]);
    
    % 第二个协变量
    [file_name_cov,path_source_cov,~] = uigetfile({'*.txt;*.mat','All Image Files';...
        '*.*','All Files'},'MultiSelect','off','第二个统计量的协变量');
    CovariateVariable2=importdata([path_source_cov,char(file_name_cov)]);
else
    CovariateVariable1=[];
    CovariateVariable2=[];
end
%% 置换检验 均数减均数。使用GRETNA中的gretna_permutation_test

Para=[Variable1;Variable2];
Index_group1=1:size(Variable1,1);
Index_group2=1+size(Variable1,1):size(Variable1,1)+size(Variable2,1);
M=Nperm;
Cov=[CovariateVariable1;CovariateVariable2];
%
% NumOfSub=size(Para,1);
NumOfMetric=size(Para,2);
% Delta=cell(NumOfMetric,1);
pvalue=ones(NumOfMetric,1);
h1=waitbar(0,'请等待 Outer Loop>>>>>>>>');
for i=1:NumOfMetric
    waitbar(i/NumOfMetric,h1,sprintf('%2.0f%%', i/NumOfMetric*100)) ;
    if ~isempty(Cov)
        [~, pvalue(i)] = gretna_permutation_test...
            (Para(:,i), Index_group1, Index_group2, M, Cov);
    else
        [~, pvalue(i,1)] = gretna_permutation_test...
            (Para(:,i), Index_group1, Index_group2, M);
    end
end
close (h1)
sig=pvalue<0.05;
%% SAVE
% results path
time_lc=datestr(now,30);
path_outdir_tmp = uigetdir({},'结果存放目录');
mkdir([path_outdir_tmp filesep 'PermuFWE_',file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_',time_lc]);
path_outdir=[path_outdir_tmp filesep 'PermuFWE_',file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_',time_lc];
cd (path_outdir)
% save excel
% title
filename_ex = [file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_PermuFWE.xlsx'];
data_ex = {'pvalue','sig'};
sheet = 1;
xlRange = 'A1';
xlswrite(filename_ex,data_ex,sheet,xlRange)
% data
data_ex=[pvalue,sig];
sheet = 1;
xlRange = 'A2';
xlswrite(filename_ex,data_ex,sheet,xlRange)
%save .mat
save([ file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_PermuFWE.mat'],'pvalue','sig');
% Hint information
% msgbox(['结果存放在: ',path_outdir,'results_permutation',time_lc,'.*']);
% back to current path
cd(currentFolder)
% finished
disp('Completed!')
end