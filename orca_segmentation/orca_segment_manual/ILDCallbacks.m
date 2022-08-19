function ILDCallbacks(varargin)
%ILDCALLBACKS Callback function for ILoveDrawing.
%   This is an internal function used by ILoveDrawing.
%
%   See also ILOVEDRAWING.

%   ILDCallbacks() takes no input and uses tag to identify caller.
%
%   ILDResetGlobals('exit') is called by 'Exit' callback and clears all
%   global variables, EXCEPT ILD_Mask for interaction with caller.

%   Weihao Sheng, 2019-12-04
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% global variables
global ILD_VERSION          % version
global ILD_DEBUG            % verbosely showing debugging info in console
global ILD_Path             % where ILD functions reside
global ILD_RUNNINGLOCK      % running lock, one instance only
global ILD_PreLoadMode      % data is preloaded, calling from segment_manually

global ILD_RawFile          % path to raw file
global ILD_RawData          % actual 3-dim matrix containing RawData
global ILD_RawDataSize      % [height width nFrames] of RawData
global ILD_nTrials          % how many trials included in this raw file
global ILD_TrialFrames      % frames per trial
global ILD_FPS              % frames per second of this file
global ILD_Mask             % the mask data; can be used as input (load 
                            % pre-defined mask) or output (return the mask
                            % data to the caller function
global ILD_SaveMaskTo       % path to save the mask file; can be the input
global ILD_MaskSaved        % have the mask been saved (1 for saved)
global ILD_MaskVisible      % Show or Hide (1/0) the current mask
global ILD_MaskColor        % colors for showing mask (not for saving them - binary masks!)
global ILD_Window_DPI       % Scaling Percentage of loaded frame, options include 1, 1.25, 1.5, 2
global ILD_ControlWindow_Pos% position of ControlWindow (I Love Drawing)
global ILD_ControlWindowName% I Love Drawing

global ILD_CurrTrial        % current trial
global ILD_CurrFrame        % current frame
global ILD_CurrFrameInternal% absolute frame in the trial
global ILD_PenDiameter_px   % Size of pen (in pixels)
global ILD_PenMode          % Drawing or Erasing (1/0)
global ILoveDrawingOutput   % for returning the mask only (if it is not cleared)

global ILD_MinCellDia_px    % minimum pen size in pixels (this value is due to change; can be used as input)
global ILD_MaxCellDia_px    % maximum pen size in pixels (this value is due to change; can be used as input)

%% we find the control window first
figControl = findobj('Type', 'figure', 'Tag', 'ILDControlWindow');
if isempty(figControl)
    dbstop if error
    error('Is there really a control panel? A BUG HERE!');
end

%% who called us?
if nargin > 0
    ILDdisp ([mfilename ': called with command']);
    tag = varargin{1};              % called with command
else
    cboHandle = gcbo;              % current uicontrol handle
    tag = get(cboHandle, 'Tag');   % tag of uicontrol
end

switch tag
%% About the program
	case 'About'
        
		msg = [    '    I Love Drawing - utility program for manual mask segmentation' newline];
        msg = [msg '    Version ' ILD_VERSION newline newline];
        msg = [msg '    Weihao Sheng 2019' newline];
        msg = [msg '    Yang Yang''s Lab of Neural Basis of Learning and Memory' newline];
        msg = [msg '    School of Life Sciences and Technology, ShanghaiTech University, ' newline];
        msg = [msg '    Shanghai, China'];
            
        uiwait(msgbox(msg,ILD_ControlWindowName,'modal'));

%% Open or Close raw file
	case 'OpenClose'
        if isempty(ILD_RawData) 
            % open a raw file
            ok = ILDLoadRawTrial;
            SyncParameters(figControl);
            if ok % loaded
                ILDRefreshDrawing('init');
                ILD_Mask = zeros([ILD_RawDataSize(1:2)]);
                ILD_MaskSaved = true;
            else
                set(findobj(figControl, 'Tag', 'Filename'), 'String', ' ', 'BackgroundColor', 'red');
            end
        else
            % close a raw file
            if ~isempty(ILD_Mask) && ~ILD_MaskSaved
                answer = questdlg('You have unsaved mask now. Do you still want to close this file?', ...
                    ILD_ControlWindowName, 'Yes, clear it and close', 'No', ...
                    'No');
                if ~strcmp(answer, 'Yes, clear it and close'), return; end
            end
            
            % close the drawing window
            figDrawing = findobj('Type', 'figure', 'Tag', 'ILDDrawingWindow');
            if ishghandle(figDrawing), close(figDrawing); end
            % clear workspace
            ILDResetGlobals('clear'); 
            % refresh display
            SyncParameters(figControl); 
        end

%% Trials & Frames
	case {'PrevTrial', 'CurrTrial', 'NextTrial'}
        
        if isempty(ILD_RawData)
            ILD_CurrTrial = 1; ILD_CurrFrame = 1; ILD_CurrFrameInternal = 1;
        else
            uicCurrTrial = findobj(figControl, 'Tag', 'CurrTrial');
            switch tag
                case 'PrevTrial', intended = ILD_CurrTrial - 1;
                case 'NextTrial', intended = ILD_CurrTrial + 1;
                case 'CurrTrial', intended = str2num(get(uicCurrTrial, 'String'));
            end
            ILD_CurrTrial = max(min(intended, ILD_nTrials), 1);
            ILD_CurrFrame = 1;
            ILD_CurrFrameInternal = (ILD_CurrTrial-1)*ILD_TrialFrames+ILD_CurrFrame;
        end
        SyncParameters(figControl); ILDRefreshDrawing('canvas');
        
    case {'CurrFrame', 'PrevFrame', 'NextFrame'}
        
        if isempty(ILD_RawData)
            ILD_CurrTrial = 1; ILD_CurrFrame = 1; ILD_CurrFrameInternal = 1;
        else
            uicCurrFrame = findobj(figControl, 'Tag', 'CurrFrame');
            switch tag
                case 'PrevFrame', intended = ILD_CurrFrame - 1;
                case 'NextFrame', intended = ILD_CurrFrame + 1;
                case 'CurrFrame', intended = str2num(get(uicCurrFrame, 'String'));
            end
            ILD_CurrFrame = max(min(intended, ILD_TrialFrames), 1);
            ILD_CurrFrameInternal = (ILD_CurrTrial-1)*ILD_TrialFrames+ILD_CurrFrame;
        end
        SyncParameters(figControl); ILDRefreshDrawing('canvas');
        
	case 'PlayAllTrials'
        
        if isempty(ILD_RawData)
            ILD_CurrTrial = 1; ILD_CurrFrame = 1; ILD_CurrFrameInternal = 1;
            return
        end
        for jTrial = 1:ILD_nTrials
            ILD_CurrTrial = jTrial;
            for kFrame = 1:ILD_TrialFrames
                ILD_CurrFrame = kFrame;
                ILD_CurrFrameInternal = (ILD_CurrTrial-1)*ILD_TrialFrames+ILD_CurrFrame;
                SyncParameters(figControl); ILDRefreshDrawing('canvas');
                pause(1/ILD_FPS);
            end
        end
        ILD_CurrTrial = 1; ILD_CurrFrame = 1; 
        ILD_CurrFrameInternal = 1;
        SyncParameters(figControl); ILDRefreshDrawing('canvas');
        
    case 'PlayThisTrial'
        
        if isempty(ILD_RawData)
            ILD_CurrTrial = 1; ILD_CurrFrame = 1; ILD_CurrFrameInternal = 1;
            return
        end
        for kFrame = 1:ILD_TrialFrames
            ILD_CurrFrame = kFrame;
            ILD_CurrFrameInternal = (ILD_CurrTrial-1)*ILD_TrialFrames+ILD_CurrFrame;
            SyncParameters(figControl); ILDRefreshDrawing('canvas');
            pause(1/ILD_FPS);
        end
        ILD_CurrFrame = 1; ILD_CurrFrameInternal = (ILD_CurrTrial-1)*ILD_TrialFrames+ILD_CurrFrame;
        SyncParameters(figControl); ILDRefreshDrawing('canvas');

%% Pen / Mask
    case 'PenSmall'

        ILD_PenDiameter_px = max(ILD_PenDiameter_px-1, ILD_MinCellDia_px);
        SyncParameters(figControl); ILDRefreshDrawing('pen');
        
    case 'PenSize'

        intended = str2num(get(cboHandle, 'String'));
        ILD_PenDiameter_px = min(max(intended, ILD_MinCellDia_px), ILD_MaxCellDia_px); % pen size should be between DEFINED range
        SyncParameters(figControl); ILDRefreshDrawing('pen');
        
    case 'PenLarge'

        ILD_PenDiameter_px = min(ILD_PenDiameter_px+1, ILD_MaxCellDia_px);
        SyncParameters(figControl); ILDRefreshDrawing('pen');
        
    case 'DrawErase'

        ILD_PenMode = ~ILD_PenMode;
        SyncParameters(figControl); 
        
%% Mask
    case 'ChooseColor'
        
        ILD_MaskColor = uisetcolor(ILD_MaskColor, 'Choose color for mask');
        SyncParameters(figControl); ILDRefreshDrawing('canvas');
        
    case 'MaskShowHide'
        
        ILD_MaskVisible = get(cboHandle, 'Value');
        ILDRefreshDrawing('canvas');
        
    case 'LoadMask'
        
        % is rawdata loaded?
        if isempty(ILD_RawData)
            ILDdisp ([mfilename ': MASK without RAWDATA is meaningless!']);
            ILD_Mask = []; ILD_MaskSaved = false;
            return
        end        
        % clear existing mask?
        if ~isempty(ILD_Mask)
            answer = questdlg('YOU ALREADY HAVE A MASK IN USE! Do you still want to load a new one?', ILD_ControlWindowName, 'Yes, clear this one', 'No', 'No');
            if strcmp(answer, 'No'), return; end
            ILD_Mask = []; ILD_MaskSaved = false;
        end
        % we can load the file now
        [maskfile, maskpath] = uigetfile(...
            {'*.bmp;*.jpg;*.tif;*.png', 'Mask raster images (*.bmp, *.jpg, *.tif, *.png)';
            '*.mat', 'Mask file stored in MATLAB (*.mat)'}, ...
            'Open pre-defined mask file');
        
        maskloaded = [];
        if ~isempty(maskfile)
            try
                maskloaded = imread(fullfile(maskpath, maskfile));
            catch
                ILDdisp ([mfilename ': Error occured while reading ' fullfile(maskpath, maskfile)]);
                msgbox('Nothing happened.', ILD_ControlWindowName, 'error', 'modal');
            end
        end
        
        % did we load a mask just now?
        if ~isempty(maskloaded)
            % great! check the size
            sz = size(maskloaded);
            if (sz(1) == ILD_RawDataSize(1)) && (sz(2) == ILD_RawDataSize(2))
                % size match, force binary mask
                ILD_Mask = im2bw(maskloaded);
                answer = questdlg('Which color is used for mask in this file?', 'White', 'Black');
                if strcmp(answer, 'Black')
                    ILD_Mask = 1 - ILD_Mask;
                    ILDdisp([mfilename ': MASK inverted (black is mask)']);
                end
                ILD_MaskSaved = true;
                ILDdisp ([mfilename ': MASK loaded']);
                
                % btw if we have a place to put the file...
                if isempty(ILD_SaveMaskTo), ILD_SaveMaskTo = maskpath; end
                
            else % we have different mask size?
                ILDdisp ([mfilename ': MASK size different from RAWDATA, discarded (MASK ' num2str(sz) 'while RawData ' num2str(ILD_RawDataSize) ')']);
                msgbox('MASK size different from RAWDATA', 'Load Mask', 'error', 'modal');
                ILD_Mask = zeros(ILD_RawDataSize(1), ILD_RawDataSize(2)); 
                ILD_MaskSaved = false;
            end
        end
        ILDRefreshDrawing('canvas');
        
    case 'SaveMask'
            
        if ~isempty(ILD_SaveMaskTo), dir_push(ILD_SaveMaskTo); end
        [maskfile, maskpath] = uiputfile(...
            {'*.bmp', 'Mask raster images (*.bmp)';
             '*.mat', 'Mask file stored in MATLAB (*.mat)'}, ...
            'Save mask to...');
        if ~isempty(maskfile)
            imwrite(ILD_Mask, fullfile(maskpath, maskfile), 'bmp');
            ILD_MaskSaved = 1;
            ILoveDrawingOutput = ILD_Mask;
            ILDdisp ([mfilename ': mask saved to ' fullfile(maskpath, maskfile)]);
            msgbox('Mask saved', 'Save Mask', 'help', 'modal');
        else
            ILDdisp ([mfilename ': save mask cancelled by user']);
            msgbox('You CANCELLED save mask', 'Save Mask', 'warn', 'modal');
        end
        if ~isempty(ILD_SaveMaskTo), dir_pop; end
        if ~isempty(maskpath), ILD_SaveMaskTo = maskpath; end        
        
%% Exit
    case 'Goodbye'
        
        ILDResetGlobals('exit');
        
        figDrawing = findobj('Type', 'figure', 'Tag', 'ILDDrawingWindow');
        if ishandle(figDrawing), delete(figDrawing); end
        if ishandle(figControl), delete(figControl); end

%% something weird here
	otherwise
		warndlg('Sorry, feature not yet implemented.');
end % switch

end


%% a general function for syncing display with globals

function SyncParameters(figControl)

global ILD_RawFile          % path to raw file
global ILD_RawData          % actual 3-dim matrix containing RawData
global ILD_MaskVisible      % Show or Hide (1/0) the current mask
global ILD_MaskColor        % colors for showing mask (not for saving them - binary masks!)
global ILD_CurrTrial        % current trial
global ILD_CurrFrame        % current frame in the trial
global ILD_PenDiameter_px   % Size of pen (in pixels)
global ILD_PenMode          % Drawing or Erasing (1/0)

uicFilename = findobj(figControl, 'Tag', 'Filename');
uicOpenClose = findobj(figControl, 'Tag', 'OpenClose');
if isempty(ILD_RawData)
    set(uicFilename, 'String', '   ', 'BackgroundColor', [0.7 0.7 0.7]);
    set(uicOpenClose, 'String', 'Open', 'TooltipString', 'Load raw file');
else
    [~, rawfilename, ~] = fileparts(ILD_RawFile);
    set(uicFilename, 'String', rawfilename, 'BackgroundColor', 'green');
    set(uicOpenClose, 'String', 'Close', 'TooltipString', 'Close current raw file and clear workspace');
end

uicCurrTrial = findobj(figControl, 'Tag', 'CurrTrial');
set(uicCurrTrial, 'String', num2str(ILD_CurrTrial));

uicCurrFrame = findobj(figControl, 'Tag', 'CurrFrame');
set(uicCurrFrame, 'String', num2str(ILD_CurrFrame));

uicPenSize = findobj(figControl, 'Tag', 'PenSize');
set(uicPenSize, 'String', num2str(ILD_PenDiameter_px));

uicDrawErase = findobj(figControl, 'Tag', 'DrawErase');
text = {'Currently ERASING', 'Currently DRAWING'};
set(uicDrawErase, 'String', text{ILD_PenMode+1});

uicChooseColor = findobj(figControl, 'Tag', 'ChooseColor');
set(uicChooseColor, 'BackgroundColor', ILD_MaskColor);

uicMaskShowHide = findobj(figControl, 'Tag', 'MaskShowHide');
set(uicMaskShowHide, 'Value', ILD_MaskVisible);

end