function orca_online_worker(callback_reason)
%callback worker for online processing
%   orca_online_worker('FileChanged')
%       reads changed file from disk; only available when data needs to be loaded from disk
%   orca_online_worker('Refresh')
%       performs re-calculation only

% this is a general template, you may modify to fit your own pipeline

global ORCA

try
    % if data need to be loaded from disk
    if strcmpi(callback_reason, 'FileChanged')
        % lock watchdog
        [ORCA.workspace{2}(1), ORCA.workspace{2}(2)] = ORCA.method.watchdog('pause', ORCA.workspace{2}(1), ORCA.workspace{2}(2));
        % load data
        ORCA.methodparams.loader = { round(ORCA.TrialDef.duration(2)*ORCA.AcqDef.fps) }; %lastnFrames as required by loadThorlabsRecent
        ORCA.Data = ORCA.method.loader(ORCA.DataFile, ORCA.methodparams.loader{:});
        
    end

    % registration (if needed)
    if ~isempty(ORCA.method.registration)
        ORCA.Data = ORCA.method.registration(ORCA.Data, mean(ORCA.Data,3), ORCA.methodparams.registration{:});
    end

    % segmentation
    ROIs = ORCA.method.segmentation(ORCA.Data, ORCA.TrialDef, ORCA.AcqDef, ORCA.methodparams.segmentation{:});

    % trace extraction
    [ROItrace, ROIs] = ORCA.method.traceextraction(ORCA.Data, ORCA.TrialDef, ORCA.AcqDef, ROIs, ORCA.methodparams.traceextraction{:});
    
    ORCA.result.ROIs = ROIs;
    ORCA.result.ROItrace = ROItrace;
    
    % post processing
    % --- save ROItrace to disk
    %save(sprintf('orcatrace_%s.mat', datestr(now,'yyyymmddHHMMSS')), 'ROIs', 'ROItrace');

    % --- export first 3 ROIs to Thorlabs Imaging System
    % trace extraction uses ('sort', true), so just give out first three ROIs 
    write_ROIs_to_Thorlabs_SLM(ROIs(1:3));

    % --- if showUI, update UI
    if ORCA.showUI, ORCA.method.uiworker('update'); end

catch ME
    disp "///// ERROR DETECTED /////"
    disp ME
end


% unlock watchdog
if strcmpi(callback_reason, 'FileChanged')
    [ORCA.workspace{2}(1), ORCA.workspace{2}(2)] = ORCA.method.watchdog('resume', ORCA.workspace{2}(1), ORCA.workspace{2}(2));
end