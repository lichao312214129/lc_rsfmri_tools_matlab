function  [h_posthoc_fdr,pvalue_posthoc,tvalue_posthoc]=lc_posthoc_ttest2_for_FCmatrix_mypaper(mask,fdr_threshold)
% 对ROI wise的static/dynamic FC 进行统计分析(post-hoc ttest2+组间水平的FDR校正)
% 注意：我们只将病人组与正常对照组进行两两比较，病人组之间没有比较。
% input：
%   ZFC_*：ROI wise的静态和动态功能连接矩阵,size=N*N,N为ROI个数
%   Mask：感兴趣功能连接网络二值矩阵（2D,维度与个体网络矩阵维度一致）,缺省则对所有的连接进行统计
%   fdr_threshold： FDR校正的q值
% output：
%   H_FDR:经过FDR校正后的静态或者动态功能连接统计分析的显著情况
%   P：静态或者动态功能连接统计分析的p值
%   T: ...T值

%% all input
if nargin<1
    % input
    path = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic';
    state=4;
    
    % fc
    path_sz=fullfile(path,['state',num2str(state),'\state',num2str(state),'_SZ']);
    path_bd=fullfile(path,['state',num2str(state),'\state',num2str(state),'_BD']);
    path_mdd=fullfile(path,['state',num2str(state),'\state',num2str(state),'_MDD']);
    path_hc=fullfile(path,['state',num2str(state),'\state',num2str(state),'_HC']);
    
    suffix='*.mat';
    n_row=114;%矩阵有几行
    n_col=114;%矩阵有几列
    
    % correction
    fdr_threshold=0.05;
    correction_method='fdr';
    
    % mask
    add_mask=1;
    mask=importdata(fullfile(path,['state',num2str(state),'\result','\h_ancova_',correction_method,'.mat']));
    mask=mask==1;
    
    % save
    if_save=1;
    save_path=fullfile(path,['state',num2str(state),'\result1']);
end

%% load fc and cov
% load fc
fprintf('Loading FC...\n');
fc_sz=load_FCmatrix(path_sz,suffix,n_row,n_col);
fc_bd=load_FCmatrix(path_bd,suffix,n_row,n_col);
fc_mdd=load_FCmatrix(path_mdd,suffix,n_row,n_col);
fc_hc=load_FCmatrix(path_hc,suffix,n_row,n_col);
fprintf('Loaded FC\n');

% 加载协变量
% post-hoc 不需要加协变量

%% 准备数据
% 提取Mask内的连接,提取之后，被试矩阵将会是1D的形式
if add_mask
    fc_sz=fc_sz(:,mask);
    fc_bd=fc_bd(:,mask);
    fc_mdd=fc_mdd(:,mask);
    fc_hc=fc_hc(:,mask);
end

% Inf/NaN to 1 and 0
fc_sz(isinf(fc_sz))=1;
fc_bd(isinf(fc_bd))=1;
fc_mdd(isinf(fc_mdd))=1;
fc_hc(isinf(fc_hc))=1;

fc_sz(isnan(fc_sz))=0;
fc_bd(isnan(fc_bd))=0;
fc_mdd(isnan(fc_mdd))=0;
fc_hc(isnan(fc_hc))=0;

%% post-hoc ttest2
disp('performing post-hoc ttest2 for all dependent variables...')
DependentFiles={fc_sz,fc_bd,fc_mdd,fc_hc};
contrast=[1 1 1 0];%正常组在最后
[h_posthoc_without_fdr,pvalue_posthoc,tvalue_posthoc]=lc_ttest2(DependentFiles,contrast);

%% 组间水平的fdr correction：
%% 此时的FDR校正的对象应该是所有组的某个特征，而不是某个组的所有特征
[h_posthoc_fdr]= post_hoc_fdr(pvalue_posthoc,fdr_threshold,correction_method);

%% let h_fdr and p_fdr back to 2D matrix
% note. 统一都取上三角（不包括对角线）
h_posthoc_fdr=mat1D_to_mat3D(h_posthoc_fdr,mask);
pvalue_posthoc=mat1D_to_mat3D(pvalue_posthoc,mask);
tvalue_posthoc=mat1D_to_mat3D(tvalue_posthoc,mask);

% save
if if_save
    disp('save results...');
    save (fullfile(save_path,['h_posthoc_',correction_method,'.mat']),'h_posthoc_fdr');
    save (fullfile(save_path,['tvalue_posthoc_',correction_method,'.mat']),'tvalue_posthoc');
    save (fullfile(save_path,['pvalue_posthoc_',correction_method,'.mat']),'pvalue_posthoc');
    disp('saved results');
end

fprintf('==================================\n');
fprintf('Completed\n');
end

function all_subj_fc=load_FCmatrix(path,suffix,n_row,n_col)
% 加载path中所有被试的FC
subj=dir(fullfile(path,suffix));
subj={subj.name}';
subj_path=fullfile(path,subj);

n_subj=length(subj);
all_subj_fc=zeros(n_subj,n_row,n_col);
for i =1:n_subj
    all_subj_fc(i,:,:)=importdata(subj_path{i});
end
end

function [H,P,T]=lc_ttest2(DependentFiles,contrast)
% 仅仅将病人组与正常对照两两对比
% 假设总共有4组，正常人组在第四组，则：
% contrast=[1 1 1 0]
n_g=sum(contrast);
patients_groups_ind=find(contrast==1);

% 预分配
fc=(DependentFiles{1});
n_features=size(fc,2);
H=zeros(n_g,n_features);
P=ones(n_g,n_features);
T=zeros(n_g,n_features);
disp('ttest2...')
for i=1:n_g
    ind=patients_groups_ind(i);
    [h,p,~,s] = ttest2(DependentFiles{ind}, DependentFiles{contrast==0});
    t=s.tstat;
    H(i,:)=h;
    P(i,:)=p;
    T(i,:)=t;
end
disp('ttest2 done')
end

function [h_fdr]= post_hoc_fdr(P,fdr_threshold,correction_method)
% P的维度=n_group*n_features
% 对象：所有组的某个特征，迭代直到所有特征校正结束
[n_g,n_f]=size(P);
h_fdr=zeros(n_g,n_f);
for i=1:n_f
    if strcmp(correction_method,'fdr')
        results=multcomp_fdr_bh(P(:,i),'alpha', fdr_threshold);
    else
        results=multcomp_bonferroni(P(:,i),'alpha', fdr_threshold);
    end
    h_fdr(:,i)=results.corrected_h;
end
end

function mat2D=mat1D_to_mat3D(mat1D,mask)
% 将1D矩阵根据提取mask返回到2D原始矩阵
% mat1D 的维度可以是n_group*n_features
[n_g,n_f]=size(mat1D);
mat2D=zeros(n_g,size(mask,1),size(mask,2));
for i=1:n_g
    mat2D(i,mask)=mat1D(i,:);
end
end