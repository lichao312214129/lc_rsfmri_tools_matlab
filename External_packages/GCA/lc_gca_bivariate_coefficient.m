function lc_gca_bivariate_coefficient(img_path_name,outputdir,order,covariables)
% load ROISignals
if nargin < 1
    img_path=uigetdir('pwd','Selecting ROISignals');
    img_s=dir(img_path);
    img_name={img_s.name};
    img_name=img_name(3:end)';
    fun=@(a) fullfile(img_path,a);
    img_path_name=cellfun(fun,img_name, 'UniformOutput',false);
else
    [~,img_name] = cellfun (@fileparts, img_path_name,'UniformOutput',false);
end
% Selecting save results
if nargin < 2
    outputdir=uigetdir('pwd','Selecting output directory');
end

if nargin < 3
    order = 1;
end

if nargin < 4
    covariables = [];
end

nsubj = length(img_path_name);
for i = 1:nsubj
    fprintf('%d/%d\n',i,nsubj);
    subjfile = img_path_name{i};
    timecourses =  importdata(subjfile);
    [GrangerCausalCefficient, result_x2y,result_y2x,result_auto,roi_sequence] = lc_gca_bivariate_coefficient_base(timecourses,order,covariables);
    savename = img_name{i};
    savename  = fullfile(outputdir, savename);
    save(savename, 'GrangerCausalCefficient');
end
disp('Done!');
end