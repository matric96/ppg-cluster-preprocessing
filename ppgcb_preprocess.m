function [y, info] = ppgcb_preprocess(sig, model, opts)
%PPGCB_PREPROCESS  Cluster-based PPG preprocessing with an ambient-light CQI.
%
%   [y, info] = ppgcb_preprocess(sig, model) filters a PPG recording with the
%   method described in Ricci et al., "A Novel Cluster-Based Approach for PPG
%   Signal Preprocessing: Motion Artifact Filtering and Ambient Light
%   Correction", Sensors (2026).
%
%   INPUT
%   sig    struct describing ONE continuous recording block (split the
%          recording at gaps longer than 1 s before calling this function):
%            .t     PPG/ambient-light time stamps (s), column vector
%            .ppg   PPG samples, N x C (C = 1 or 3 channels; averaged)
%            .amb   ambient-light samples, N x 1
%            .tAcc  accelerometer time stamps (s), M x 1
%            .acc   accelerometer samples, M x 3, in mg (gravity included)
%   model  trained parameters (see ppgcb_load_model): fields C, fMin, fMax,
%          Lmin, Lmax, Tq, ETA, epsA, epsV, rSat.
%   opts   optional struct: .fs (55), .winLen (10 s), .extLen (2 s),
%          .xfLen (0.5 s), .welchWin (256), .nfft (2048), .ppgSign (1).
%
%   OUTPUT
%   y      filtered PPG on the uniform time grid info.t (NaN outside the
%          analyzed windows)
%   info   struct with the grid (t), the averaged unfiltered PPG (x), and,
%          for every 10 s window: start index (i0), motion cluster (k),
%          CQI (q), reliability flag (r), PSD area (A), degenerate flag.

if nargin < 3, opts = struct(); end
o = defaults(opts);
fs = o.fs; nW = round(o.winLen*fs); nE = round(o.extLen*fs); nX = round(o.xfLen*fs);

% --- common uniform grid -----------------------------------------------------
t = sig.t(:); [t, iu] = unique(t);
ppg = sig.ppg(iu, :); amb = double(sig.amb(iu)); amb = amb(:);
tg = (t(1):1/fs:t(end))';
fm = @(z) fillmissing(z, 'linear', 'EndValues', 'nearest');
x  = o.ppgSign * mean(fm(interp1(t, double(ppg), tg)), 2);
am = fm(interp1(t, amb, tg));

% --- accelerometer: magnitude (g), 5 Hz low-pass at its own rate, resampling
[ta, ia] = unique(sig.tAcc(:)); acc = double(sig.acc(ia, :)) / 1000;
fsA = 1 / median(diff(ta));
[bA, aA] = butter(2, 5 / (fsA/2));
accG = fm(interp1(ta, filtfilt(bA, aA, sqrt(sum(acc.^2, 2))), tg));

% --- 10 s windows --------------------------------------------------------------
i0 = ((1 + nE) : nW : (numel(tg) - nW - nE + 1))';
n = numel(i0);
feat = zeros(n, 2); A = zeros(n, 1); degen = false(n, 1);
for w = 1:n
    idx = i0(w) + (0:nW-1);
    feat(w, :) = [std(accG(idx)), skewness(accG(idx))];
    [A(w), degen(w)] = ppgcb_cqi_area(am(idx), fs, o, model);
end

% --- motion cluster, CQI and reliability flag ---------------------------------
[k, q, r] = ppgcb_label_windows(feat, A, degen, model);

% --- cluster-based wavelet filtering with overlap-and-blend -------------------
y = ppgcb_assemble(x, i0, k, r, model.ETA, nW, nE, nX);

info = struct('t', tg, 'x', x, 'i0', i0, 'k', k, 'q', q, 'r', r, ...
              'A', A, 'degenerate', degen, 'features', feat);
end

function o = defaults(o)
d = struct('fs', 55, 'winLen', 10, 'extLen', 2, 'xfLen', 0.5, ...
           'welchWin', 256, 'nfft', 2048, 'ppgSign', 1);
f = fieldnames(d);
for i = 1:numel(f), if ~isfield(o, f{i}), o.(f{i}) = d.(f{i}); end, end
end
