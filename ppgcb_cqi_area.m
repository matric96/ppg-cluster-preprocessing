function [A, degen] = ppgcb_cqi_area(aw, fs, o, model)
%PPGCB_CQI_AREA  Area under the Welch PSD of one ambient-light window and
%   degenerate-case check (flat, saturated or disconnected signal).
aw = aw(:);
[P, f] = pwelch(aw - mean(aw), hamming(o.welchWin), round(o.welchWin/2), o.nfft, fs);
A = trapz(f, P);
degen = A < model.epsA || var(aw) < model.epsV || mean(aw >= max(aw)) > model.rSat;
end
