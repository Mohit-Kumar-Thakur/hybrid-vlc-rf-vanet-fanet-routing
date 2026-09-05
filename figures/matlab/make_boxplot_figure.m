%% make_boxplot_figure.m
%  End-to-end delay and bottleneck throughput spread by method, High congestion.
%  Output basename matches the \includegraphics path in manuscript_v2/main.tex:
%
%      fig07_boxplot_distribution       (Fig. 7 in the manuscript)
%
%  Two panels: delay on the left, throughput on the right. Three boxes each, one per
%  routing method, over all successful routes.
%
%  DATA
%  Reads boxplot_high.csv (long format: method,metric,value), which holds the raw
%  per-route values exported from the notebook -- 160 successful routes per method per
%  metric. A box plot summarises a distribution, so it needs the full sample rather
%  than precomputed quartiles.
%
%  The boxes are drawn explicitly rather than with boxplot() or boxchart(): boxplot()
%  requires the Statistics and Machine Learning Toolbox and boxchart() requires R2020b,
%  and neither is needed for a standard Tukey box. Whiskers extend to the most extreme
%  point within 1.5*IQR of the quartiles; points beyond that are drawn individually.

clear; clc; close all;

csvFile = 'boxplot_high.csv';
if exist(csvFile, 'file') ~= 2
    error('make_boxplot_figure:missingData', ...
          ['Cannot find %s in %s.\nIt is exported alongside these scripts; copy it ' ...
           'into the same folder as this file.'], csvFile, pwd);
end
T = readtable(csvFile);

methods = {'AODV', 'DSDV', 'Proposed'};
colors  = [ ...
    1.00 0.55 0.35; ...   % AODV     -- bright coral/orange
    0.68 0.55 0.92; ...   % DSDV     -- bright violet
    0.40 0.68 0.98];      % Proposed -- bright sky blue

panels = struct( ...
    'metric', {'delay_ms', 'throughput_mbps'}, ...
    'ylabel', {'End-to-end delay (ms)', 'Bottleneck throughput (Mbps)'}, ...
    'title',  {'End-to-end delay distribution', 'Throughput distribution'});

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [80 80 1150 520]);

for p = 1:numel(panels)
    ax = subplot(1, 2, p, 'Parent', fig);
    axes(ax);                                    %#ok<LAXES>
    hold(ax, 'on');

    allVals = [];
    for k = 1:numel(methods)
        v = T.value(strcmp(T.method, methods{k}) & strcmp(T.metric, panels(p).metric));
        v = v(isfinite(v));
        allVals = [allVals; v];                  %#ok<AGROW>
        draw_box(ax, k, v, colors(k, :));
    end

    pad = 0.08 * (max(allVals) - min(allVals));
    set(ax, 'XTick', 1:numel(methods), 'XTickLabel', methods, ...
            'XLim', [0.4, numel(methods) + 0.6], ...
            'YLim', [min(allVals) - pad, max(allVals) + pad], ...
            'FontSize', 11, 'LineWidth', 1.0, 'Box', 'off', ...
            'TickDir', 'out', 'YGrid', 'on', 'Layer', 'top');
    if isprop(ax, 'GridAlpha'), set(ax, 'GridAlpha', 0.15); end

    ylabel(ax, panels(p).ylabel, 'FontSize', 12);
    title(ax, panels(p).title, 'FontSize', 12, 'FontWeight', 'bold');
    hold(ax, 'off');
end

ttl = 'End-to-end delay and throughput spread by method - High congestion (Qmax=50)';
if exist('sgtitle', 'file') == 2
    sgtitle(ttl, 'FontSize', 13, 'FontWeight', 'bold');
else
    annotation(fig, 'textbox', [0 0.94 1 0.06], 'String', ttl, ...
        'HorizontalAlignment', 'center', 'EdgeColor', 'none', ...
        'FontSize', 13, 'FontWeight', 'bold');
end

outFile = 'fig07_boxplot_distribution';
if exist('exportgraphics', 'file') == 2 || exist('exportgraphics', 'builtin') == 5
    exportgraphics(fig, [outFile '.png'], 'Resolution', 600);
    exportgraphics(fig, [outFile '.pdf'], 'ContentType', 'vector');
else
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, [outFile '.png'], '-dpng', '-r600');
    print(fig, [outFile '.pdf'], '-dpdf', '-painters');
end
fprintf('wrote %s.png and %s.pdf\n', outFile, outFile);


%% ------------------------------------------------------------------ helper --
function draw_box(ax, xc, v, faceColor)
%DRAW_BOX  Standard Tukey box plot for one group, drawn from primitives.
    w  = 0.55;                       % box width
    q1 = prctile_local(v, 25);
    q2 = prctile_local(v, 50);
    q3 = prctile_local(v, 75);
    iqr = q3 - q1;

    % whiskers: most extreme observations still within 1.5*IQR of the quartiles
    loFence = q1 - 1.5 * iqr;
    hiFence = q3 + 1.5 * iqr;
    loWhisk = min(v(v >= loFence));
    hiWhisk = max(v(v <= hiFence));
    outliers = v(v < loWhisk | v > hiWhisk);

    % whisker stems and caps
    plot(ax, [xc xc], [hiWhisk q3], 'k-', 'LineWidth', 1.0);
    plot(ax, [xc xc], [q1 loWhisk], 'k-', 'LineWidth', 1.0);
    plot(ax, xc + [-1 1]*w*0.28, [hiWhisk hiWhisk], 'k-', 'LineWidth', 1.0);
    plot(ax, xc + [-1 1]*w*0.28, [loWhisk loWhisk], 'k-', 'LineWidth', 1.0);

    % the box
    patch(ax, 'XData', xc + [-1 1 1 -1]*w/2, 'YData', [q1 q1 q3 q3], ...
          'FaceColor', faceColor, 'FaceAlpha', 0.85, ...
          'EdgeColor', [0.15 0.15 0.15], 'LineWidth', 0.9);

    % median
    plot(ax, xc + [-1 1]*w/2, [q2 q2], 'k-', 'LineWidth', 1.8);

    % outliers
    if ~isempty(outliers)
        plot(ax, repmat(xc, numel(outliers), 1), outliers, 'o', ...
             'MarkerSize', 3.5, 'MarkerEdgeColor', [0.30 0.30 0.30], ...
             'MarkerFaceColor', 'none', 'LineWidth', 0.6);
    end
end

function y = prctile_local(v, p)
%PRCTILE_LOCAL  Linear-interpolation percentile, so the Statistics Toolbox is not
%   required. Matches MATLAB/NumPy's default linear method.
    v = sort(v(:));
    n = numel(v);
    if n == 1, y = v; return; end
    idx = (p/100) * (n - 1) + 1;
    lo  = floor(idx);
    hi  = ceil(idx);
    if lo == hi
        y = v(lo);
    else
        y = v(lo) + (idx - lo) * (v(hi) - v(lo));
    end
end
