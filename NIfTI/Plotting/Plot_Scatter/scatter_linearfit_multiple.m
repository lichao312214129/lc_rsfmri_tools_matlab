function scatter_linearfit_multiple( X,Y,Title,m,n )
%此函数将对各散点图以及线性拟合线画在一个图像上
%input----X为矩阵，每一列为一个变量；Y为与X相对应得矩阵，每一列为一个变量，x与y的列数相同
%R，P为相应的相关系数和p值，都是向量这两个值可以通过相关分析获得
%Title为亚散点图的标题，是一个元胞矩阵，几个散点图就有几个title
%m,n 为亚散点图的矩阵大小，m为行，n为列；本代码适合10个亚图以内的散点图绘制；超过10个需要调整代码！！
if nargin <=3 %如果未输入m和n，则按奇数和偶数，分别定义亚图格局。
N_SubFig=size(X,2);
  if N_SubFig==2
      m=1;n=2;
  elseif ~mod(N_SubFig,2)
      m=N_SubFig/2;n=N_SubFig/2;
  else
      m=(N_SubFig+1)/2;n=(N_SubFig+1)/2;
  end
end
if nargin <=2 %如果未输入Title,则Title为空。
    Title=cell(N_SubFig,1);
end
    for i=1:size(X,2)
        subplot(m,n,i);
        scatter_linearfit(X(:,i),Y(:,i),Title{i});
%         xlabel('Granger causal influence','FontName','Times New Roman','FontSize',30,'Rotation',0)
%         ylabel('ISI','FontName','Times New Roman','FontSize',30,'Rotation',90)
        set(gca,'box','off')
    end

end

