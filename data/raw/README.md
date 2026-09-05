# Raw field measurements — provenance and licensing

## `FinalV2V_Dataset.csv`

Cellular V2X (C-V2X) field measurements collected on the TIHAN testbed (Technology
Innovation Hub on Autonomous Navigation, IIT Hyderabad).

- **Rows:** 10,252 field measurements
- **Published at:** IEEE DataPort
- **DOI:** [10.21227/f2kd-9g03](https://doi.org/10.21227/f2kd-9g03)

## How this project uses it

Only two columns are consumed by the pipeline: `distance (m)` and `Path_Loss (dB)`.
These are fitted with a two-segment breakpoint log-distance model, whose coefficients are
stored in `data/generated/rf_pathloss_fit.json`. Only the near-range segment
(≤ 250 m, holdout R² = 1.00) is used to generate data; the far-range segment fits poorly
(R² = 0.053) because beyond 250 m the field-test scenario identity explains more of the
variation than distance does, so it is reported for context only and never used
generatively.

The file also contains GPS coordinates, headings and speeds from the test runs. None of
these are used by this project's pipeline.

## Licensing — please read before reuse

**This file is third-party data. It is not covered by this repository's MIT (code) or
CC BY 4.0 (generated data) licences.** Those licences apply only to material originating
in this project.

If you intend to reuse or redistribute `FinalV2V_Dataset.csv`, check the licence terms
attached to the dataset at its IEEE DataPort DOI above and comply with them. If you only
need the RF propagation behaviour, `data/generated/rf_pathloss_fit.json` carries the
fitted coefficients and is sufficient to reproduce every result in this project without
touching the raw file.

Cite the dataset at its own DOI, separately from this repository and from the paper.
