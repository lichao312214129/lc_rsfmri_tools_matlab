function lc_gca_bivariate_coefficient_subjlevel(allsubj,order,covariables)
img_path=uigetdir('ROISignals');
img_s=dir(img_path);
img_name={img_s.name};
img_name=img_name(3:end)';
fun=@(a) fullfile(img_path,a);
img_path_name=cellfun(fun,img_name, 'UniformOutput',false);

nsunj = length(img_path_name);
for i = 1:nsubj
timecourses =  importdata(img_path_name{i});
[result_x2y,result_y2x,result, roi_sequence] = lc_gca_bivariate_coefficient(timecourses,1,[]);
end