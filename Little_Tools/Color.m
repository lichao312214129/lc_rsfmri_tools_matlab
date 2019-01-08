
n=10;
p=zeros(n,n);
for i=1:n
    p(i,:)=i^.6+[1:n]';
end
imagesc(p);

%%
[x,y]=meshgrid(1:2);
z=x+y;
surf(x,y,z);
shading interp
view(0,90)