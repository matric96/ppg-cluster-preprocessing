# Cluster-based PPG preprocessing with an ambient-light Contact Quality Index

MATLAB implementation of the preprocessing method described in:

> Ricci, M.; Suárez, D.; Bertomeu-González, V.; Martínez-Rodrigo, A.; Alcaraz, R.; Rieta, J.J.
> *A Novel Cluster-Based Approach for PPG Signal Preprocessing: Motion Artifact Filtering and
> Ambient Light Correction.* Sensors 2026 (in revision).

The method combines (i) accelerometer-derived motion-state clustering, (ii) a heuristic
Contact Quality Index (CQI) computed from the ambient-light channel, and (iii) a cluster-based
Symlet 4 wavelet filter whose thresholds depend on the motion state and on the CQI-based
reliability flag.

## Requirements

MATLAB with the Signal Processing, Statistics and Machine Learning, and Wavelet toolboxes.

## Files

| File | Content |
|---|---|
| `ppgcb_preprocess.m` | Main function: from raw PPG, accelerometer and ambient-light samples to the filtered PPG and the per-window labels |
| `ppgcb_label_windows.m` | Motion cluster (nearest trained centroid), CQI and reliability flag |
| `ppgcb_cqi_area.m` | Area under the ambient-light PSD and degenerate-case check |
| `ppgcb_wavelet_filter.m` | Five-level sym4 DWT filter (A5 removed, D1–D3 soft-thresholded, D4–D5 preserved) |
| `ppgcb_assemble.m` | Window extension (2 s), filtering and overlap-and-blend (1 s) |
| `ppgcb_load_model.m` | Loads the trained parameters |
| `ppgcb_model.mat`, `ppgcb_model.json` | Trained parameters (Table 7 of the paper) |
| `example_ppgcb.m` | Minimal example showing the input format |
| `export_model_params.m` | Script used to export the parameters from the training run |

## Usage

```matlab
model = ppgcb_load_model();
sig = struct('t', t, 'ppg', ppg, 'amb', amb, 'tAcc', tAcc, 'acc', acc);
[y, info] = ppgcb_preprocess(sig, model);
```

* `t`, `ppg`, `amb`: PPG/ambient-light time stamps (s), PPG samples (N x 1 or N x 3 channels,
  which are averaged), and ambient-light samples.
* `tAcc`, `acc`: accelerometer time stamps (s) and tri-axial samples in mg.
* The input must be one continuous block: split recordings at gaps longer than 1 s.
* Signals are resampled to a 55 Hz grid; 10 s windows closer than 2 s to the block edges are
  not analyzed, and `y` is NaN there.
* `info` contains, for each window, the motion cluster `k` (1 = rest/low motion,
  2 = moderate, 3 = dynamic motion), the CQI `q`, and the reliability flag `r`.

## Notes on the parameters

The parameters were estimated on eight training participants recorded with a Polar Verity
Sense worn on the forearm (PPG and ambient light at 55 Hz, raw digital units). They are
device-specific and should be re-estimated or validated before applying the method to other
devices, placements or populations. The CQI is a heuristic indicator of ambient-light-related
optical reliability and has not been validated against independent contact-quality measurements.

The clinical recordings used in the study are not included for ethical and privacy reasons;
they are available from the corresponding author upon reasonable request.

## License

MIT License (see `LICENSE`).
