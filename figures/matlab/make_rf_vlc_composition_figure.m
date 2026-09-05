%% make_rf_vlc_composition_figure.m
%  RF/VLC hop-technology composition of the proposed framework's own chosen routes,
%  by intent, High congestion.
%  Output basename matches the \includegraphics path in manuscript_v2/main.tex:
%
%      fig08_rf_vlc_composition         (Fig. 8 in the manuscript)
%
%  Stacked bars summing to 1: the share of hops on each technology, per intent. The
%  point of the figure is that the split is intent-dependent rather than fixed --
%  Safety, Emergency and Telemetry stay predominantly RF, while Infotainment is
%  overwhelmingly VLC.
%
%  DATA PROVENANCE
%  Exact hop counts from the notebook's tech_df for the High scenario. Shares are
%  computed from those counts here rather than hard-coded, so the two always agree.

clear; clc; close all;

intents = {'Safety', 'Emergency', 'Infotainment', 'Telemetry'};

% Absolute hop counts actually routed by the proposed framework (High congestion).
rfHops  = [48, 50,  13, 55];
vlcHops = [ 6,  6, 118,  8];

total    = rfHops + vlcHops;
rfShare  = rfHops  ./ total;
vlcShare = vlcHops ./ total;

data = [rfShare(:), vlcShare(:)];     % rows = intents, cols = [RF VLC]

% Two clearly distinct hues; RF warm, VLC cool.
colors = [ ...
    1.00 0.55 0.35; ...   % RF  -- bright coral/orange
    0.40 0.68 0.98];      % VLC -- bright sky blue

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100 100 900 520]);
ax  = axes('Parent', fig);
axes(ax);                 %#ok<LAXES>
hold(ax, 'on');

b = bar(data, 'stacked');
for k = 1:numel(b)
    set(b(k), 'FaceColor', colors(k, :), ...
              'EdgeColor', [0.15 0.15 0.15], ...
              'LineWidth', 0.7, ...
              'BarWidth',  0.62);
end

set(ax, 'YLim', [0, 1.12]);

% ---- in-segment labels --------------------------------------------------
% Percentage and raw hop count are printed inside each segment, centred. A segment
% shorter than 8% of the bar has no room for two lines of text, so its label is placed
% just outside the bar instead of being squeezed illegibly inside it.
for i = 1:numel(intents)
    segTop = 0;
    for k = 1:2
        if k == 1
            frac = rfShare(i);  cnt = rfHops(i);   name = 'RF';
        else
            frac = vlcShare(i); cnt = vlcHops(i);  name = 'VLC';
        end
        segBottom = segTop;
        segTop    = segTop + frac;
        label = sprintf('%s  %.1f%%\\newline(%d hops)', name, 100*frac, cnt);
        if frac >= 0.08
            text(i, (segBottom + segTop)/2, label, 'Parent', ax, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.10 0.10 0.10]);
        else
            text(i + 0.40, (segBottom + segTop)/2, label, 'Parent', ax, ...
                'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
                'FontSize', 8.5, 'FontWeight', 'bold', 'Color', [0.25 0.25 0.25]);
        end
    end
end

set(ax, 'XTick', 1:numel(intents), 'XTickLabel', intents, ...
        'XLim', [0.4, numel(intents) + 0.75], ...
        'FontSize', 11, 'LineWidth', 1.0, 'Box', 'off', ...
        'TickDir', 'out', 'YGrid', 'on', 'Layer', 'top');
if isprop(ax, 'GridAlpha'), set(ax, 'GridAlpha', 0.15); end

ylabel(ax, 'Share of hops', 'FontSize', 12);
title(ax, 'RF/VLC hop-technology composition - High congestion', ...
      'FontSize', 13, 'FontWeight', 'bold');

lgd = legend(b, {'RF', 'VLC'}, 'Location', 'northoutside', 'FontSize', 10);
set(lgd, 'Box', 'on');
if isprop(lgd, 'NumColumns'), set(lgd, 'NumColumns', 2); end

hold(ax, 'off');

outFile = 'fig08_rf_vlc_composition';
if exist('exportgraphics', 'file') == 2 || exist('exportgraphics', 'builtin') == 5
    exportgraphics(fig, [outFile '.png'], 'Resolution', 600);
    exportgraphics(fig, [outFile '.pdf'], 'ContentType', 'vector');
else
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, [outFile '.png'], '-dpng', '-r600');
    print(fig, [outFile '.pdf'], '-dpdf', '-painters');
end
fprintf('wrote %s.png and %s.pdf\n', outFile, outFile);
