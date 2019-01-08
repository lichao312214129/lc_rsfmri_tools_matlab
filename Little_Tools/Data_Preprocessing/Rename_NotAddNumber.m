function Rename_NotAddNumber(object)
%用途：修改文件或者文件夹名，与Rename不同的是，本代码不在原有名后面加数字编号。
%object='folder' or 'file'
% current路径
currentFolder = pwd;
OldName={};
%% 执行
if nargin<1
    object='folder';
end
if strcmp(object,'folder')
    path_source1 = uigetdir({},'请选择文件夹');%选文件夹
    strut_path_source1=dir(path_source1);
    file_name1={strut_path_source1.name};
    star=3;
else
    [file_name1,path_source1,~] =uigetfile({'*';'*.nii';'*.img'},'MultiSelect','on','请选择图像或文件');%选文件
    star=1;
end
cd (path_source1)
len = length(file_name1);
if len>=1000
    disp('您的文件数目超过1000，请联系lichao19870617@163.com或者直接修改原代码');
    return;
end
filename = input('重命名为:','s');
Saveoldname = input('是否保留旧文件名（Y/N）:','s');
switch Saveoldname
    case 'Y'
        tic;
        for k=star:len
            oldname=char(file_name1{k});
            if star==1
                OldName{k}=oldname;
            else
                OldName{k-2}=oldname;
            end
            if strcmp(object,'folder')
                newname=strcat(filename,'_',oldname);
            else
                newname=strcat(filename,'_',oldname(1:find(oldname=='.')-1),oldname(find(oldname=='.'):end));
            end
            cmd=sprintf('rename %s %s',oldname,newname);
            system(cmd);
        end;
        disp(['重命名并保存旧文件名成功，运行时间=',num2str(toc),'秒']);
    case 'N'
        tic;
        for k=star:len
            oldname=char(file_name1{k});
            if star==1
                OldName{k}=oldname;
            else
                OldName{k-2}=oldname;
            end
            if strcmp(object,'folder')
                newname=strcat(filename ,int2str(k-2),'.nii');
            else
                newname=strcat(filename ,int2str(k),oldname(find(oldname=='.'):end));
            end
            cmd=sprintf('rename %s %s',oldname,newname);
                system(cmd);
        end;
        disp(['重命名并不保存旧文件名成功，运行时间=',num2str(toc),'秒']);
end
%  返回路径
cd (currentFolder);
%保存旧名字
save('OldName.mat','OldName');
end

