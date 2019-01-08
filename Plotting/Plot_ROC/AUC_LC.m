function [AUC]=AUC_LC(RealLabel,Pred)  
%计算AUC值,RealLabel为原始样本标签,Pred为分类器得到的标签  
RealLabel=reshape(RealLabel,length(RealLabel),1);Pred=reshape(Pred,length(Pred),1);%转换为行或列向量  
RealLabel=RealLabel==1;%将非1设为0.
[~,I]=sort(Pred);  
M=0;N=0;  
for i=1:length(Pred)  
    if(RealLabel(i)==1)  
        M=M+1;  
    else  
        N=N+1;  
    end  
end  
sigma=0;  
for i=M+N:-1:1  
    if(RealLabel(I(i))==1)  
        sigma=sigma+i;  
    end  
end  
AUC=(sigma-(M+1)*M/2)/(M*N); 
end

