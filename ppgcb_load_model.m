function model = ppgcb_load_model(file)
%PPGCB_LOAD_MODEL  Loads the trained parameters (default: ppgcb_model.mat).
%   Fields: C (3x2 centroids, normalized SD-skewness), fMin, fMax (1x2),
%   Lmin, Lmax, Tq, ETA (2x3; row 1: r = 0, row 2: r = 1; columns: clusters),
%   epsA, epsV, rSat.
if nargin < 1, file = fullfile(fileparts(mfilename('fullpath')), 'ppgcb_model.mat'); end
S = load(file); model = S.model;
end
