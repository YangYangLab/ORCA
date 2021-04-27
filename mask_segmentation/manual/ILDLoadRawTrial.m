function ok = ILDLoadRawTrial
%ILDLOADRAWTRIAL Load raw data and trial info if not loaded
%   This is an internal function used by ILoveDrawing.
%
%   See also ILOVEDRAWING.

%   Weihao Sheng, 2019-12-02
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% 

global ILD_RawFile
global ILD_RawData
global ILD_RawDataSize 
global ILD_nTrials     
global ILD_TrialFrames 
global ILD_FPS

global ILD_LoadingEngine
global ILD_ControlWindowName

ok = false;

% raw files loaded?
if isempty(ILD_RawData)  % path given but data not loaded
    
    if isempty(ILD_LoadingEngine) % no loading method?
        error('ILD: ILD cannot load any file without LoadingEngine');
    end
    if isempty(ILD_RawFile)
        [rawf, rawp] = uigetfile(...
            {'*.raw', 'Raw recording file (*.raw)';}, ...
            'Open recorded raw file');
        if ~isempty(rawf), ILD_RawFile = fullfile(rawp, rawf); end
    end
    if ~isempty(ILD_RawFile)
        ILDdisp('ILD: calling LoadingEngine to read file...');
        if ~isempty(ILD_RawDataSize) % we also have the recording params, good!
            ILD_RawData = feval(ILD_LoadingEngine, ILD_RawFile, ILD_RawDataSize(2), ILD_RawDataSize(1), ILD_RawDataSize(3));
        else % no recording params? It's ok, LoadingEngine will ask the user
            ILD_RawData = feval(ILD_LoadingEngine, ILD_RawFile);
        end
    end
end
if isempty(ILD_RawData) % data not loaded somehow, we don't care anything
    ILD_RawFile = []; 
    return
end
ILD_RawDataSize = size(ILD_RawData);
if isempty(ILD_RawFile), ILD_RawFile = 'pre-loaded'; end

% trial info given?
if ~trials_match_raw_datasize
    ILD_nTrials = askfor(['How many trials for this raw file? ' newline 'If you cannot remember, you can skip this question.']);
    if isempty(ILD_nTrials)
        ILD_TrialFrames = askfor(['Okay you don''t remember how many trials...' newline 'Then how many frames per each trial?'], {'60'});
    end
end
if ~trials_match_raw_datasize
    ILDdisp([mfilename ': No trial info? Fine.']);
    msgbox('By default 1 trial will be considered now. :(', ILD_ControlWindowName, 'error', 'modal');
    ILD_nTrials = 1; 
else
    if isempty(ILD_nTrials), ILD_nTrials = ILD_RawDataSize(3)./ILD_TrialFrames; end
end
    ILD_TrialFrames = ILD_RawDataSize(3) ./ ILD_nTrials;
    
    ILDdisp([mfilename ': raw file and trial info loaded. :)']);
    ok = true;
    % for performance, convert ILD_RawData after trials match
    ILDdisp([mfilename ': converting datatype... this can last for some time.']);
    ILD_RawData = im_norm_gray(ILD_RawData, [-0.05, 0.50]); % better visualization
    ILD_RawData = im_gray2uint8(ILD_RawData);
    if isempty(ILD_FPS), ILD_FPS = 15; end % use this value for playback speed

end

%% subroutine: trials_match_raw_datasize_or_not
function tf = trials_match_raw_datasize
global ILD_RawDataSize ILD_nTrials ILD_TrialFrames

    if isempty(ILD_nTrials) && isempty(ILD_TrialFrames)
        tf = false;
    elseif ~isempty(ILD_nTrials)
        tf = mod(ILD_RawDataSize(3), ILD_nTrials) == 0;
    elseif ~isempty(ILD_TrialFrames)
        tf = mod(ILD_RawDataSize(3), ILD_TrialFrames) == 0;
    end
end

%% subroutine: wrapper function for inputdlg
function answer = askfor(prompt,default)
global ILD_ControlWindowName

    if nargin == 1
        answer = inputdlg(prompt,ILD_ControlWindowName,1);
    elseif nargin == 2
        answer = inputdlg(prompt,ILD_ControlWindowName,1,default);
    else
        error('What the heck R U asking for?');
    end
    try
        answer = str2num(answer{1});
    catch
        answer = [];
    end
end
