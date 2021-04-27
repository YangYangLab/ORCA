function pipeline_online_slm
%PIPELINE_ONLINE_SLM Pipeline demo for online stimulation/inhibition using SLM

global ORCA

%% set up things here
ORCA.Online.ImagesURL = ' ';
ORCA.Online.Images = []; % where images 

ORCA.Device.ImageRegistration = 'register_stack_GPU';
ORCA.Device.FileWatcher = 'ThorlabsFileWatcher';
ORCA.Device.LoadDataOnline = 'ThorlabsLoadRecent';
ORCA.Device.SLMControl = 'ThorlabsWriteSLM';
ORCA.Device.UseGPU = 0;

ORCA.Debug = @(varargin) []; % @(varargin) fprintf(varargin{:}); % <- alternate 

ORCA.Experiment.Imaging.PixelSizeum = 0.528;
ORCA.Experiment.Imaging.DataBytes = 2;
ORCA.Experiment.Imaging.DataPrecision = 'uint16';
ORCA.Experiment.Imaging.Resolution = [512 512];
ORCA.Experiment.Trial.FPS = 15;
ORCA.Experiment.Trial.TmDuration = 4;
ORCA.Experiment.Trial.nFrames = 60;
ORCA.Experiment.Trial.TmBaselineWin = [0 1];
ORCA.Experiment.Trial.TmStimWin = [1 1.2];
ORCA.Experiment.SLMChoice = 0;
ORCA.Experiment.SLMTemplate = [];

ORCA.MaskSegmentation.glance.Threshold = 0.05;
ORCA.MaskSegmentation.glance.MinimumPixels = 36;
ORCA.MaskSegmentation.glance.Convex = 1;


ORCA.Online.GObj = [];

%% the full pipeline starts here
init_ORCA
ORCA.Online.Processor{1} = Notifier;
ORCA.Online.Processor{2} = addlistener(ORCA.Online.Processor{1}, 'FramesIn', @process_trial);
ORCA.Online.Processor{3} = addlistener(ORCA.Online.Processor{1}, 'Reloading', @reload_process_trial);

online_init;
end

function process_trial(src,evt)
global ORCA

    status = feval(ORCA.Device.LoadDataOnline);

    if status ~= 0, return; end

    reload_process_trial();
    
    if ORCA.Experiment.SLMChoice > 0
        ORCA.Experiment.SLMTemplate = bwlabel(mask>0);
    end
    feval(ORCA.Device.SLMControl, ORCA.Experiment.SLMTemplate, ORCA.Experiment.SLMChoice);
end

function reload_process_trial(src,evt)
global ORCA

    if isempty(ORCA.Online.Images), return; end
    debugprint = ORCA.Debug; %@(varargin) fprintf(varargin{:});
    
    %[offsets, ORCA.Online.Images] = feval(ORCA.Device.ImageRegistration, ORCA.Online.Images, mean);
    
    wmap = glance_std(ORCA.Online.Images);
    wmap = gather(wmap);
    [wmap,stats] = glance_filter(wmap);
    mask = glance_merge_convex(wmap, stats);
    
    [roitrace, stats] = trace_extract_trial(ORCA.Online.Images, mask, ...
        struct('Baseline', ORCA.Experiment.Trial.TmBaselineWin));
    summaryimage = mean(ORCA.Online.Images,3);
    online_display(summaryimage, ORCA.Experiment.Trial, mask, roitrace, stats);
end