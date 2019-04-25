function lc_exact_fc(all_file_path,out_path)
% extract the fc values (z values) from the .mat files
%%
% input
if nargin < 1
    in_path=uigetdir(pwd,'folder containing files');
    % fetch all files path
    file_struct=dir(fullfile(in_path,'*.mat'));
    file_name={file_struct.name}';
    all_file_path=fullfile(in_path,file_name)';
end

if nargin < 2
    out_path=uigetdir(pwd,'saveing folder');
end

n_file=length(all_file_path);
zvalues=zeros(n_file,1);
for i = 1: n_file
    fprintf('%d/%d\n',i,n_file)
    % load file
    data=importdata(all_file_path{i});
%     name1=data.names;
%     name2=data.names2;
    % extract z values
    zvalues(i)=data.Z(165,166);
end

% save to excel
disp('saving...');
mysplit=@(str) strsplit(str,'.');
file_name_before=cellfun(mysplit,file_name,'UniformOutput',false);
file_name_before=cellfun(@(mycell) mycell{1}, file_name_before,'UniformOutput',false);
xlswrite(fullfile(out_path,'zvalues.xlsx'),[file_name_before,cellstr(num2str(zvalues))], 'sheet1','A2');
xlswrite(fullfile(out_path,'zvalues.xlsx'),[{'ROI'},{'zvalues'}], 'sheet1','A1');
disp('Done!\n');
end