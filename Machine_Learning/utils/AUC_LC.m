function AUC=AUC_LC(Real_label,preds)  
%计算AUC值(area under roc curve),
%input:Real_label为原始样本标签,preds为分类器得到的标签  
Real_label=reshape(Real_label,length(Real_label),1);
preds=reshape(preds,length(preds),1);%转换列向量  
Real_label=Real_label==1;%将非1设为0.
%%
[~,I]=sort(preds);  
M=0;N=0;  
for i=1:length(preds)  
    if(Real_label(i)==1)  
        M=M+1;  
    else  
        N=N+1;  
    end  
end  
sigma=0;  
for i=M+N:-1:1  
    if(Real_label(I(i))==1)  
        sigma=sigma+i;  
    end  
end  
AUC=(sigma-(M+1)*M/2)/(M*N); 
end

