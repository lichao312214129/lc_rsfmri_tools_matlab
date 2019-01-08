function y = vals2quantile(x, p)

p = 100.*p;
n = length(x);
x = sort(x,1);
q = [0 100*(0.5:(n-0.5))./n 100]';
xx = [x(1,:); x(1:n,:); x(n,:)];
y = interp1q(q,xx,p(:));
y = reshape(y, size(p));
