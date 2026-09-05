# Hierarchical Intent-Aware Routing for Hybrid VLC/RF VANET–FANET Networks

Code and datasets for a cascaded, intent-aware routing framework for vehicular networks
that combine radio-frequency (RF) and visible light communication (VLC) links with
unmanned aerial vehicle (UAV) relays.

This repository is the reproducibility package for the accompanying manuscript. It
contains everything needed to regenerate the datasets, retrain the models, reproduce
every reported number, and rebuild the figures.

---

## What the framework does

Each routing request is resolved in three cascaded stages:

1. **Intent classification.** A multilayer perceptron labels the request as one of four
   traffic classes — Safety, Emergency, Infotainment or Telemetry — each with its own
   delay, bit-error-rate and throughput budget.
2. **Reliability gating.** One of four per-intent MLPs predicts whether each candidate
   RF or VLC link will stay reliable. A separate hard constraint drops any VLC link
   whose blockage probability exceeds an intent-specific threshold.
3. **Multi-criteria ranking.** Surviving links are scored by a weighted utility function
   over six criteria (delay, throughput, BER, outage, blockage, progress). The weights
   are derived per intent by the Analytic Hierarchy Process, so the ranking stays
   traceable to an explicit priority judgement rather than to learned parameters.

Routing then reduces to a single Dijkstra search over the utility-weighted candidate
graph. The framework is evaluated against AODV (reactive) and DSDV (proactive) baselines
across three congestion regimes.

---

## Repository layout

```
notebooks/
  01_tihan_extended_dataset_generation.ipynb   builds the three congestion datasets
  02_hybrid_routing_framework.ipynb            models, routing, evaluation, ablations
data/
  raw/        third-party C-V2X field measurements (see data/raw/README.md first)
  generated/  the three congestion-regime datasets and supporting files
figures/
  matlab/     MATLAB scripts that regenerate the manuscript figures
docs/
  DATA_DICTIONARY.md   every column of every shipped file, generated from the data
```

---

## Reproducing the results

Requires Python 3.10+.

```bash
pip install -r requirements.txt
jupyter lab
```

Run `notebooks/01_...` first if you want to rebuild the datasets from scratch; otherwise
the generated datasets in `data/generated/` are already the ones used in the paper, and
`notebooks/02_...` can be run directly.

The second notebook trains both model stages, runs the routing evaluation for all three
congestion regimes, and produces the ablation and sensitivity analyses. A full run takes
roughly 20–45 minutes depending on hardware.

### Reproducibility note

All random draws are seeded. One caveat worth knowing if you compare against an older
copy of this code: the DSDV staleness model originally seeded its generator from Python's
built-in `hash()` of the scenario name. Python salts string hashing per process, so DSDV
selected different stale links — and reported different numbers — on every kernel
restart. This is fixed; the seed now derives from a CRC32 of the scenario name, which is
stable across processes. Aggregate results were re-verified after the fix and were
unchanged, but individual DSDV paths differ from pre-fix runs.

---

## Figures

`figures/matlab/` regenerates the manuscript's bar-chart figures at publication
resolution (600 dpi PNG plus vector PDF). Each script is standalone — open MATLAB, set
the working directory to `figures/matlab/`, and run it.

| Script | Produces |
|---|---|
| `make_ahp_weights_figure.m` | AHP-derived utility weights by intent |
| `make_boxplot_figure.m` | delay / throughput spread by method |
| `make_rf_vlc_composition_figure.m` | RF vs VLC hop composition by intent |
| `make_ablation_summary_figure.m` | ablation on each intent's binding metric |
| `make_ablation_figures.m` | the four per-intent ablation comparisons |

`plot_ablation_group.m` is a shared helper, not a script to run directly. The data values
embedded in these scripts are the exact means computed by notebook 02, not values read
off earlier plots.

---

## Data

- **`data/generated/`** — the three congestion-regime datasets (18,654 rows each),
  node positions, the fitted path-loss coefficients, and a composition summary. These
  are the exact files behind every result in the paper.
- **`data/raw/`** — third-party C-V2X field measurements used to fit the RF path-loss
  model. **Read `data/raw/README.md` before reusing or redistributing this file.**

`docs/DATA_DICTIONARY.md` documents every column, generated directly from the shipped
files so it cannot drift from the data.

---

## Licence

- **Code** (notebooks, MATLAB scripts): MIT, see `LICENSE`.
- **Generated datasets** (`data/generated/`): CC BY 4.0, see `LICENSE-DATA`.
- **`data/raw/FinalV2V_Dataset.csv`**: third-party, **not** covered by either licence
  above. See `data/raw/README.md`.

## Citing

If you use this code or data, please cite the accompanying paper. The raw field
measurements should be cited separately at their own DOI — see `data/raw/README.md`.
