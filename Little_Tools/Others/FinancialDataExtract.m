% 用途：将txt文档里面的相关项目的数据提取出来，然后以投资者为单位保存到excel表格中
% txt文档中的项目用 '|'为分割，可以自行调整
%% ==========================Input==============================
% input:1 txt文档中的项目分隔符
ProjSep='|';
% input2: 选择结果存放路径
[Path_Results] =uigetdir({},'选择第结果存放路径地址（文件夹）');
% input3: 需提取的项目名称以及要写入到excel的项目名称
NameToExtrat={'户名','帐号','交易日期','摘要','借贷标志','交易金额','卡号'};
NameToWrite={'户名','帐号','交易日期','摘要','借贷标志','交易金额','投资人','收返利卡号'};
% input4: 选择需提取的人（投资人）的名字
[NameOfPersonFile,PathOfPersonFile,~] = uigetfile({'*.xlsx;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','请选择投资人名称的excel文件');
[~,NameOfPerson,~]=xlsread([PathOfPersonFile,'\',NameOfPersonFile]);
% input5: 读取所有源数据
%    number of source folder
NumOfSource=input('请输入源文件夹的个数，然后回车： ','s');
NumOfSource=str2double(NumOfSource);
%    read source folder path
Path_Source=cell(2,1);
for i=1:NumOfSource
    [Path_Source{i}] =uigetdir({},['选择第',num2str(i),'源数据文件夹']);
end
%% =======================All Input Completed!========================

%% ===============Read all txt file path in source================
Path_TxtFile={};
for i=1:NumOfSource
    SourceCell=dir(Path_Source{i});
    Name_SourceFile={SourceCell.name};
    Name_SourceFile=Name_SourceFile(1,3:end)';
    Path_SourceFile=strcat(Path_Source{i},'\',Name_SourceFile);
    for j=1:numel(Path_SourceFile)
        TxtFile=dir(Path_SourceFile{j});
        TemName_TxtFile={TxtFile.name}';
        TemName_TxtFile=TemName_TxtFile(3:end);
        TemPath_TxtFile=strcat(Path_SourceFile{j},'\',TemName_TxtFile);
        Path_TxtFile=cat(1,Path_TxtFile,TemPath_TxtFile);
    end
end
%% ===================Read Txt Path Completed!===================

%% 进入主程序：两层循环，第一层是投资者循环，第二层是txt文件的循环
for NumOfPerson=1:numel(NameOfPerson) % 第一层循环：投资者
    fprintf('第 %1d 个投资者\n',NumOfPerson);
    % 打开txt文件:第二层循环
    ExtractedData_AllTxt={};%给某个人所有txt中提取的数据建立空元胞矩阵
    %% =============Begin to extract one person's data============
    for NumOfTxt=1:numel(Path_TxtFile)
        if rem(NumOfTxt,5)==0;fprintf('第 %1d 个txt文件\n', NumOfTxt);end
        fid = fopen( Path_TxtFile{NumOfTxt},'r');
        TxtCell = textscan(fid,'%s');
        TxtCell=TxtCell{1};
        fclose(fid);
        %% 确定所有项目在每一行的对应位置
        NameOfTxtPreject=TxtCell(1);
        ContentOfTxt=TxtCell(2:end);
        % txt项目
        IndexOfProjectSep=strfind(NameOfTxtPreject{1},ProjSep);
        % 找到项目名称的index
        for i=1:numel(NameToExtrat)
            IndexOfProjectName(i)=strfind(NameOfTxtPreject{1},NameToExtrat{i});%
        end
        % 项目名的第一个字符的前一个index为相邻分隔符的index
        IndexOfProjectName=IndexOfProjectName-1;
        % 根据 上一个IndexOfProjectName来确定对应分隔符在分隔符index矩阵里面的index
        [IfMember,Ind]=ismember(IndexOfProjectName,IndexOfProjectSep);
        % txt内容
        MyStrcmpSep=@(Str) strfind(Str,ProjSep);
        IndexOfContentSep=cellfun(MyStrcmpSep,ContentOfTxt,'UniformOutput', false);
        % 确定某个投资者出现在txt的哪一行
        MyStrcmpName=@(Str) strfind(Str,NameOfPerson{NumOfPerson});
        IfMatch=cellfun(MyStrcmpName,ContentOfTxt,'UniformOutput', false);
        % ===============================提取内容=================================
              
        try
            NumOfMatch=sum(cell2mat(IfMatch)~=0);
        catch
            NumOfMatch=0;
            for i=1:numel(IfMatch)
                if  ~isempty(IfMatch{i})
                     NumOfMatch= NumOfMatch+1;
%                     fprintf('第%d个不为空\n',i);
                end
            end
        end
        % 判断某个txt文档中是否有投资人信息，没有则进入下一个循环：节省时间
        if NumOfMatch==0
            continue;
        end
        % 开始提取信息
        ExtractedData_OneTxt=cell(NumOfMatch,numel(NameToExtrat));
        count=0;
        for i=1:numel(IfMatch)
            if ~isempty(IfMatch{i})
                count=count+1;
                for j=1:numel(NameToExtrat)
                    LocOfStr=IndexOfContentSep{i}(Ind(j):Ind(j)+1);
                    if LocOfStr(2)-LocOfStr(1)==1
                        ExtractedData_OneTxt{count,j}='N/A';% 当为空时，填入N/A
                    else
                        ExtractedData_OneTxt{count,j}=ContentOfTxt{i}(LocOfStr(1)+1:LocOfStr(2)-1);
                    end
                end
            end
        end
        ExtractedData_AllTxt=cat(1,ExtractedData_AllTxt,ExtractedData_OneTxt);
    end
    %% =====one person's data have been extract completely!=======
    %% =======================write to excel======================
    if ~isempty(ExtractedData_AllTxt)
        DataOfExcel={};
        DataOfExcel(:,[1:6,8])=ExtractedData_OneTxt;
        DataOfExcel(:,7)={NameOfPerson{NumOfPerson}};
        FileNameOfExcel = [Path_Results,filesep,NameOfPerson{NumOfPerson},'.xlsx'];
        DataOfExcel =cat(1,NameToWrite,DataOfExcel);
                Inves=DataOfExcel(2:end,6);
                Inves=cellfun(@str2num,Inves);
                Inves=sum(Inves);
                InvesCell={'投资合计',Inves};
        sheet = 1;
        xlRange1 = 'A1';
                NumOfDataRaw=size(DataOfExcel,1);
                xlRange2 = strcat('A',num2str(NumOfDataRaw+1));
        xlswrite(FileNameOfExcel,DataOfExcel,sheet,xlRange1);
                xlswrite(FileNameOfExcel,InvesCell,sheet,xlRange2);
    else
        fprintf(['投资人:\t',NameOfPerson{NumOfPerson},'\t','没有可提取数据\n']);
    end
    %% =======one peson's data have been written to excel=========
end
%% =============All peson's data have been written to excel================
fprintf('%9.0f个投资人的数据已被提取，并保存到excel文档!\n',numel(NameOfPerson));
