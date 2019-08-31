function mat = lc_vec2mat(dfc_2d, numroi)
n_feature = size(dfc_2d, 1);
mat = zeros(numroi, numroi, n_feature);
for i = 1:n_feature
    mat(:,:,i) = vec2mat(dfc_2d(i,:),numroi);
end

function mat = vec2mat(vec,numroi)
temp = ones(numroi, numroi);
mat = zeros(numroi, numroi);
ind = triu(temp,1) == 1;
mat(ind) = vec;
mat = mat + mat';