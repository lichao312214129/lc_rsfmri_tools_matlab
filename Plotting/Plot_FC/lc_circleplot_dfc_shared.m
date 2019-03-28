%% 画脑网络的连接(shared)
% 注意要考虑差异的方向。
% 比如SZ的某个连接小于正常人，而BD的此连接大于正常人，这就属于方向不一致。
% 本代码已经考虑到这种情况。
% 出现这种情况后，要单独讨论。本研究中这种情况很少见。
%% input
if_binary=0; %二值化处理，正值为1，负值为-1
net_index_path='F:\黎超\dynamicFC\Data\Network_and_plot_para\netIndex.mat';
node_name_path='F:\黎超\dynamicFC\Code\17network_label.xlsx';
if_save=0;
save_name='';
how_disp='all';% or 'only_neg'

% 开始作图
figure
set(gcf,'Position',get(0,'ScreenSize'))
% set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(3,4,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

% 状态1
axes(ha(1)); 
net_path='F:\黎超\dynamicFC\Data\Dynamic\state1\result1\shared_1and2and3_fdr.mat';
mask_path='F:\黎超\dynamicFC\Data\Dynamic\state1\result1\shared_1and2and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
% net_sign=sign(net);
net_sign=net;
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(2)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\shared_1and2_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(3)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\shared_1and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(4)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\shared_2and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)


% 状态2
axes(ha(5)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_1and2and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(6)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_1and2_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(7)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_1and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(8)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_2and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)


% 状态4
axes(ha(9)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_1and2and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(10)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_1and2_fdr.mat';


% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;

which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(11)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_1and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;


which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(12)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_2and3_fdr.mat';

% 只选择异常方向一致的连接(mask与mask_sign的交集)
net=importdata(net_path);
mask=importdata(mask_path);
net_sign=sign(net);
net_sum=abs(squeeze(sum(net_sign,1)));
net_sign_comp=ones(size(net_sum))*size(net_sign,1);
mask_net=net_sum==net_sign_comp;
mask_path=mask.*mask_net~=0;


which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

%
set(gcf,'color','k');
set(ha(1:4),'XTickLabel',''); 
set(ha,'YTickLabel','')

% save
if if_save
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\figure\shared_all3.tiff')
end