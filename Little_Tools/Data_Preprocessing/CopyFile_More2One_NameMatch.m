function  CopyFile_More2One_NameMatch(name_source)
%Email: lichao19870617@gmail.com
%功能： 将第三级文件或文件夹复制并整理到其他路径。
%具体功能如：将Dcm2AsiszImg整理后的DICOM或其他文件复制到相应文件夹(注意：此DICOM或其他文件在三级目录下，如Controls-Subject1-RSBOLDFMRI-'DICOM')，以便DPARSF、DPABI等软件处理
% 与copy_file_for_DPARSF不同的是：其将多个subject文件下的文件复制到另一个总的文件夹下（More2One）。
%input:
%     name_source:需要复制的文件夹可以是文件名的精确全称，如：'501_T1W_3D_TFE_ref2'，也可以是可以确认文件名的模糊字段，如：'T1W'等,注意：可以是多个匹配字段。
%     如不输入,如只输入：copy_file2DPARSF('T1W'),则进行字段匹配。
%     使用方法：将分类好的DICOM文件全部放在一个文件夹下面。然后运行此代码，例如：copy_file2DPARSF(‘T1W’, 'fuzzy')
%%
fprintf('Copying==============================>>>\n')
if nargin<1
    Name_Fragment_Char=input('请输入一或多个匹配字段，多个字段以*号隔开：','s');
    Name_Fragment_Char=['*',Name_Fragment_Char,'*'];
    loc_star=find(Name_Fragment_Char=='*');
    for i=1:length(loc_star)-1
        name_source{i}=Name_Fragment_Char(loc_star(i)+1:loc_star(i+1)-1);
    end
end
%% 源文件及目标路径
%源
path_source1 = spm_select(1,'dir','选择需要复制的文件夹');
up1 = dir(path_source1);
file_name_source={up1.name}';
%目标
path_target = spm_select(1,'dir','目标路径');
%% 在目标路径下建立存放数据的文件夹并根据源文件命名
name_raw=input('请输入文件夹名：','s');
if ~exist([path_target,filesep,name_raw], 'file')
    mkdir(fullfile(path_target,name_raw));%创建文件存放的地址
end
loc_subject=[path_target,filesep,name_raw];%存放各个subject的目录
%%
for i=3:length(file_name_source)
    %显示进程：10个一行
    if ~rem(i-2,10)||i==length(file_name_source)
        fprintf([num2str(i-2),'/',num2str(length(file_name_source)-2),'\n'])%count
    else
        fprintf([num2str(i-2),'/',num2str(length(file_name_source)-2),',']);%count
    end
    up2=dir(fullfile(path_source1,up1(i).name));
    file_name2={up2.name}';
    %模糊匹配
    % 4. 模糊匹配img_name(i) 和oldname_pinyin：遍历oldname_pinyin
    % 以滑动窗的形式将oldname与file_name2进行比较，类似卷积操作，有为1的项，则模糊匹配成功（但不保证真实成功，因此str越精确越好）
    IfMatch=0;%此处一定要赋初始值0
    for j=1:length(file_name2)
        IfMatch(j)=NameMatch_Multiple_SliceWindow(file_name2{j},name_source);
    end
    loc_target=find(IfMatch==1);%当某个file_name2中有>=1处于旧名字重叠，则认为模糊匹配成功***，copy_*为位置
    %
    if isempty(loc_target)
        disp([file_name_source{i},' ','文件夹中没有想要复制的文件']);
    else
        % 复制
        copyfile([path_source1,filesep, char(file_name_source(i)),filesep,char(file_name2(loc_target))], ...
            [loc_subject,filesep,char(file_name_source(i)),'_',char(file_name2(loc_target))]);
    end
end
fprintf('Copy completed!\n')
end