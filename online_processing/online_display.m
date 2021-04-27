function fig = online_display(summaryimage, trialinfo, roimap, roitrace, stats)
%UIONLINE_SHOW_TRIAL show trace for one trial
%   FIG = UIONLINE_SHOW_TRIAL(SUMMARYIMAGE, TRIALINFO, ROIMAP, ROITRACE) displays calculated trace as
%   well as the image.
%
%   FIG = UIONLINE_SHOW_TRIAL(..., STATS) 

%   Weihao Sheng, 2020-06-01 (Enjoy Children's Day!)
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

global ORCA
if nargin < 5, stats = []; end

%% calculate necessary params

[nROIs, nFrames] = size(roitrace);
wBaseline = trialinfo.TmBaselineWin .* trialinfo.FPS + [1 1];
wStimulus = trialinfo.TmStimWin .* trialinfo.FPS + [1 1];

psets = ORCA.Plotting.LinePlotDefaults;
gobj = ORCA.Online.GObj;

wYLim = psets.Scalings.YLim;
nplotssize = psets.PlotSize;
nplotsx = repmat([psets.Area(1) : nplotssize: psets.Area(1)+psets.Area(3)-nplotssize]',[1 fix(psets.Area(4)/nplotssize)]); nplotsx = nplotsx(:);
nplotsy = repmat([psets.Area(2) : nplotssize: psets.Area(2)+psets.Area(4)-nplotssize], [fix(psets.Area(3)/nplotssize) 1]); nplotsy = nplotsy(:);

%% show contents

    % sort display sequence
    [tracemax, tracesequence] = sort(max(roitrace, [], 2),'descend');
    if isa(tracesequence,'gpuArray'), tracesequence = gather(tracesequence); end % compability issues
   
    % show image
    gobj.SummaryImage = imshow(mat2gray(summaryimage), 'Parent', gobj.SummaryImagePlaceholder);
    hold(gobj.SummaryImagePlaceholder, 'on');
    contour(gobj.SummaryImagePlaceholder, roimap>0, 'Color', psets.Colour.Lines); 
    plot_add_scalebar(gobj.SummaryImage, ORCA.Experiment.Imaging.PixelSizeum, 'Color', [1 1 1]);
    
    gcanvas_clear(gobj.Figure, psets.Area);
    for idx = 1:nROIs
        roi = tracesequence(idx); % use sort sequence instead of default one
        
        % make a label on the summary image
        [r,c] = find(roimap==roi);
        text(gobj.SummaryImagePlaceholder,...
            c(end), r(end), num2str(idx), 'Color', psets.Colour.Lines); 
        
        % plot response on the right
        
        hPlot = axes(gobj.Figure, 'Box', 'on', ...
            'XTick', [], 'XLim', [1 nFrames], 'XAxisLocation', 'top', ...
            'YTick', [wYLim(1) 0:0.5:wYLim(2)], 'YLim', wYLim);
        hold(hPlot,'on');
        gcanvas_overwrite(hPlot, [nplotsx(idx) nplotsy(idx) nplotssize nplotssize]);
%         patch(hPlot, ...
%             [wBaseline(1) wBaseline(1) wBaseline(2) wBaseline(2)], [wYLim(1) wYLim(2) wYLim(2) wYLim(1)], ...
%             psets.Colour.Shades.Baseline);
        patch(hPlot, ...
            [wStimulus(1) wStimulus(1) wStimulus(2) wStimulus(2)], [wYLim(1) wYLim(2) wYLim(2) wYLim(1)], ...
            psets.Colour.Shades.Stimulus);
        xlabel(hPlot, sprintf('ROI%d',idx), 'Color', psets.Colour.Lines);
        plot(roitrace(roi,:), 'Color', psets.Colour.Lines);
        hold(hPlot,'off');
    end

%% Done and refresh
%uiset_recursive(fig, 'Units', 'normalized'); % very slow, disabled now
end
