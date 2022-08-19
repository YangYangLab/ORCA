function f = orcaui_online_worker_update(deltapage)
% show all traces on UI
%   deltapage = 0, update and refresh all 
%   deltapage = +1, one page after 
%   deltapage = -1, one page ahead

global ORCA

f = ORCA.workspace{1};
cv = f.UserData.Canvas;

p = inputParser; p.KeepUnmatched = true; p.CaseSensitive = false; p.PartialMatching = true;
addParameter(p, 'OnePageAxes', 24);
addParameter(p, 'YLim', [-0.5 3]);
addParameter(p, 'StimulusColor', hexcolor('fadd86'));
parse(p, ORCA.methodparams.uiworker{:});
p = p.Results;

ROIs = ORCA.result.ROIs; roitrace = ORCA.result.ROItrace;
[nROIs, nFrames] = size(roitrace);

%% sort display sequence and coloring
% --- sorting
    [dffmax, traceorder] = sort(max(roitrace, [], 2),'descend');
    if isa(traceorder,'gpuArray'),traceorder = gather(traceorder);end % compability issues

% --- due to coloring issues only 256 
    if nROIs > 256
        warning('ORCA online supports display of maximum 64 traces.')
        nROIs = 256;
    end

% --- matching colors

    chosencolor = round(linspace(235,20,nROIs));
    ROIcolors = cv.ColorPalette(chosencolor,:);

    if deltapage == 0
        % --- update palette
        cv.list{4,1}.CData = permute(cv.ColorPalette, [3 1 2]);
        
        % --- update Filename
        cv.list{5,1}.String = ORCA.DataFile;
        
        % --- update image
        cla(cv.list{1,1});
        averageImage = mat2gray(mean(ORCA.Data,3));
        cv.list{2,1} = imshow(averageImage, 'Parent', cv.list{1,1});
        
        % --- put contours
        hold(cv.list{1,1}, 'on');
        for x = 1:nROIs
            contour(cv.list{1,1}, ROIs{x}>0, 'Color', ROIcolors(x,:));
        end
        hold(cv.list{1,1}, 'off');
    end

%% Page select and update
    maxpages = ceil(nROIs/p.OnePageAxes);
    page = f.UserData.CurrentPage;
    if deltapage ~= 0
        page = page + deltapage;
        if page <= 0, page = 1; end
        if page > maxpages, page = maxpages; end
        f.UserData.CurrentPage = page;
    end

% --- only draw this page
    withinPageRange = ((page-1)*p.OnePageAxes+1) : min(nROIs, page * p.OnePageAxes);

    %rgBaseline = ORCA.TrialDef.baseline .* ORCA.AcqDef.fps + [1 0];
    rgStimulus = ORCA.TrialDef.stimulus .* ORCA.AcqDef.fps + [1 0];
    frmStimOnset = rgStimulus(1); frmStimOffset = rgStimulus(2);

    for idx = 1:length(withinPageRange)
        roi = traceorder(withinPageRange(idx));
        
        currPlot = cv.list{10+idx}; 
        cla(currPlot);
        set(currPlot, 'Box','off','XTick', [], 'XLim', [1 nFrames], 'YLim', p.YLim, 'Visible', 'on');
        patch(currPlot, ...
            [frmStimOnset frmStimOnset frmStimOffset frmStimOffset], [p.YLim(1) p.YLim(2) p.YLim(2) p.YLim(1)], ...
            p.StimulusColor);
        hold(currPlot,'on');
        plot(currPlot, roitrace(roi,:), 'Color', ROIcolors(withinPageRange(idx),:));
        hold(currPlot,'off');
    end

% --- hide extra blank axes
    for idx = length(withinPageRange)+1 : p.OnePageAxes
        cla(cv.list{10+idx});
        set(cv.list{10+idx}, 'Visible', 'off');
    end

% --- update page flip buttons
    if     page==1, cv.list{9}.Visible = 'off'; 
    elseif  page>1, cv.list{9}.Visible = 'on'; end
    
    if      page < maxpages, cv.list{10}.Visible = 'on'; 
    elseif page == maxpages, cv.list{10}.Visible = 'off'; end

    drawnow;
end
