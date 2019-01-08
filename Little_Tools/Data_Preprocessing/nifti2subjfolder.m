function nifti2subjfolder(foldername_subject)
% input:
% foldername_subject=整理后每个被试文件夹名字的前缀
%output：
% 整理的后的文件，如FunImg_sorted
% =========================================================================
% 用途：将一个文件夹下面所有的nii文件分别放到各个subject文件夹下
% =========================================================================
% 使用背景：
% 1.DICOM文件已经被Dcm2AsiszImg.exe程序整理好--
% 2.某个模态的DICOM已经被copy_file_for_DPARSF.m代码整理成DPASFA所需格式--
% 3.所有被试文件夹被Rename代码重新命名和extractID提取ID，并得到OldName.mat和ID.mat--
% 4.FunRaw目录一起拖入dcm2niigui.exe，转化成4D.nii/.hdr文件，但是这些文件都在一起，没有与上一步的文件夹名字对应，从而不知道那一个.nii
% 属于哪一个被试--
% =========================================================================
% 处理及代码流程
% 1. 将转化出来的.nii/.hdr一起放到FunImg下
% 2. 将其与Oldname比较
% 3. 如果其与第i个Oldname相同，则将他放到文件名为'Poki'的文件夹下
% 1. 将其与Oldname比较
% 2. 如果其与第i个Oldname相同，则将他放到文件名为'Poki'的文件夹下
% 具体流程
% 1. 读取FunImg下所有文件的名字：img_name
% 2. 把旧名字的下划线删除：oldname
% 3. 提取oldname的名字拼音部分：oldname_pinyin
% 4. 模糊匹配img_name(i) 和oldname_pinyin：遍历oldname_pinyin
% 5. 将定位的img_name所属的nii和hdr都复制到另一个文件夹：'Poki'
%% ===============================================================
% 新建文件夹存储整理的funimg
loc_results=uigetdir({},'results folder');
if ~exist([loc_results,filesep,'FunImg_sorted'], 'file')
    mkdir([loc_results,filesep,'FunImg_sorted']);%创建文件存放的地址
end
loc_FunImg_sorted=fullfile(loc_results,'FunImg_sorted');%存放整理后的FunImg_sorted
% 分类后文件夹名字前缀
if nargin<1
    foldername_subject=input('请输入sub_folder name 的前缀: ','s');
end
%% 1.读取FunImg下所有文件的名字
[name_ImgandHdr,path_ImgandHdr,~] = uigetfile({'*.img;*.hdr;*.nii;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select files');
%% 2. 把旧名字的下划线删除：oldname
[name_oldname,path_oldname,~] = uigetfile({'*.mat','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','select OldName.mat files');
oldname=importdata([path_oldname,name_oldname]);
oldname=oldname';
for i=1:length(oldname)
    oldname{i}(oldname{i}=='_')=[];%删除下划线
end
%% 3. 提取oldname的名字拼音部分：oldname_pinyin
for i=1:length(oldname)
%     loc_ForMorF=oldname{i}=='M'|oldname{i}=='F';
%     loc_end=find(loc_ForMorF==1);
    loc_ForMorF=oldname{i}=='Y';
    loc_end=find(loc_ForMorF==1);
    loc_end=loc_end(end)-1;%最后一个M或者F字母的位置，即为拼音的结尾位置
    oldname_pinyin{i}=oldname{i}(1:loc_end);%拼音，此处可以根据实际情况修改使用***
end
%% 4. 模糊匹配img_name(i) 和oldname_pinyin：遍历oldname_pinyin
% 以滑动窗的形式将oldname与name_ImgandHdr进行比较，类似卷积操作，有为1的项，则模糊匹配成功（但不保证真实成功，因此str越精确越好）
for i=1:length(oldname_pinyin)
    %显示进程：10个一行
    if ~rem(i,10)||i==length(oldname_pinyin)
        fprintf([num2str(i),'/',num2str(length(oldname_pinyin)),'\n'])%count
    else
        fprintf([num2str(i),'/',num2str(length(oldname_pinyin)),',']);%count
    end
    window_length=length(oldname_pinyin{i});
    for j=1:length(name_ImgandHdr)
        %滑动比较
        loc_start=1;loc_end=loc_start+window_length-1;
        while loc_end<=length(name_ImgandHdr{j})
            resutl_cmp(j,loc_start)=strcmp(oldname_pinyin{i},name_ImgandHdr{j}(loc_start:loc_end));%所有name_ImgandHdr中与第i个旧名字匹配的结果。
            loc_start=loc_start+1;loc_end=loc_end+1;%每次向后滑动一个字母
        end
    end
    loc_ImgandHdr_copy=find(sum(resutl_cmp,2)>=1);%当某个name_ImgandHdr中有>=1处于旧名字重叠，则认为模糊匹配成功***，copy_*为位置
    if isempty(loc_ImgandHdr_copy)
        fprintf([name_ImgandHdr{i},' ','文件夹中没有想要复制的文件\n']);
        continue %找不到某个旧名字，则不执行后续循环内代码，进入下一个旧名字
    end
    % 新建文件夹存储源数据
    if ~exist([loc_FunImg_sorted,filesep,foldername_subject,num2str(i)], 'file')
        mkdir([loc_FunImg_sorted,filesep,foldername_subject,num2str(i)]);%创建文件存放的地址
    end
    loc_subfolder=[loc_FunImg_sorted,filesep,foldername_subject,num2str(i)];
    %% 5. 复制,因为loc_ImgandHdr_copy可能有很多个，因此使用循环
    for k=1:numel(loc_ImgandHdr_copy)
        copyfile([path_ImgandHdr,filesep,char(name_ImgandHdr(loc_ImgandHdr_copy(k)))],loc_subfolder);
    end
end
fprintf('===============Completed!===============\n');%count
end