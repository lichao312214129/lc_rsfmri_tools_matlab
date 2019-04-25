function lc_2niigz_V2(in_path,out_path,dcm2nii_path,in_suffix)
% transform .img/.nii files to .nii.gz files
% Note. each subj has many files, which in one folder. All subj folder in a
% folder too.
% step1: concat all files for each subj
% step2: save each subj's file that concated to .nii
% step3: use dcm2nii.exe to  transform the .nii into .nii.gz for each subj
% step4: move the .nii.gz to out_path
%%
% input
if nargin < 4
    in_suffix='*.img'; % if source file is .img, you could input .nii, if you source file is .nii
    fprintf([repmat('=',1,20),'\n'])
    fprintf('your source file type is %s?\nif not, edit the code in line 6 to ''*.nii\n',in_suffix);
    fprintf('press any key to continue\n');
    fprintf([repmat('=',1,20),'\n'])
    pause;
end

if nargin < 3
    dcm2nii_path=pwd;
end

if nargin < 2
    out_path=uigetdir(pwd,'folder for saving results');
end

if nargin < 1
    in_path=uigetdir(pwd,'.img source folder');
end

% fetch all subj folder path
try
    all_subj_folder=dir(in_path);
catch
    all_subj_folder=dir(in_path);
end
all_subj_folder_name={all_subj_folder.name};
all_subj_folder_name=all_subj_folder_name(3:end);

% loop (step1,2,3,4)
n_subj=length(all_subj_folder_name);
tmp_nii_out_path=[out_path,filesep,'tmp.nii'];
for ith_subj=1:n_subj
    fprintf('%d/%d\n',ith_subj,n_subj);
    % fetch all nii path for each subj
    try
        all_file=dir(fullfile(in_path,all_subj_folder_name{ith_subj},in_suffix));
        all_file={all_file.name};
    catch
        all_file=dir([in_path,filesep,all_subj_folder_name{ith_subj},filesep,in_suffix]);
        all_file={all_file.name};
    end
    %concat all files for each subj according number(after the last '¡Á',but before '.')
    delimiter='x';  % str that for spliting all file name for one subj to sort the order of file
    index = sort_files_for_one_subj(all_file,delimiter);
    
    % load all file for one subj and sort
    Data=[];
    n_file=length(all_file);
    for ith_file = 1:n_file
         fprintf('\t\t%d/%d',ith_file,n_file);
        one_file=[in_path,filesep,all_subj_folder_name{ith_subj},filesep,all_file{index(ith_file)}];
        data_struct=load_nii(one_file);
        data=data_struct.img;
%         [data,header]=y_Read(one_file);
        Data=cat(4,Data,data);
    end
    
    % save to 4d nii
    data_struct.img=Data;
    save_nii(data_struct,tmp_nii_out_path);
%     y_Write(data,header,[out_path,filesep,'tmp.nii']);

    % nii to gz
    cmd=[
        strcat(dcm2nii_path,'\dcm2nii.exe'),...
        ' -b ' strcat(dcm2nii_path,'\dcm2nii_conv.ini'), ...
        [' ',tmp_nii_out_path]
        ];
    system(cmd);
    
    % remove/rename .nii.gz to out_path
    out_name =[out_path ,filesep , [all_subj_folder_name{ith_subj},'.nii.gz']];
    in_file=[out_path,filesep,'ftmp.nii.gz'];
    out_file=out_name;
    fprintf('%s\n%s\n%s\n%s\n','move',in_file,'to',out_file);
    movefile(in_file,out_file)
end

% delete tmp.niis
delete (tmp_nii_out_path);
disp('====== All Done! ======');
end

function index = sort_files_for_one_subj(all_file,delimiter)
% split all_file by delimiter
% return index
if nargin < 2
    delimiter='x';
end
mysplit=@(mystr) strsplit(mystr,delimiter);
[splited_str,~]=cellfun(mysplit,all_file,'UniformOutput',false);

n_file=length(splited_str);
order_num=zeros(n_file,1);
for i =1:n_file
    num=splited_str{i}{2};
    num=strsplit(num,'.');
    order_num(i)=str2double(num{1});
end
[~,index]=sort(order_num,'ascend');
end