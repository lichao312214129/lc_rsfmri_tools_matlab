a=eye(100,100);
a(a==0)=rand(sum(a(:)==0),1);
f=imagesc(a);
set(gca,'xtick',10:10:100,'xticklabel',10:10:100) %xtick就是你要在哪些地方显示刻度，xticklabel