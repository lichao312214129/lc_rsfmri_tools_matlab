function ZFC_dynamic=DynamicFC(ts_seed,data_nii,window_step,window_length)
% 用途： 用于Voxel Wise的dynamicFC计算
%input
% ts_seed=种子点的时间序列
%data_nii=某个被试的所有体素的时间序列，size=[ndim1,ndim2,ndim3,nts],nts=时间序列的长度
%output：
%ZFC_dynamic=某个被试的动态连接，size=[ndim1,ndim2,ndim3,nw],nw=window的个数
%% =====================================
if nargin <3
  window_step=1; %默认每次滑动1个TR
  window_length=50;  %默认50个TR
end
%% =====================================
%计算dynamic FC窗口个数,为了预分配空间
window_star=1;window_end=window_length;
volum=size(data_nii,1);% dynamic FC parameters
count=0;
while window_end<=volum
    count=count+1;%计算多少个窗，即多少个动态矩阵,用来分配空间给ZFC_dynamic,从而加快速度
    window_star=window_star+window_step;%滑动
    window_end=window_end+window_step;%滑动
end
% allocate space
ndim1=size(ts_seed,2); ndim2=size(data_nii,2);
FC_dynamic=zeros(ndim1,ndim2,count);
%真正的动态连接计算，注意：初始化window_star和window_end
window_star=1;window_end=window_length;
while window_end<=volum
    data_nii_w=data_nii(window_star:window_end,:);
    ts_seed_w=ts_seed(window_star:window_end,:);
    R_dynamic=corr(ts_seed_w,data_nii_w);
    FC_dynamic(:,:,window_star)=R_dynamic;%Static zFC
    window_star=window_star+window_step;%滑动
    window_end=window_end+window_step;%滑动
end
ZFC_dynamic=0.5*log((1+FC_dynamic)./(1-FC_dynamic));%Fisher R-to-Z transformation
%2个种子点，70000列数据约11秒
end
