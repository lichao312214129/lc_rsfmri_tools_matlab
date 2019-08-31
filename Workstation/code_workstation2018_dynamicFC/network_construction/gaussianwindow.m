function w = gaussianwindow(N,x0,sigma)
x = 0:N-1;
w = exp(- ((x-x0).^2)/ (2 * sigma * sigma))';