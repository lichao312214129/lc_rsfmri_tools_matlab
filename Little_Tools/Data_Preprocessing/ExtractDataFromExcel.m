% 用途：将excel中的数据顺序与ID对应
% input：
    % excel表格中的数据（临床资料、量表等）
    % ID=被试的ID号码，可以是任何一个可以和被试唯一匹配的特殊编号
% output：
    % Locmember_*=每个被试在excel中的位置
%% ===========================Read Excel==========================
[DataExcel_GAD,DataExcel_GAD_Str,DataExcel_GAD_Raw]=xlsread('GAD数据采集表修正 .xls',4);
[DataExcel_HC,DataExcel_HC_Str,DataExcel_HC_Raw]=xlsread('GAD数据采集表修正 .xls',5);
%% =========================Import ID data========================
ID_GADok=importdata('ID_GADok.mat');
ID_GADnotok=importdata('ID_GADnotok.mat');
ID_HC=importdata('ID_HC.mat');
%% =========================Cell to string========================
ID_GADok=cellstr(ID_GADok);
ID_GADnotok=cellstr(ID_GADnotok);
ID_HC=cellstr(ID_HC);
%% ========================String to double=======================
ID_GADok=cellfun(@str2double,ID_GADok,'UniformOutput',1);
ID_GADnotok=cellfun(@str2double,ID_GADnotok,'UniformOutput',1);
ID_HC=cellfun(@str2double,ID_HC,'UniformOutput',1);
%% =======================Locate the id===========================
[IFmember_GADok,Locmember_GADok]=ismember(ID_GADok,DataExcel_GAD(:,1));
[IFmember_GADnotok,Locmember_GADnotok]=ismember(ID_GADnotok,DataExcel_GAD(:,1));
[IFmember_HC,Locmember_HC]=ismember(ID_HC,DataExcel_HC(:,3));

%% ===================Acquir demographic data=====================
Data_GAD_Dem=DataExcel_GAD_Raw(2:end,[7,8,9,13]);
Data_HC_Dem=DataExcel_HC_Raw(2:end,[7,8,11]);
%Age and Edu
MyCell2double=@(x) x(1:end-1);
Data_GAD_AgeEdu=cellfun(MyCell2double,Data_GAD_Dem(:,2:end),'UniformOutput',0);
Data_GAD_AgeEdu(:,3)=cellfun(MyCell2double,Data_GAD_AgeEdu(:,3),'UniformOutput',0);
Data_GAD_AgeEdu=cellfun(@str2double,Data_GAD_AgeEdu(1:46,:), 'UniformOutput',0);
Data_GAD_AgeEdu=cell2mat(Data_GAD_AgeEdu);
Data_HC_AgeEdu=cellfun(MyCell2double,Data_HC_Dem(1:20,2:end),'UniformOutput',0);
Data_HC_AgeEdu=[Data_HC_AgeEdu;Data_HC_Dem(21:end,2:3)];
Data_HC_AgeEdu_low=cellfun(@double,Data_HC_AgeEdu(21:end,:), 'UniformOutput',0);
Data_HC_AgeEdu_up=cellfun(@str2double,Data_HC_AgeEdu(1:20,:), 'UniformOutput',0);
Data_HC_AgeEdu=[Data_HC_AgeEdu_up;Data_HC_AgeEdu_low];
Data_HC_AgeEdu=cell2mat(Data_HC_AgeEdu);
% Gender
MyStrcmp=@(x) strcmp(x,'男');
Data_GAD_Gender=cellfun(MyStrcmp,Data_GAD_Dem(:,1));
Data_HC_Gender=cellfun(MyStrcmp,Data_HC_Dem(:,1));
% All: gender,age,education,duration of illness and the last 6 column
Data_GAD_Dem=[Data_GAD_Gender(1:46),Data_GAD_AgeEdu,cell2mat(DataExcel_GAD_Raw(2:47,14:19))]; %gender,age,education,duration of illness and the last 6 column
Data_HC_Dem=[Data_HC_Gender,Data_HC_AgeEdu,cell2mat(DataExcel_HC_Raw(2:end,19:24))]; %gender,age,education and the last 6 column
% add order ID at the first column
% Data_GAD_Dem=[[1:size(Data_GAD_Dem,1)]',Data_GAD_Dem]; 
% Data_HC_Dem=[[1:size(Data_HC_Dem,1)]',Data_HC_Dem];
% delete data if it has not the corrspond ID
% Data_GAD_Dem=Data_GAD_Dem;
% Data_HC_Dem=Data_HC_Dem;
%% ============Extract excel data according ID order==============
% 如果有某个ID在excel原始数据中没有对应的情况，则先将此处的0变为1，从而完成循序调整
Locmember_GADok(Locmember_GADok==0)=1;
Locmember_GADnotok(Locmember_GADnotok==0)=1;
Locmember_HC(Locmember_HC==0)=1;
% 根据ID进行循序调整，记住HC的循序可能存在问题，因为很多HC没有原始ID.Note.此处在量表第一列加了order ID
ScaleSorted_GADnotok=[(1:numel(Locmember_GADnotok))',Data_GAD_Dem(Locmember_GADnotok,:)];
ScaleSorted_GADok=[(1:numel(Locmember_GADok))',Data_GAD_Dem(Locmember_GADok,:)];
ScaleSorted_HC=[(1:numel(Locmember_HC))',Data_HC_Dem];% HC 并没有按照ID来排序，因为有许多HC没有原始ID
% 删除没有原始ID的数据
ScaleSorted_GADnotok=ScaleSorted_GADnotok(IFmember_GADnotok',:);
ScaleSorted_GADok=ScaleSorted_GADok(IFmember_GADok',:);
% ScaleSorted_HC=ScaleSorted_HC(IFmember_HC',:);