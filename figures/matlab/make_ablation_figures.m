%% make_ablation_figures.m
%  Regenerates the four per-intent ablation figures used in the manuscript.
%  Output basenames match the \includegraphics paths in manuscript_v2/main.tex:
%
%      fig04a_safety_delay              (Fig. 9  in the manuscript)
%      fig04b_emergency_delay           (Fig. 10)
%      fig04c_infotainment_throughput   (Fig. 11)
%      fig04d_telemetry_ber             (Fig. 12)
%
%  Each writes a 600 dpi PNG and a vector PDF. Copy the PNGs into
%  manuscript_v2/figures/ to replace the matplotlib versions; the LaTeX needs no edit
%  because the names are unchanged. (To use the vector PDFs instead, change the four
%  \includegraphics extensions from .png to .pdf -- LaTeX accepts both.)
%
%  DATA PROVENANCE
%  These are the exact group means computed by the routing notebook, extracted directly
%  from its evaluation dataframes rather than read off the previous matplotlib figures.
%  Safety and Emergency use the range-realistic sampling condition; Infotainment and
%  Telemetry use the unrestricted one, matching _category_mean() in the notebook.
%  Values are given to 5-6 significant figures; the plots display 1 decimal (or 1
%  significant figure with an exponent, for BER).
%
%  Column order in every matrix is the legend order:
%      AODV | DSDV | AHP-only | ML-reliability-only | Complete-Proposed
%  Row order is Low (Qmax=20) | Medium (Qmax=40) | High (Qmax=50).

clear; clc; close all;

%% -------------------------------------------------- Fig 9: Safety delay --
% Mean end-to-end delay (ms), range-realistic sampling.
safety = [ ...
     7.68804,  7.48803,  1.78966,  3.43248,  3.02660;   % Low
     8.51707,  8.05579,  2.06930,  4.32522,  3.43509;   % Medium
    14.26900, 15.62710,  2.88864,  4.66529,  3.93586];  % High

plot_ablation_group(safety, ...
    'End-to-end Delay (ms)', ...
    'Safety - end-to-end delay: baselines vs. ablation mechanisms', ...
    'fig04a_safety_delay');

%% ---------------------------------------------- Fig 10: Emergency delay --
% Mean end-to-end delay (ms), range-realistic sampling.
emergency = [ ...
     7.54872,  7.02526,  1.85154,  3.36983,  2.70821;   % Low
     8.22686,  7.47434,  2.10417,  4.20504,  3.19021;   % Medium
    12.44170, 13.21890,  3.38942,  7.22390,  3.99813];  % High

plot_ablation_group(emergency, ...
    'End-to-end Delay (ms)', ...
    'Emergency - end-to-end delay: baselines vs. ablation mechanisms', ...
    'fig04b_emergency_delay');

%% ---------------------------------------- Fig 11: Infotainment throughput --
% Mean bottleneck throughput (Mbps), unrestricted sampling.
infotainment = [ ...
    5.05530, 4.81897, 18.2654, 5.06557, 17.0766;   % Low
    4.24357, 4.20247, 16.2760, 4.22816, 16.6163;   % Medium
    3.31677, 3.44418, 16.1302, 3.25512, 15.6707];  % High

plot_ablation_group(infotainment, ...
    'Throughput (Mbps)', ...
    'Infotainment - throughput: baselines vs. ablation mechanisms', ...
    'fig04c_infotainment_throughput', ...
    struct('legendLoc', 'northoutside'));   % keeps the legend clear of the tall bars

%% ------------------------------------------------ Fig 12: Telemetry BER --
% Mean end-to-end bit-error rate, unrestricted sampling. Log y-axis.
% AODV is identical across all three scenarios because its routes are chosen on hop
% count over the RF-only graph, which congestion does not alter -- congestion changes
% delay and achieved throughput, not the RF topology AODV searches.
telemetry = [ ...
    2.08334e-05, 2.88674e-05, 1.85819e-06, 6.76416e-06, 3.63197e-06;   % Low
    2.08334e-05, 1.19793e-05, 1.76878e-06, 6.76416e-06, 3.47412e-06;   % Medium
    2.08334e-05, 3.08001e-05, 1.61283e-06, 9.42499e-06, 3.18968e-06];  % High

plot_ablation_group(telemetry, ...
    'End-to-end BER', ...
    'Telemetry - BER: baselines vs. ablation mechanisms', ...
    'fig04d_telemetry_ber', ...
    struct('logScale', true, 'valueFmt', '%.1e', 'legendLoc', 'northoutside'));

fprintf('\nAll four figures written to %s\n', pwd);
