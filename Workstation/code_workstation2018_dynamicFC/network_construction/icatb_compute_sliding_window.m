function c = icatb_compute_sliding_window(nT, win_alpha, wsize)
%% Compute sliding window
% Thanks to GIFT software

nT1 = nT;
if mod(nT, 2) ~= 0
    nT = nT + 1;
end

m = nT/2;
w = round(wsize/2);
gw = gaussianwindow(nT, m, win_alpha);
b = zeros(nT, 1);  b((m -w + 1):(m+w)) = 1;
c = conv(gw, b); c = c/max(c); c = c(m+1:end-m+1);
c = c(1:nT1);

function w = gaussianwindow(N,x0,sigma)
x = 0:N-1;
w = exp(- ((x-x0).^2)/ (2 * sigma * sigma))';