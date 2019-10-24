function lc_gca_bivariate_coefficient_grouplevel(allsubj,order,covariables)
% load ROISignals
img_path=uigetdir('pwd','Selecting ROISignals');
img_s=dir(img_path);
img_name={img_s.name};
img_name=img_name(3:end)';
fun=@(a) fullfile(img_path,a);
img_path_name=cellfun(fun,img_name, 'UniformOutput',false);
% Selecting save results
outputdir=uigetdir('pwd','Selecting output directory');
nsubj = length(img_path_name);
for i = 1:nsubj
fprintf('%d/%d\n',i,nsubj);
subjfile = img_path_name{i};
timecourses =  importdata(subjfile);
[GrangerCausalCefficient, result_x2y,result_y2x,result_auto,roi_sequence] = lc_gca_bivariate_coefficient(timecourses,1,[]);
savename = img_name{i};
savename  = fullfile(outputdir, savename);
save(savename, 'GrangerCausalCefficient');
end