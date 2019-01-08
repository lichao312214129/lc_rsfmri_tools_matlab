%% 此代码用来给pMap做多重比较校正
% load
t=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\Static\SZvsHC_TNet.txt');
p=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\Static\SZvsHC_PNet.txt');
% correction
[Results] = multcomp_holm_bonferroni(p,'alpha',0.01);
h=Results.corrected_h;
h=reshape(h,[114,114]);
sum(h(:))
% plot
t(h~=1)=0;
hc=lc_ReorganizeNetForYeo17NetAtlas(t);
imagesc(hc)
lc_InsertSepLineToNet(hc);
colorbar
axis square
% save figure
% print(gcf,'-dtiff','-r300','BDvsHC')
%% mean
% load
% hc=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\Static\averaged_hc_Avg.txt');
% sz=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\Static\averaged_sz_Avg.txt');
% bd=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\Static\averaged_bd_Avg.txt');
% mdd=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\Static\averaged_mdd_Avg.txt');
% % plot
% figure
% subplot(2,2,1)
% hc=lc_ReorganizeNetForYeo17NetAtlas(hc);
% lc_InsertSepLineToNet(hc);
% colorbar
% axis square
% 
% subplot(2,2,2)
% sz=lc_ReorganizeNetForYeo17NetAtlas(sz);
% lc_InsertSepLineToNet(sz);
% colorbar
% axis square
% 
% subplot(2,2,3)
% bd=lc_ReorganizeNetForYeo17NetAtlas(bd);
% lc_InsertSepLineToNet(bd);
% colorbar
% axis square
% 
% subplot(2,2,4)
% mdd=lc_ReorganizeNetForYeo17NetAtlas(mdd);
% lc_InsertSepLineToNet(mdd);
% colorbar
% axis square