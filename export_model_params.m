%% Export the trained parameters from trained_model.mat (validation script)
% to ppgcb_model.mat and a human-readable ppgcb_model.json for the repository.
src = 'trained_model.mat';                 % output of ppg_cluster_filter_train_test.m
S = load(src); m = S.model; cfg = S.cfg;
model = struct('C', m.C, 'fMin', m.fMin, 'fMax', m.fMax, 'Lmin', m.Lmin, ...
    'Lmax', m.Lmax, 'Tq', m.Tq, 'ETA', m.ETA, ...
    'epsA', cfg.epsA, 'epsV', cfg.epsV, 'rSat', cfg.rSat);
save('ppgcb_model.mat', 'model');
fid = fopen('ppgcb_model.json', 'w'); fprintf(fid, '%s', jsonencode(model, 'PrettyPrint', true)); fclose(fid);
disp(model)
