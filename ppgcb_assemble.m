function y = ppgcb_assemble(x, i0, k, r, ETA, nW, nE, nX)
%PPGCB_ASSEMBLE  Filters each 10 s window with nE samples of context on each
%   side using its own (k, r) threshold multiplier, keeps the central part plus
%   nX samples, and cross-fades adjacent windows with linear weights.
x = x(:); num = zeros(size(x)); den = zeros(size(x));
up  = (1:2*nX)' / (2*nX + 1);
wts = [up; ones(nW - 2*nX, 1); flipud(up)];
for w = 1:numel(i0)
    s  = i0(w);
    ye = ppgcb_wavelet_filter(x((s - nE):(s + nW + nE - 1)), ETA(r(w) + 1, k(w)));
    io = (s - nX):(s + nW + nX - 1);
    num(io) = num(io) + wts .* ye(nE - nX + 1 : nE + nW + nX);
    den(io) = den(io) + wts;
end
y = num ./ den; y(den == 0) = NaN;
end
