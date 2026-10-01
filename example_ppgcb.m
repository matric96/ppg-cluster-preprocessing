%% Minimal example of the cluster-based PPG preprocessing
% Replace the SYNTHETIC signals below with a real recording (one continuous
% block). The synthetic signals only demonstrate the input format.
model = ppgcb_load_model();

fs = 55; T = 120; t = (0:1/fs:T)';
ppg = 1e5 + 2e3*sin(2*pi*1.2*t) + 5e3*sin(2*pi*0.05*t) + 300*randn(numel(t), 3);  % 3 channels
amb = 1e3 + 50*randn(numel(t), 1);
tAcc = (0:1/52:T)';
acc = [zeros(numel(tAcc), 2), 1000*ones(numel(tAcc), 1)] + 20*randn(numel(tAcc), 3); % mg

sig = struct('t', t, 'ppg', ppg, 'amb', amb, 'tAcc', tAcc, 'acc', acc);
[y, info] = ppgcb_preprocess(sig, model);

figure; plot(info.t, info.x - mean(info.x), 'Color', [0.6 0.6 0.6]); hold on;
plot(info.t, y, 'r'); xlabel('Time (s)'); ylabel('PPG (ADC counts)');
legend('Unfiltered (mean removed)', 'Cluster-based filter');
fprintf('Windows: %d | clusters: %s | low-reliability windows: %d\n', ...
    numel(info.k), mat2str(accumarray(info.k, 1, [3 1])'), sum(info.r == 0));
