function  all_subj_FCmatrix_2D=extract_triu(all_subj_FCmatrix)
% 提取n_subj*n_node*n_node矩阵中每个被试的上三角矩阵（不包括对角线）
mask_triu=ones(size(all_subj_FCmatrix,2));
mask_triu(tril(mask_triu)==1)=0;
mask_triu=mask_triu==1;

n_subj=size(all_subj_FCmatrix,1);
fc=squeeze(all_subj_FCmatrix(1,:,:));
all_subj_FCmatrix_2D=zeros(n_subj,length(fc)*(length(fc)-1)/2);
for i =1:n_subj
    fc=squeeze(all_subj_FCmatrix(i,:,:));
    all_subj_FCmatrix_2D(i,:)=fc(mask_triu);
end
end