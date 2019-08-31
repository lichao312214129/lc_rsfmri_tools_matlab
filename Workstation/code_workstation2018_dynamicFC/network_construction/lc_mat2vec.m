function [vec, ind] = lc_mat2vec(mat)
% vec = mat2vec(mat)
% returns the lower triangle of mat
% mat should be square
% Revised by Li Chao

[n,m] = size(mat);

if n ~=m
    error('mat must be square!')
end

temp = ones(n);

%% find the indices of the upper triangle of the matrix
ind = triu(temp, 1) == 1;
vec = mat(ind);