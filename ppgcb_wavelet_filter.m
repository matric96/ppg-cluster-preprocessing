function y = ppgcb_wavelet_filter(x, eta)
%PPGCB_WAVELET_FILTER  Five-level sym4 DWT: A5 removed, D1-D3 soft-thresholded
%   with lambda_j = eta * median(|W_j|)/0.6745, D4-D5 preserved.
x = x(:) - mean(x);
[c, l] = wavedec(x, 5, 'sym4');
c(1:l(1)) = 0;
for j = 1:3
    pos = numel(l) - j; s = sum(l(1:pos-1)) + 1; e = s + l(pos) - 1;
    w = c(s:e);
    lam = eta * median(abs(w)) / 0.6745;
    c(s:e) = sign(w) .* max(abs(w) - lam, 0);
end
y = waverec(c, l, 'sym4');
end
