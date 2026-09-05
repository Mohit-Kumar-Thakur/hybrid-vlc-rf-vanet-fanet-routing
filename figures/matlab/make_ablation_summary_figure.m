%% make_ablation_summary_figure.m
%  Ablation performance on each intent's own binding metric, High congestion.
%  Output basename matches the \includegraphics path in manuscript_v2/main.tex:
%
%      fig05_ablation_summary           (Fig. 9 in the manuscript)
%
%  Four panels, one per intent, three bars each (the ablation configurations). Each
%  panel plots the metric that intent actually binds on: delay for Safety and Emergency,
%  throughput for Infotainment, BER for Telemetry. Telemetry uses a log y-axis because
%  its three values span roughly an order of magnitude.
%
%  DATA PROVENANCE
%  Exact means from ablation_raw[('High', cfg)] in the routing notebook, successful
%  routes only. NOTE these use the UNRESTRICTED sampling condition, which is what this
%  summary figure uses -- it differs from the per-intent charts in
%  make_ablation_figures.m, where Safety and Emergency use range-realistic sampling.
%  That is why, e.g., Safety/AHP-only reads 2.837 here but 2.889 there.

clear; clc; close all;

configs = {'AHP-only', 'ML-reliability-only', 'Complete-Proposed'};

panels = struct( ...
    'intent', {'Safety', 'Emergency', 'Infotainment', 'Telemetry'}, ...
    'values', {[2.83685, 5.08651, 3.58902], ...
               [3.37967, 7.80544, 3.72430], ...
               [16.1302, 3.25512, 15.6707], ...
               [1.61283e-06, 9.42499e-06, 3.18968e-06]}, ...
    'ylabel', {'End-to-end Delay (ms)', 'End-to-end Delay (ms)', ...
               'Throughput (Mbps)', 'End-to-end BER'}, ...
    'logScale', {false, false, false, true}, ...
    'fmt', {'%.2f', '%.2f', '%.2f', '%.2e'});

% Same three ablation hues used in the per-intent charts, so the two figures read as
% one family.
colors = [ ...
    1.00 0.82 0.30; ...   % AHP-only            -- bright gold
    0.35 0.82 0.65; ...   % ML-reliability-only -- bright teal-green
    0.40 0.68 0.98];      % Complete-Proposed   -- bright sky blue

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [60 60 1500 430]);

for p = 1:numel(panels)
    ax = subplot(1, 4, p, 'Parent', fig);
    axes(ax);                                     %#ok<LAXES>
    hold(ax, 'on');

    v = panels(p).values;

    % One bar at a time so each gets its own colour (a single bar() call with a vector
    % produces one series and therefore one colour).
    for k = 1:numel(v)
        bar(k, v(k), 0.62, 'FaceColor', colors(k, :), ...
            'EdgeColor', [0.15 0.15 0.15], 'LineWidth', 0.7);
    end

    % Headroom for the labels, reserved before they are drawn.
    if panels(p).logScale
        set(ax, 'YScale', 'log', 'YLim', [min(v)/2.2, max(v)*2.6]);
    else
        set(ax, 'YLim', [0, max(v) * 1.20]);
    end

    for k = 1:numel(v)
        if panels(p).logScale
            yl = v(k) * 1.12;
        else
            yl = v(k) + max(v) * 0.02;
        end
        text(k, yl, sprintf(panels(p).fmt, v(k)), 'Parent', ax, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.10 0.10 0.10]);
    end

    set(ax, 'XTick', 1:numel(v), 'XTickLabel', configs, ...
            'XLim', [0.4, numel(v) + 0.6], ...
            'FontSize', 9.5, 'LineWidth', 1.0, 'Box', 'off', ...
            'TickDir', 'out', 'YGrid', 'on', 'Layer', 'top');
    if isprop(ax, 'GridAlpha'),        set(ax, 'GridAlpha', 0.15);        end
    if isprop(ax, 'XTickLabelRotation'), set(ax, 'XTickLabelRotation', 20); end

    ylabel(ax, panels(p).ylabel, 'FontSize', 10.5);
    title(ax, panels(p).intent, 'FontSize', 12, 'FontWeight', 'bold');
    hold(ax, 'off');
end

% Figure-level title (sgtitle needs R2018b; fall back to a plain annotation).
ttl = 'Ablation performance on each intent''s binding metric - High congestion';
if exist('sgtitle', 'file') == 2
    sgtitle(ttl, 'FontSize', 13, 'FontWeight', 'bold');
else
    annotation(fig, 'textbox', [0 0.94 1 0.06], 'String', ttl, ...
        'HorizontalAlignment', 'center', 'EdgeColor', 'none', ...
        'FontSize', 13, 'FontWeight', 'bold');
end

outFile = 'fig05_ablation_summary';
if exist('exportgraphics', 'file') == 2 || exist('exportgraphics', 'builtin') == 5
    exportgraphics(fig, [outFile '.png'], 'Resolution', 600);
    exportgraphics(fig, [outFile '.pdf'], 'ContentType', 'vector');
else
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, [outFile '.png'], '-dpng', '-r600');
    print(fig, [outFile '.pdf'], '-dpdf', '-painters');
end
fprintf('wrote %s.png and %s.pdf\n', outFile, outFile);
