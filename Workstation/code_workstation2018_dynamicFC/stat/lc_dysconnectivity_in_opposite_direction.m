%% count the dysconnectivity in the opposite direction

%% input posthoc h and tvalue for state 1, 2 and 4
h1 = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\h_posthoc_fdr.mat';
h2 = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\h_posthoc_fdr.mat';
h4 = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\h_posthoc_fdr.mat';

t1 = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\tvalue_posthoc_fdr.mat';
t2 = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\tvalue_posthoc_fdr.mat';
t4 = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\tvalue_posthoc_fdr.mat';

%% state 1
% load h and t for SZ, MDD and MDD
h_s1 = importdata(h1);
t_s1 = importdata(t1);

h_sz_s1=squeeze(h_s1(1,:,:));
h_bd_s1=squeeze(h_s1(2,:,:));
h_mdd_s1=squeeze(h_s1(3,:,:));

t_sz_s1=squeeze(t_s1(1,:,:));
t_bd_s1=squeeze(t_s1(2,:,:));
t_mdd_s1=squeeze(t_s1(3,:,:));

%% state 2
% load h and t for SZ, MDD and MDD
h_s2 = importdata(h2);
t_s2 = importdata(t2);

h_sz_s2=squeeze(h_s2(1,:,:));
h_bd_s2=squeeze(h_s2(2,:,:));
h_mdd_s2=squeeze(h_s2(3,:,:));

t_sz_s2=squeeze(t_s2(1,:,:));
t_bd_s2=squeeze(t_s2(2,:,:));
t_mdd_s2=squeeze(t_s2(3,:,:));

%% state 4
% load h and t for SZ, MDD and MDD
h_s4 = importdata(h4);
t_s4 = importdata(t4);

h_sz_s4=squeeze(h_s4(1,:,:));
h_bd_s4=squeeze(h_s4(2,:,:));
h_mdd_s4=squeeze(h_s4(3,:,:));

t_sz_s4=squeeze(t_s4(1,:,:));
t_bd_s4=squeeze(t_s4(2,:,:));
t_mdd_s4=squeeze(t_s4(3,:,:));

%% count
% S1
% filter
t_sz_s1(h_sz_s1==0)=0;
t_bd_s1(h_bd_s1==0)=0;
t_mdd_s1(h_mdd_s1==0)=0;
% loc and quantity
szvsbd_s1 = sign(t_sz_s1.*t_bd_s1);
[szvsbd_i_s1, szvsbd_j_s1] = find(szvsbd_s1==-1);
c_szvsbd_s1 = sum(szvsbd_s1(:)==-1);

% S2
% filter
t_sz_s2(h_sz_s2==0)=0;
t_bd_s2(h_bd_s2==0)=0;
t_mdd_s2(h_mdd_s2==0)=0;
% loc and quantity
c_szvsbd_s2 = sign(t_sz_s2.*t_bd_s2);
[szvsbd_i_s2, szvsbd_j_s2] = find(c_szvsbd_s2==-1);
c_szvsbd_s2 = sum(c_szvsbd_s2(:)==-1);

% S4
% filter
t_sz_s4(h_sz_s4==0)=0;
t_bd_s4(h_bd_s4==0)=0;
t_mdd_s4(h_mdd_s4==0)=0;
% loc and quantity
c_szvsbd_s4 = sign(t_sz_s4.*t_bd_s4);
[szvsbd_i_s4, szvsbd_j_s4] = find(c_szvsbd_s4==-1);
c_szvsbd_s4 = sum(c_szvsbd_s4(:)==-1);

imagesc(szvsbd_s1)

net_path=szvsbd_s1;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);