function fig = uionline_show_trial(summaryimage, trialinfo, roimap, roitrace, stats)
%UIONLINE_SHOW_TRIAL show trace for one trial
%   FIG = UIONLINE_SHOW_TRIAL(SUMMARYIMAGE, TRIALINFO, ROIMAP, ROITRACE) displays calculated trace as
%   well as the image.
%
%   FIG = UIONLINE_SHOW_TRIAL(..., STATS) 

%   Weihao Sheng, 2020-06-01 (Enjoy Children's Day!)
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

global RAPID
if nargin < 5, stats = []; end

%% calculate necessary params

[nROIs, nFrames] = size(roitrace);
wBaseline = trialinfo.Baseline .* trialinfo.fps + [1 1];
wStimulus = trialinfo.Stimulus .* trialinfo.fps + [1 1];
wYLim = RAPID.UIOnline.PlotYLim;

%% show contents

    % sort display sequence
    [tracemax, tracesequence] = sort(max(roitrace, [], 2),'descend');
    if isa(tracesequence,'gpuArray'), tracesequence = gather(tracesequence); end % compability issues
    
    % Adjust positions based on screen size   
    % switch to existing fig or create one
    fig = findobj('Type', 'figure', 'Tag', RAPID.UIOnline.Tags.ShowTrial);
    if isempty(fig)
        fig = figure(...
            'Name',     [RAPID.UIOnline.Title 'Current Trial'], ...
            'Tag',      RAPID.UIOnline.Tags.ShowTrial, ...
            'Position', RAPID.UIOnline.ScreenSize, ... % maximise window
            RAPID.UIOnline.Defaults{:});
        
        cvsWidth = fig.InnerPosition(3); cvsHeight = fig.InnerPosition(4)-fig.InnerPosition(2);
        
        % draw plots first so that image stays on top
        containerPlots = uipanel(fig, 'BorderType', 'none', 'Units', 'pixel');
        containerPlots.Position = round([0.25*cvsWidth 0.01 0.75*cvsWidth 0.98*cvsHeight]);
        containerImage = uipanel(fig, 'BorderType', 'none', 'Units', 'pixel');
        containerImage.Position = round([0 0.8*cvsHeight-0.3*cvsWidth 0.3*cvsWidth 0.3*cvsWidth]);
        containerImage = axes(containerImage, 'Box', 'on', 'XTick', [], 'YTick', [], 'Units', 'pixel');
        %containerImage.Position = round([0 0.8*cvsHeight-0.3*cvsWidth 0.3*cvsWidth 0.3*cvsWidth]);
        fig.UserData = {containerImage containerPlots};
    else
        containerImage = fig.UserData{1};
        containerPlots = fig.UserData{2}; delete([containerPlots.Children]); % redraw if different ROIs
        
        figU = fig.Units; fig.Units = 'pixel'; 
            cvsWidth = fig.InnerPosition(3); cvsHeight = fig.InnerPosition(4)-fig.InnerPosition(2);
        fig.Units = figU;
    end

    % calculate plotting areas and construct subplots
    plotsRatio = (0.6*cvsWidth)/(cvsHeight);
    for plotm = 1:20, if plotm*plotm*plotsRatio>nROIs, break; end; end
    plotn = round(plotm * plotsRatio);
   
    % show image
    hImage = imshow(mat2gray(summaryimage), 'Parent', containerImage);
    hold(containerImage, 'on');
    contour(containerImage, roimap>0, 'Color', 'r'); 
    
    for idx = 1:nROIs
        roi = tracesequence(idx); % use sort sequence instead of default one
        
        [r,c] = find(roimap==roi);
        text(containerImage, c(end), r(end), num2str(idx), 'Color', 'r'); %[RAPID.UIOnline.ColourLines(roi,:)]
        
        hPlot = subplot(plotm, plotn, idx, 'Parent', containerPlots); 
        hold(hPlot,'on');
        set(hPlot, 'Box', 'on',  ...
            'InnerPosition', hPlot.OuterPosition, ...% larger plot
            'XTick', [], 'XLim', [1 nFrames], 'XAxisLocation', 'top', ...
            'YTick', [wYLim(1) 0:0.5:wYLim(2)], 'YLim', RAPID.UIOnline.PlotYLim);
        patch(hPlot, ...
            [wBaseline(1) wBaseline(1) wBaseline(2) wBaseline(2)], [wYLim(1) wYLim(2) wYLim(2) wYLim(1)], ...
            RAPID.UIOnline.ColourBaseline);
        patch(hPlot, ...
            [wStimulus(1) wStimulus(1) wStimulus(2) wStimulus(2)], [wYLim(1) wYLim(2) wYLim(2) wYLim(1)], ...
            RAPID.UIOnline.ColourStimulus);
        xlabel(hPlot, sprintf('ROI%d',idx), 'Color', 'r'); 
        plot(hPlot, roitrace(roi,:), 'Color', 'r');
        
        hold(hPlot,'off');
    end

%% Done and refresh
%uiset_recursive(fig, 'Units', 'normalized'); % very slow, disabled now
end
