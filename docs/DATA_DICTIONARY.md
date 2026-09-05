# Data dictionary

Generated directly from the shipped CSV files, so the columns, types and ranges below always match the data in this repository.


## `data/generated/{low,medium,high}_congestion_dataset.csv`

The three congestion-regime datasets share an identical schema; only the `scenario`, `qmax`, `queue`, `latency_ms` and derived-throughput values differ between them. Column ranges shown are for the High-congestion file.

**18,654 rows x 31 columns**


| Column | Type | Example / range | Description |
|---|---|---|---|
| `pair_id` | str | P000000a, P000000b, P000001a, P000001b ... | Identifier of the directed physical node pair this row describes. |
| `src_id` | str | V1, V2, V3, V4 ... | Source node id (V* = vehicle, U* = UAV relay). |
| `dst_id` | str | V2, V1, V3, V4 ... | Destination node id. |
| `comm_type` | str | V2V, V2U, U2V, U2U | Link category: V2V, V2U, U2V or U2U. |
| `src_type` | str | vehicle, uav | Source node type (vehicle / uav). |
| `dst_type` | str | vehicle, uav | Destination node type (vehicle / uav). |
| `distance_m` | float64 | 0.8711 to 587.4 | Euclidean 3-D distance between the two nodes, metres. |
| `rel_speed_mps` | float64 | 15.28 to 20.57 | Relative speed between the two nodes, m/s. |
| `src_alt_m` | float64 | 0 to 63.23 | Source altitude, metres (0 for ground vehicles). |
| `dst_alt_m` | float64 | 0 to 63.23 | Destination altitude, metres. |
| `link_source` | str | model_augmented_short_range, tihan_field_me... | Whether the row's channel values came from the field-fitted short-range model or the extrapolated regime. |
| `link_type` | str | RF, VLC | Radio technology of this candidate link: RF or VLC. |
| `rf_snr_db` | float64 | -999 to 56.2 | RF signal-to-noise ratio, dB. |
| `vlc_snr_db` | float64 | -999 to 94.96 | VLC signal-to-noise ratio, dB. |
| `blockage_prob` | float64 | 0 to 0.8317 | P_B(d), probability the VLC line of sight is blocked. 0 for RF. |
| `los_blocked` | int64 | 0 to 1 | Bernoulli draw from blockage_prob: 1 if line of sight is blocked. |
| `los_coeff` | float64 | 0 to 0.0001069 | Lambertian line-of-sight channel-gain coefficient. |
| `density` | float64 | 5.002 to 60 | Local vehicle density around the source node. |
| `doppler_hz` | float64 | 300.6 to 404.6 | Doppler shift implied by rel_speed_mps, Hz. |
| `intent` | str | Infotainment, Safety, Emergency, Telemetry | Traffic class assigned to this pair: Safety, Emergency, Infotainment or Telemetry. |
| `delay_budget_ms_obs` | float64 | 8.488 to 236.9 | Observed (noise-perturbed) delay budget for this intent. |
| `log_ber_budget_obs` | float64 | -6.169 to -2.804 | Observed log10 BER budget for this intent. |
| `tput_budget_mbps_obs` | float64 | 0.823 to 6.12 | Observed throughput budget for this intent. |
| `queue` | int64 | 3 to 48 | Queue occupancy in packets, round(rho * qmax). |
| `capacity_mbps` | float64 | 0.05651 to 63.09 | Physical-layer capacity ceiling of the link, Mbps. |
| `ber` | float64 | 0 to 1 | Bit-error rate of the link. |
| `outage_prob` | float64 | 0 to 1 | Probability the link is in outage. |
| `latency_ms` | float64 | 0.2043 to 3507 | Per-hop latency: propagation + transmission + queueing, ms. |
| `label` | int64 | 0 to 1 | Reliability label used to train the Stage 2 gate (1 = reliable). |
| `scenario` | str | High | Congestion regime this row belongs to: Low, Medium or High. |
| `qmax` | int64 | 50 to 50 | Queue capacity for that regime, packets. |

## `data/generated/node_positions.csv`

Static positions of the 100 vehicles and 3 UAV relays used for every scenario.

**103 rows x 5 columns**


| Column | Type | Example / range | Description |
|---|---|---|---|
| `node_id` | str | V1, V2, V3, V4 ... | Node identifier. |
| `type` | str | vehicle, uav | Node type: vehicle or uav. |
| `x` | float64 | 50.89 to 610.7 | Longitudinal position along the road corridor, metres. |
| `y` | float64 | -8.077 to 51.24 | Lateral position across the carriageway, metres. |
| `z` | float64 | 0 to 63.23 | Altitude, metres (0 for ground vehicles). |

## `data/generated/dataset_composition_summary.csv`

Row counts per scenario and intent, with the RF/VLC and reliable/unreliable split, for verifying dataset balance.

**12 rows x 8 columns**


| Column | Type | Example / range | Description |
|---|---|---|---|
| `scenario` | str | Low, Medium, High | Congestion regime this row belongs to: Low, Medium or High. |
| `intent` | str | Safety, Emergency, Infotainment, Telemetry | Traffic class assigned to this pair: Safety, Emergency, Infotainment or Telemetry. |
| `rows` | int64 | 4658 to 4669 |  |
| `rf` | int64 | 2370 to 2370 |  |
| `vlc` | int64 | 2288 to 2299 |  |
| `reliable` | int64 | 2425 to 3471 |  |
| `unreliable` | int64 | 1197 to 2233 |  |
| `short_range_augmented` | int64 | 2776 to 2846 |  |

## `data/generated/rf_pathloss_fit.json`

Coefficients of the two-segment breakpoint path-loss model fitted to the TIHAN field measurements. Segment A (<= 250 m) is the only segment used to generate data; Segment B is reported for coverage context only.


| Key | Value |
|---|---|
| `PL0` | 107.88174961671604 |
| `slope` | 20.000000000907693 |
| `n_exponent` | 2.000000000090769 |
| `r2_short_range_holdout` | 1.0 |
| `r2_short_range_full_fit` | 1.0 |
| `resid_std_short_db` | 2.882429043609195e-08 |
| `breakpoint_m` | 250.0 |
| `pl_at_breakpoint` | 155.84054979233338 |
| `slope_beyond_breakpoint` | 32.19095311574622 |
| `n_exponent_beyond_breakpoint` | 3.219095311574622 |
| `r2_beyond_breakpoint` | 0.05295118749000971 |
| `speed_mean_kmh` | 64.960739631706 |
| `speed_std_kmh` | 2.8903978449446748 |
| `n_field_rows` | 10252 |
| `n_field_rows_short_range` | 1773 |

## `data/raw/FinalV2V_Dataset.csv`

Third-party C-V2X field measurements. See `data/raw/README.md` for provenance and licensing before reusing.

**10,252 rows x 34 columns**


Columns: `Time_Epoch`, `transmitted_latitude (deg)`, `transmitted_longitude (deg)`, `transmitted_heading (deg)`, `transmitted_speed (km/hr)`, `transmitted_altitude (m)`, `latitude_self (deg)`, `longitude_self (deg)`, `Self_speed (km/hr)`, `Self_heading (degrees)`, `Self_Altitude (m)`, `distance (m)`, `latency (ms)`, `throughput (bits/sec)`, `data_size (kb)`, `Packet_Error_Rate`, `Transmission_Time (ms)`, `Transmission_Frequency (Hz)`, `Configuration`, `Channel`, `Bandwidth`, `Modulation`, `Tx/Rx Configuration`, `Device Details`, `Tx Power (dB)`, `Receiver Gain (dB)`, `Path_Loss (dB)`, `ERP (dBm)`, `Rx_Power (dBm)`, `Noise_Power (dBm)`, `SNR (dB)`, `scenario`, `RSSI_antenna1 (dBm)`, `RSSI_antenna2 (dBm)`


Only two columns are consumed by the pipeline: `distance (m)` and `Path_Loss (dB)`, which are fitted to produce `rf_pathloss_fit.json`.
