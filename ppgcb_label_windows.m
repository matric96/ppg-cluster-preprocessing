function [k, q, r] = ppgcb_label_windows(feat, A, degen, model, ivIdx)
%PPGCB_LABEL_WINDOWS  Motion cluster (nearest trained centroid in normalized
%   SD-skewness space), CQI and reliability flag for each 10 s window.
%   ivIdx (optional) identifies the continuous block of each window; motion
%   labels are smoothed only within a block and only among reliable windows.
n = size(feat, 1);
if nargin < 5, ivIdx = ones(n, 1); end
Z = min(max((feat - model.fMin) ./ (model.fMax - model.fMin), 0), 1);
[~, k] = min(pdist2(Z, model.C), [], 2);
q = 1 - (log1p(A) - model.Lmin) / (model.Lmax - model.Lmin);
q = min(max(q, 0), 1);
q(degen) = 0;
r = double(q >= model.Tq);
for i = 2:n-1   % isolated labels among reliable neighbours of the same block
    same = ivIdx(i-1) == ivIdx(i) && ivIdx(i+1) == ivIdx(i);
    if same && r(i) && r(i-1) && r(i+1) && k(i-1) == k(i+1) && k(i) ~= k(i-1)
        k(i) = k(i-1);
    end
end
end
