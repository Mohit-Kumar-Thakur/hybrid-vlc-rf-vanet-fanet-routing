%% make_ahp_weights_figure.m
%  AHP-derived utility weights by intent -- the coefficients w_c of Eq. (10).
%  Output basename matches the \includegraphics path in manuscript_v2/main.tex:
%
%      fig14_ahp_weights                (Fig. 3 in the manuscript, Section 4.4)
%
%  Grouped by criterion, one coloured series per intent. Each intent's six weights sum
%  to 1, so a bar's height is the share of the ranking decision that criterion controls
%  for that intent.
%
%  DATA PROVENANCE
%  Exact outputs of the notebook's AHP eigenvector derivation (Algorithm 1), not values
%  read off the previous matplotlib figure. Each row is asserted to sum to 1 below.

clear; clc; close all;

criteria = {'Delay', 'Throughput', 'BER', 'Outage', 'Blockage', 'Progress'};
intents  = {'Safety', 'Emergency', 'Infotainment', 'Telemetry'};

% rows = intents, columns = criteria
W = [ ...
    0.1896, 0.0320, 0.2978, 0.1515, 0.2611, 0.0679;   % Safety
    0.1877, 0.0364, 0.2975, 0.1487, 0.2604, 0.0692;   % Emergency
    0.1013, 0.5170, 0.0541, 0.0883, 0.0614, 0.1779;   % Infotainment
    0.0621, 0.0531, 0.4373, 0.1417, 0.2538, 0.0521];  % Telemetry

% Each intent's weights must sum to 1 (AHP normalises the principal eigenvector).
rowSums = sum(W, 2);
if any(abs(rowSums - 1) > 5e-3)
    error('make_ahp_weights_figure:badWeights', ...
          'AHP weights must sum to 1 per intent; got %s.', mat2str(rowSums', 4));
end

% Bars are grouped BY CRITERION, so transpose: rows = criteria, cols = intents.
data = W.';

% Light, bright, hue-separated palette -- one distinct hue per intent.
colors = [ ...
    1.00 0.55 0.35; ...   % Safety       -- bright coral/orange
    0.68 0.55 0.92; ...   % Emergency    -- bright violet
    0.40 0.68 0.98; ...   % Infotainment -- bright sky blue
    0.35 0.82 0.65];      % Telemetry    -- bright teal-green

nGroups = size(data, 1);
nSeries = size(data, 2);

% Wide canvas: Safety and Emergency weights are nearly identical by design (they differ
% only in throughput and progress), so their two labels sit adjacent and collide at a
% narrower figure width.
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100 100 1400 580]);
ax  = axes('Parent', fig);
axes(ax);                 %#ok<LAXES>
hold(ax, 'on');

b = bar(data);            % matrix input defaults to grouped
for k = 1:nSeries
    set(b(k), 'FaceColor', colors(k, :), ...
              'EdgeColor', [0.15 0.15 0.15], ...
              'LineWidth', 0.7, ...
              'BarWidth',  0.88);
end

set(ax, 'YLim', [0, max(data(:)) * 1.18]);

% bar centre x-positions (XEndPoints is R2019b+)
xc = zeros(nGroups, nSeries);
for k = 1:nSeries
    if isprop(b(k), 'XEndPoints')
        xc(:, k) = b(k).XEndPoints(:);
    elseif isprop(b(k), 'XOffset')
        xc(:, k) = (1:nGroups)' + b(k).XOffset;
    else
        w = 0.88 / nSeries;
        xc(:, k) = (1:nGroups)' - 0.44 + w * (k - 0.5);
    end
end

for k = 1:nSeries
    for j = 1:nGroups
        text(xc(j, k), data(j, k) + max(data(:)) * 0.012, ...
            sprintf('%.3f', data(j, k)), 'Parent', ax, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontSize', 7.5, 'FontWeight', 'bold', 'Color', [0.10 0.10 0.10]);
    end
end

set(ax, 'XTick', 1:nGroups, 'XTickLabel', criteria, ...
        'FontSize', 11, 'LineWidth', 1.0, 'Box', 'off', ...
        'TickDir', 'out', 'YGrid', 'on', 'Layer', 'top');
if isprop(ax, 'GridAlpha'), set(ax, 'GridAlpha', 0.15); end

ylabel(ax, 'AHP weight', 'FontSize', 12);
title(ax, 'AHP-derived utility weights by intent: how the criteria separate across intents', ...
      'FontSize', 13, 'FontWeight', 'bold');

lgd = legend(b, intents, 'Location', 'northoutside', 'FontSize', 10);
set(lgd, 'Box', 'on');
if isprop(lgd, 'NumColumns'),    set(lgd, 'NumColumns', 4);         end
if isprop(lgd, 'ItemTokenSize'), set(lgd, 'ItemTokenSize', [16 10]); end

hold(ax, 'off');

outFile = 'fig14_ahp_weights';
if exist('exportgraphics', 'file') == 2 || exist('exportgraphics', 'builtin') == 5
    exportgraphics(fig, [outFile '.png'], 'Resolution', 600);
    exportgraphics(fig, [outFile '.pdf'], 'ContentType', 'vector');
else
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, [outFile '.png'], '-dpng', '-r600');
    print(fig, [outFile '.pdf'], '-dpdf', '-painters');
end
fprintf('wrote %s.png and %s.pdf\n', outFile, outFile);
