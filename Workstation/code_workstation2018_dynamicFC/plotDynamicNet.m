% aa=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\DynamicFC17_1_screened\Dynamic\BD\ROISignals_00053_resting.mat');
% net1=aa(:,:,1);
% figure
% imagesc(net1);colormap(jet)
% %
% a=allMatrix(1,:);
% % a1=squareform(a);
% a1=zeros(114,114);
% a1(upMatMask)=a;
% figure
% imagesc(a1);colormap(jet)
mask=importdata('D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\results\h_fdr_ancova.mat');
net=importdata('D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\results\F_ancova.mat');
net=net.*mask;
[index,sortedNetIndex,reorgNet]=lc_ReorganizeNetForYeo17NetAtlas(net);
sepIndex=importdata('D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\sepIndex.mat');
lc_InsertSepLineToNet(reorgNet)
colormap(jet)
axis square
%
% ithWindow=20;
% count=1;
% for ithWindow=1:5:100
% net=zDynamicFC(:,:,ithWindow);
% subplot(5,4,count);
% net=lc_ReorganizeNetForYeo17NetAtlas(net);
% sepIndex=importdata('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\sepIndex.mat');
% lc_InsertSepLineToNet(net,sepIndex)
% axis square
% count=count+1;
% end