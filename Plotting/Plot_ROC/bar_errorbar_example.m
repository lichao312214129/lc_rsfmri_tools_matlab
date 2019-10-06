x = 1:4;
y = rand(4,5);
h = bar(x,y);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',y/10,'.','linewidth',1)  % 将y/10替换为是误差矩阵即可
