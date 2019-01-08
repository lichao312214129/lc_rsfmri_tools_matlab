% clc
% clear
% close all
%%
tic
program_path='E:\Lichao_research\天津医科大学培训2015-10\script_template';
addpath(program_path);
mc='fdr';%% multiple comparision 'bonf','fdr','uncorr'
sig=0.05;
steps=[0 1 1];% 1st=FC calculation,2nd=ttest1,3rd=ANOVA.
workdir='J:\lichao\insomnia\ICA_Insomnia_2017_12_06\Results';
data_dir='J:\lichao\insomnia\ICA_Insomnia_2017_12_06\Results\Result_ICA';
result_dir='J:\lichao\insomnia\ICA_Insomnia_2017_12_06\Results\inter-networks';mkdir(result_dir);cd(result_dir);
[cov,subjlist]=xlsread('J:\lichao\insomnia\ICA_Insomnia_2017_12_06\covANDscale\demographic_data_ICA68.xlsx');
[ICN_num,ICN_name]=xlsread('J:\lichao\insomnia\ICA_Insomnia_2017_12_06\covANDscale\demographic_data_ICA68.xlsx','ICN');
subj=subjlist(2:end,:);
prefix=('LC');


%% calculate both the static and dynamic Inter-ICN FC
% allocate space
% timecourse_IC_section=zeros(12,30,218,68);
ZFC_static=zeros(30,30,size(subj,1));
ZFC_dynamic=zeros(30,30,size(subj,1),218);
% timecourse_IC_dynamic=zeros(12,230,size(subj,1),218);
for s=1:size(subj,1)
    if s<10
        subnum=['sub00',num2str(s)];
    elseif s<100
        subnum=['sub0',num2str(s)];
    else
        subnum=['sub',num2str(s)];
    end
    
    ICN_TP=[prefix,'_',subnum,'_timecourses_ica_s1_'];
    IPpath=[data_dir,filesep,ICN_TP,'.nii'];
    vol=spm_vol(IPpath);
    timecourse_IC=spm_read_vols(vol);
    R_static=corrcoef( timecourse_IC);
    Z_static=0.5*log((1+R_static)./(1-R_static));%Fisher R-to-Z transformation
    ZFC_static(:,:,s)=Z_static(:,:);%Static zFC
    %% dynamic FC parameters
    window_star=1;window_step=1;window_length=30;volum=size(timecourse_IC,1);% dynamic FC parameters
    while (window_star+window_length)<=volum
        %         timecourse_IC_section(:,:,window_star,s)=timecourse_IC(window_star:(window_star+window_length-1),:);
        timecourse_IC_dynamic(:,:,s,window_star)=timecourse_IC(window_star:(window_star+window_length-1),:);
        R_dynamic=corrcoef(timecourse_IC_dynamic(:,:,s,window_star));
        Z_dynamic=0.5*log((1+R_dynamic)./(1-R_dynamic));%Fisher R-to-Z transformation
        ZFC_dynamic(:,:,s,window_star)=Z_dynamic(:,:);%Static zFC
        window_star=window_star+window_step;
    end
end

%%
FC_path=[result_dir,filesep,'zFC.mat'];
save(FC_path,'ZFC_static','ZFC_dynamic','timecourse_IC_dynamic','cov', 'subj','ICN_name','ICN_num');
fprintf('==================================\n');
fprintf('Finish FC calculate\n');
toc
