function lc_check_images(normal_num, root_path, save_path)
% This function is used to check the number of image data in each subject folder
% If the file with the abnormal number in a subject folder, then this function record it.
%% ------------------------------------------------------------------------------------------------
% input
if nargin < 1
    normal_num = eval(input('请输入正常文件的数量，并按任意键继续:', 's'));
end

if nargin < 2
    root_path = uigetdir(pwd, '请选择检查的文件夹');
end

if nargin < 3
    save_path = uigetdir(pwd, '请选择结果保存的文件夹');
end

% read all subject folder path
sub_path = dir(root_path);
sub_path = {sub_path.name}';
sub_path = sub_path(3:end);
sub_path = fullfile(root_path, sub_path);

% count number of files in each subject folder
n_sub = length(sub_path);
abnormal_sub = {};
for i = 1:n_sub
    current_subpath = sub_path{i};
    nfile = length(dir(current_subpath))-2;
    if nfile ~= normal_num
        abnormal_sub = [abnormal_sub; current_subpath];
    end
end

time = datestr(now);
f = fopen(fullfile(save_path, '异常数量的被试.txt'), 'a+');
fprintf(f, '\n%s\n' ,['============',time,'============']);
fprintf(f,'%s\n',abnormal_sub{:});
fclose(f);
end