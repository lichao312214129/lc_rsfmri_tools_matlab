function CopyFile_One2More_NameMatch(NameForMatch)
% =========================================================================
% 用途：将一个文件夹下面所有的nii文件分别放到各个subject文件夹下
% =========================================================================
% input:
%       NameForMatch=字符串片段（>=1个）；将存在此字符串片段（>=1个）的文件复制到别处
%% ===============================================================
fprintf('Copying==============================>>>\n')
if nargin<1
    Name_Fragment_Char=input('请输入一或多个匹配字段，多个字段以*号隔开：','s');
    Name_Fragment_Char=['*',Name_Fragment_Char,'*'];
    loc_star=find(Name_Fragment_Char=='*');
    for i=1:length(loc_star)-1
       NameForMatch{i}=Name_Fragment_Char(loc_star(i)+1:loc_star(i+1)-1);
    end
end
%% ===============================================================
% 新建文件夹存储被复制的文件
TIME=datestr(now,30);
loc_results=uigetdir({},'results folder');
if ~exist([loc_results,filesep,'FileCopy',TIME], 'file')
    mkdir([loc_results,filesep,'FileCopy',TIME]);%创建文件存放的地址
end
loc_copy=[loc_results,filesep,'FileCopy',TIME];%存放整理后的FunImg_sorted
%% 1.读取FunImg下所有文件的名字
[name,path,~] = uigetfile({'*.img;*.hdr;*.nii;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select files');
%% 2. 把旧名字的下划线删除：oldname

%% 3. 提取oldname的名字拼音部分：name

%% 4. 模糊匹配
IfMatch=0;%此处一定要赋初始值0
for i=1:length(name)
    %显示进程：10个一行
    if ~rem(i,10)||i==length(name)
        fprintf([num2str(i),'/',num2str(length(name)),'\n'])%count
    else
        fprintf([num2str(i),'/',num2str(length(name)),',']);%count
    end
    
    IfMatch(i)=NameMatch_Multiple_SliceWindow(name{i},NameForMatch);
    
    if IfMatch(i)==0
        continue;
    else
        copyfile([path,filesep,char(name(i))],loc_copy);
    end
end
%% 保存被复制的文件记录
fid = fopen([loc_copy,filesep,'IfMatch.txt'],'a');
fprintf(fid,[datestr(now,31) ,'\r\n']);
fprintf(fid,'被复制的文件夹情况=======================================\r\n');
fprintf(fid,'共%d文件\r中有%d个文件被复制\r\n',numel(IfMatch),sum(IfMatch));
fprintf(fid,'%d\r\n',IfMatch);
fprintf(fid,'=======================================================\r\n');
fclose(fid);
fprintf('===============Completed!===============\n');%count
end