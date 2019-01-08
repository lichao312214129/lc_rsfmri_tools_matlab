load carbig;
X = [Displacement Horsepower Weight Acceleration MPG];
nans = sum(isnan(X),2) > 0;
[A,B,r,U,V] = canoncorr(X(~nans,1:3),X(~nans,4:5));

X=rand(10,50);
Y=[X(:,1:20),rand(10,4)];
[A,B,r,U,V,stats] = canoncorr(X,Y);