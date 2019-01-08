function DynamicFC_VoxelWise_LC(window_step,window_length,opt)
%% =========================函数说明==============================
% 计算Voxel wise的动态功能连接的标准差（standard deviation,std），注意：种子点的平均时间序列与种子点本身也做了相关！
% input：
% 一组被试的时间序列.nii/.img文件，4D文件，size=ndim1*ndim2*ndim3*nts
% 前三个为脑的维度，如61*73*61；nts为时间序列长度。
% output
% ZFC_dynamic 文件夹下为每个被试的动态功能连接（Fisher R to Z
% 变换过），size为：N_seed*T*N_voxel，
% N_seed=种子点个数；T=时间点个数，N_voxel=体素的个数。
%% =========================参数=================================
if nargin<3
    opt.mask=1;%是否加mask
    opt.static=0;%是否计算静态FC
    opt.dynamicFC=0;%是否保存所有滑动窗的功能连接,如果选择，则更耗时
end
if nargin<2
    window_step=1;window_length=50;
end
%% =========================结果目录==============================
path_result= uigetdir({},'select result folder');
mkdir(path_result,'ZFC_dynamic_voxelwise');%在结果路径，新建文件夹，用来存放结果
path_result=fullfile(path_result,filesep,'ZFC_dynamic_voxelwise');%结果存放的文件夹
mkdir(path_result,'ZFC_static');%在结果路径，新建文件夹，用来存放不同的结果
mkdir(path_result,'ZFC_dynamic');%在结果路径，新建文件夹，用来存放不同的结果
mkdir(path_result,'Std_ZFC_dynamic');%在结果路径，新建文件夹，用来存放不同的结果
path_result_static=fullfile(path_result,'ZFC_static');
path_result_dynamic=fullfile(path_result,'ZFC_dynamic');
path_result_Std_dynamic=fullfile(path_result,'Std_ZFC_dynamic');
%% =========================数据目录==============================
[path_source] = uigetdir({},'select data folder');
%% =========================load seed============================
% ts_seed=rand(230,1);
[seed_name,seed_source,~] = uigetfile({'*.img;*.nii;*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select seed');
if iscell(seed_name)
    N_seed=length(seed_name);
    for no_seed=1:N_seed
        seed_strut=load_nii([seed_source,char(seed_name(no_seed))]);
        %     if no_mask==1;mask_temp=mask_strut.img;end;mask_size=size(mask_temp);%评估mask的size
        seed(:,:,:,no_seed)=seed_strut.img;
    end
else
    N_seed=1;
    seed_strut=load_nii([seed_source,char(seed_name)]);
    seed=seed_strut.img;
end
seed=seed~=0;%如果是概率种子点，那么则可以做相应修改
seed_1d=reshape(seed,size(seed,1)*size(seed,2)*size(seed,3),N_seed)';
%% =======================load mask==============================
%但不上载mask，则在得到模板后，生成一个全mask
if opt.mask
    [mask_name,mask_source,~] = uigetfile({'*.img;*.nii;*.mat;','All Image Files';...
        '*.*','All Files'},'MultiSelect','off','select mask');
    mask_strut=load_nii([mask_source,char(mask_name)]);
    mask=mask_strut.img;
    mask=mask~=0;% 转为逻辑矩阵
    mask_1d=reshape(mask,1,size(mask,1)*size(mask,2)*size(mask,3));
end
%% =========================保存设置=============================
fid = fopen([path_result,filesep,'Parameters and settings.txt'],'a');
% add ===
fprintf(fid,'=========================================================\r\n');
% add time
fprintf(fid,[datestr(now,31) ,'\r\n']);
fprintf(fid,'window_step=%d\r\nwindow_length=%d\r\n',window_step,window_length);
fprintf(fid,'------------------\r\n');
% mask
if opt.mask
    fprintf(fid,'mask=%s\r\n',[mask_source char(mask_name)]);
else
    fprintf(fid,'not apply mask\r\n');
end
fprintf(fid,'------------------\r\n');
% seed
for ii=1:length(seed_name)
    fprintf(fid,['Seed',num2str(ii), ' is/are: %s\r\n'],char(seed_name(ii)));
end
fclose(fid);
%% =========================load nifti===========================
file_name=dir(path_source);
file_name={file_name.name};
file_name=file_name(3:end)';
%判断Fun*下面有几个文件，分别处理
if iscell(file_name)
    n_sub=length(file_name);
    name_nii=dir([path_source,filesep,char(file_name(1))]);
    name_nii={name_nii.name};
    name_nii=name_nii(3:end);
    temp_nii=load_nii([path_source,filesep,char(file_name(1)),filesep,char(name_nii)]);
else
    n_sub=1;
    name_nii=dir([path_source,filesep,char(file_name)]);
    name_nii={name_nii.name};
    name_nii=name_nii(3:end);
    temp_nii=load_nii([path_source,filesep,char(file_name),filesep,char(name_nii)]);
end
[ndim1,ndim2,ndim3,nts]=size(temp_nii.img);%size
%默认mask
if ~opt.mask
    mask_1d=ones(1,ndim1*ndim2*ndim3);
end
%% =分批次load nii、提取seed的平均时间序列、与ROI的时间序列做相关并保存=
for i=1:n_sub
    if i<=5;tic;end;%计算前五个被试的处理时间
    fprintf(['The ',num2str(i),'th subject\n']);
    if iscell(file_name)
        % load nii
        strut_nii=load_nii([path_source,filesep,char(file_name(i)),filesep,char(name_nii)]);
        data_nii=strut_nii.img;
        % reshape data_nii
        data_nii=reshape(data_nii,ndim1*ndim2*ndim3,nts)';
        % extract seed region's mean timeseriers
        for no_ts_seed=1:N_seed
            ts_seed=data_nii(:,seed_1d(no_ts_seed,:));
            ts_seed_m(:,no_ts_seed)=mean(ts_seed,2);%平均时间序列
        end
        % apply mask, include seed
        data_nii=data_nii(:,mask_1d);
        % dynamic FC and static FC
        R_static=corr(ts_seed_m,data_nii);
        ZFC_static=0.5*log((1+R_static)./(1-R_static));%Fisher R-to-Z transformation
        ZFC_dynamic=DynamicFC(ts_seed_m,data_nii,window_step,window_length);%1个被试（70000个体素），2个mask约11秒
        Std_ZFC_dynamic=std(ZFC_dynamic,0,3);%从时间窗的维度求标准差
    else
        strut_nii=load_nii([path_source,filesep,char(file_name),filesep,char(name_nii)]);
        data_nii=strut_nii.img;
        data_nii=reshape(data_nii,ndim1*ndim2*ndim3,nts)';
        % extract seed region's mean timeseriers
        for no_ts_seed=1:N_seed
            ts_seed=data_nii(:,seed_1d(no_ts_seed,:));
            ts_seed_m(:,no_ts_seed)=mean(ts_seed,2);%平均时间序列
        end
        % apply mask, include seed
        data_nii=data_nii(:,mask_1d);
        % dynamic FC
        ZFC_dynamic=DynamicFC(ts_seed_m,data_nii,window_step,window_length);%1个被试（70000个体素），2个mask约11秒
        Std_ZFC_dynamic=std(ZFC_dynamic,0,3);%从时间窗的维度求标准差
    end
    fprintf(['The ',num2str(i),'th subject completed! and saving... \n']);
    %% save
    % 生成文件夹
    if opt.dynamicFC; result_cmd_ZFC_dynamic=[ path_result_dynamic,filesep,file_name{i},'_ZFC_dynamic_voxelwise','.mat'];end
    result_cmd_Std_ZFC_dynamic=[ path_result_Std_dynamic,filesep,file_name{i},'_Std_ZFC_dynamic_voxelwise','.mat'];
    if opt.static; result_cmd_ZFC_static=[ path_result_static,filesep,filesep,file_name{i},'_ZFC_static_voxelwise','.mat']; end
    % 转化为3d矩阵
    empt_std=zeros(N_seed,numel(mask_1d));
    if opt.dynamicFC; empt_dynamic=zeros(N_seed,numel(mask_1d),size(ZFC_dynamic,3)); end
    if opt.static; empt_static=zeros(N_seed,numel(mask_1d));end
    empt_std(:,mask_1d)=Std_ZFC_dynamic;
    if opt.dynamicFC; empt_dynamic(:,mask_1d,:)=ZFC_dynamic;end
    if opt.static; empt_static(:,mask_1d)=ZFC_static;end
    Std_ZFC_dynamic_3d=reshape(empt_std',ndim1,ndim2,ndim3,N_seed);%注意此处的empt需要转置，因为MATLAB的默认顺序是按第一个维度。
    if opt.dynamicFC;ZFC_dynamic_3d = permute(empt_dynamic,[2 1 3]);end%3维矩阵前2维转置
    if opt.dynamicFC;ZFC_dynamic_3d=reshape(empt_dynamic,ndim1,ndim2,ndim3,N_seed,size(empt_dynamic,3));end
    if opt.static; ZFC_static_3d=reshape(empt_static',ndim1,ndim2,ndim3,N_seed);end
    % save
    if opt.dynamicFC; save(result_cmd_ZFC_dynamic,'ZFC_dynamic_3d');end
    save( result_cmd_Std_ZFC_dynamic,'Std_ZFC_dynamic_3d');
    if opt.static; save(result_cmd_ZFC_static,'ZFC_static_3d'); end
    if i<=5;fprintf([ '第',num2str(i),'个被试的处理时间为： ',num2str(toc),' 秒\n']);end;%计算前五个被试的处理时间
end
fprintf(['All completed!\n']);
end