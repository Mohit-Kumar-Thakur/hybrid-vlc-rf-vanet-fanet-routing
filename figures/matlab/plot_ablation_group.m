function plot_ablation_group(data, ylabelText, titleText, outFile, opts)
%PLOT_ABLATION_GROUP  Grouped bar chart: baselines vs. ablation mechanisms.
%
%   Draws one group per congestion scenario and five bars per group (AODV, DSDV,
%   AHP-only, ML-reliability-only, Complete-Proposed), then writes a 600 dpi PNG and a
%   vector PDF named OUTFILE.
%
%   data        3x5 numeric. Rows = Low/Medium/High. Columns = the five methods,
%               in legend order.
%   ylabelText  y-axis label.
%   titleText   figure title.
%   outFile     output basename, WITHOUT extension (e.g. 'fig04a_safety_delay').
%   opts        struct, all fields optional:
%                 .logScale   true for a logarithmic y-axis (default false)
%                 .valueFmt   sprintf format for bar labels
%                             (default '%.1f'; use '%.1e' on a log axis)
%                 .legendLoc  legend location (default 'northwest')
%
%   COMPATIBILITY NOTE
%   Earlier revisions of this file called bar() with the axes handle first and with a
%   width and/or a 'grouped' style argument:
%       bar(ax, data, 'grouped', 'BarWidth', 0.88)   % rejected
%       bar(ax, data, 0.88, 'grouped')               % also rejected
%   Both forms are release-sensitive. This version makes the axes current with axes()
%   and then calls the single-argument form bar(data), which every release from R2014b
%   onward accepts and which already defaults to grouped layout for matrix input.
%   Group width is set afterwards through the BarWidth property instead.

    % --- pressing Run on THIS file -----------------------------------------
    % This file is a helper: it needs data passed in. Pressing Run (F5) on it calls it
    % with no arguments, and MATLAB then reports "Not enough input arguments" pointing
    % at the first line that uses `data` -- which looks like a bug in that line but is
    % not. Redirect to the driver script so either file works from the Run button.
    if nargin == 0
        fprintf(['plot_ablation_group is a helper function and needs input data.\n' ...
                 'Running make_ablation_figures instead (that is the script to run).\n\n']);
        make_ablation_figures;
        return
    end

    if nargin < 5, opts = struct(); end
    if ~isfield(opts, 'logScale'),  opts.logScale  = false;       end
    if ~isfield(opts, 'valueFmt'),  opts.valueFmt  = '%.1f';      end
    if ~isfield(opts, 'legendLoc'), opts.legendLoc = 'northwest'; end

    % --- validate input early, with a clear message ------------------------
    if ~isnumeric(data) || ~ismatrix(data) || isempty(data)
        error('plot_ablation_group:badData', ...
              'data must be a non-empty numeric matrix; got %s of size %s.', ...
              class(data), mat2str(size(data)));
    end
    data = double(data);

    scenarios = {'Low (Q_{max}=20)', 'Medium (Q_{max}=40)', 'High (Q_{max}=50)'};
    methods   = {'AODV', 'DSDV', 'AHP-only', 'ML-reliability-only', 'Complete-Proposed'};

    nGroups = size(data, 1);
    nSeries = size(data, 2);

    % Light, bright, hue-separated palette -- one distinct hue per method.
    colors = [ ...
        1.00 0.55 0.35; ...   % AODV                -- bright coral/orange
        0.68 0.55 0.92; ...   % DSDV                -- bright violet
        1.00 0.82 0.30; ...   % AHP-only            -- bright gold
        0.35 0.82 0.65; ...   % ML-reliability-only -- bright teal-green
        0.40 0.68 0.98];      % Complete-Proposed   -- bright sky blue

    fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100 100 1250 560]);
    ax  = axes('Parent', fig);
    axes(ax);                 %#ok<LAXES>  make ax the current axes for bar()
    hold(ax, 'on');

    % Matrix input defaults to a grouped layout, so no style string is needed.
    b = bar(data);

    for k = 1:nSeries
        set(b(k), 'FaceColor', colors(k, :), ...
                  'EdgeColor', [0.15 0.15 0.15], ...
                  'LineWidth', 0.7, ...
                  'BarWidth',  0.88);
    end

    % --- reserve headroom BEFORE labelling so nothing is clipped -----------
    if opts.logScale
        set(ax, 'YScale', 'log');
        positive = data(data > 0);
        set(ax, 'YLim', [min(positive)/3, max(positive)*3]);
    else
        set(ax, 'YLim', [0, max(data(:)) * 1.16]);
    end

    % --- bar centre x-positions --------------------------------------------
    % XEndPoints exists from R2019b; on older releases derive the centres from the
    % series' XOffset, which is the documented pre-R2019b approach.
    xc = zeros(nGroups, nSeries);
    for k = 1:nSeries
        if isprop(b(k), 'XEndPoints')
            xc(:, k) = b(k).XEndPoints(:);
        elseif isprop(b(k), 'XOffset')
            xc(:, k) = (1:nGroups)' + b(k).XOffset;
        else
            % last-resort geometric fallback
            w = 0.88 / nSeries;
            xc(:, k) = (1:nGroups)' - 0.44 + w * (k - 0.5);
        end
    end

    % --- value labels -------------------------------------------------------
    for k = 1:nSeries
        for j = 1:nGroups
            v = data(j, k);
            if ~isfinite(v), continue; end
            if opts.logScale
                yLabel = v * 1.10;                    % multiplicative gap, log axis
            else
                yLabel = v + max(data(:)) * 0.015;    % additive gap, linear axis
            end
            text(xc(j, k), yLabel, sprintf(opts.valueFmt, v), ...
                'Parent', ax, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment',   'bottom', ...
                'FontSize', 9, 'FontWeight', 'bold', ...
                'Color', [0.10 0.10 0.10]);
        end
    end

    % --- cosmetics ----------------------------------------------------------
    set(ax, 'XTick', 1:nGroups, 'XTickLabel', scenarios, ...
            'FontSize', 11, 'LineWidth', 1.0, 'Box', 'off', ...
            'TickDir', 'out', 'YGrid', 'on', 'Layer', 'top');
    if isprop(ax, 'GridAlpha'), set(ax, 'GridAlpha', 0.15); end

    ylabel(ax, ylabelText, 'FontSize', 12);
    title(ax,  titleText,  'FontSize', 13, 'FontWeight', 'bold');

    lgd = legend(b, methods, 'Location', opts.legendLoc, 'FontSize', 10);
    set(lgd, 'Box', 'on');
    if isprop(lgd, 'NumColumns'),    set(lgd, 'NumColumns', 3);        end  % R2018a+
    if isprop(lgd, 'ItemTokenSize'), set(lgd, 'ItemTokenSize', [16 10]); end

    hold(ax, 'off');

    % --- export -------------------------------------------------------------
    % 600 dpi clears Ad Hoc Networks' 500 dpi floor for combination line/halftone art;
    % the vector PDF sidesteps the DPI requirement entirely and is preferable for line
    % art such as this. exportgraphics needs R2020a, so fall back to print().
    useExport = exist('exportgraphics', 'file') == 2 || ...
                exist('exportgraphics', 'builtin') == 5;
    if useExport
        exportgraphics(fig, [outFile '.png'], 'Resolution', 600);
        exportgraphics(fig, [outFile '.pdf'], 'ContentType', 'vector');
    else
        set(fig, 'PaperPositionMode', 'auto');
        print(fig, [outFile '.png'], '-dpng', '-r600');
        print(fig, [outFile '.pdf'], '-dpdf', '-painters');
    end
    fprintf('wrote %s.png and %s.pdf\n', outFile, outFile);
end
