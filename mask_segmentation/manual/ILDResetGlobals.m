function ILDResetGlobals(option)
%ILDRESETGLOBALS reset global variables for ILoveDrawing.
%   This is an internal function used by ILoveDrawing.
%
%   See also ILOVEDRAWING.

%   ILDResetGlobals('init') initialize all global variables required for ILD, as well as 
%   detect the input value as a way of interaction with possible caller.
%
%   ILDResetGlobals('clear') is called by 'OpenClose' callback and resets all global 
%   variables currently in use. This function should never be called in ILD_PreLoadMode,
%   because the button is disabled in that mode.
%
%   ILDResetGlobals('exit') is called by 'Exit' callback and clears all global variables, 
%   EXCEPT ILoveDrawingOutput for interaction with caller.

%   Weihao Sheng, 2019-12-02
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China
%
%   Inspired by MClust 3.5


%% comprehensive list of globals
% constant globals
global ILD_VERSION          % version
global ILD_DEBUG            % verbosely showing debugging info in console
global ILD_RUNNINGLOCK      % running flag that prevents multiple startup
global ILD_PreLoadMode      % whether this instance is running in standalone or preloaded

% globals initialized once
global ILD_Path             % where ILD functions reside
global ILD_LoadingEngine    % which function will be used for loading raw file

% globals for file info; all can be used as input
global ILD_RawFile          % path to raw file
global ILD_RawData          % actual 3-dim matrix containing RawData
global ILD_RawDataSize      % [height_y width_x nFrames] of RawData
global ILD_nTrials          % how many trials included in this raw file
global ILD_TrialFrames      % frames per trial
global ILD_FPS              % frames per second of this file

% globals for mask
global ILD_Mask             % the mask data; can be used as input (load 
                            % pre-defined mask) or output (return the mask
                            % data to the caller function
global ILD_SaveMaskTo       % path to save the mask file; can be the input
global ILD_MaskSaved        % have the mask been saved (1 for saved)
global ILD_MaskVisible      % Show or Hide (1/0) the current mask
global ILD_MaskColor        % colors for showing mask (not for saving them - binary masks!)

% globals for display
global ILD_Window_DPI       % Scaling Percentage of loaded frame, options include 1, 1.25, 1.5, 2
global ILD_ControlWindow_Pos% position of ControlWindow (I Love Drawing)
global ILD_ControlWindowName% I Love Drawing
global ILD_DrawingWindow_Pos% position of DrawingWindow (Drawing Makes Me Happy)
global ILD_DrawingWindowName% Drawing Makes Me HAPPY
global ILD_CurrTrial        % current trial
global ILD_CurrFrame        % current frame
global ILD_CurrFrameInternal% absolute frame in the trial
global ILD_PenDiameter_px   % Size of pen (in pixels)
global ILD_PenMode          % Drawing or Erasing (1/0)
global ILD_MinCellDia_px    % minimum pen size in pixels (this value is due to change; can be used as input)
global ILD_MaxCellDia_px    % maximum pen size in pixels (this value is due to change; can be used as input)
global ILD_Canvas_System    % for canvas use

% other globals 
global ILoveDrawingOutput   % for returning the mask only (if it is not cleared)


%% main function
switch option
	case 'init'
        
        %% INIT - called only by ILD once
		% constants through running
        ILD_VERSION = 'ILoveDrawing 0.2 (alpha) 2019 Winter';
        ILD_DEBUG = true;
        ILD_RUNNINGLOCK = 1;
        disp([mfilename ': Initializing...']);

        if ILD_PreLoadMode
            disp([mfilename ': running in preloaded mode']);
        end            
        
        ILD_Path = fileparts(which('ILoveDrawing.m'));
		
        if isempty(ILD_LoadingEngine), ILD_LoadingEngine = 'load_recording_raw'; end
        
        % some defaults 
        scrsz = get(0, 'screensize');
        scrsz = [scrsz(3) scrsz(4) scrsz(3) scrsz(4)];
        
        ILD_Window_DPI = 1;
        ILD_ControlWindowName = 'I Love Drawing';
        ILD_ControlWindow_Pos = [10 60 240*ILD_Window_DPI 512*ILD_Window_DPI];
        
        ILD_DrawingWindowName = 'Drawing Makes Me HAPPY';
        ILD_DrawingWindow_Pos = [300*ILD_Window_DPI 60 512*ILD_Window_DPI 512*ILD_Window_DPI];
        
        ILD_CurrTrial = 1; ILD_CurrFrame = 1; ILD_CurrFrameInternal = 1;
        
        % pen things here
        ILD_PenDiameter_px = 10; 
        ILD_PenMode = 1; 
        if isempty(ILD_MinCellDia_px), ILD_MinCellDia_px = 6;  end
        if isempty(ILD_MaxCellDia_px), ILD_MaxCellDia_px = 20; end

        ILD_MaskSaved = 0;
        ILD_MaskVisible = 1;
        ILD_MaskColor = [0 1 0.4];    % by default light green; neurons are bright

        ILD_Canvas_System = [];
        

    case 'clear'

        figDraw = findobj('Type', 'figure', 'Tag', 'ILDDrawingWindow');
        if ishandle(figDraw), delete(figDraw); end
        ILD_Canvas_System = [];
        
        ILD_RawFile = []; ILD_RawData = []; ILD_RawDataSize = []; 
        ILD_nTrials = []; ILD_TrialFrames = []; ILD_FPS = [];
        
        ILD_Mask = []; ILD_SaveMaskTo = [];
        ILD_MaskSaved = 0; 
        ILD_MaskVisible = 1;
        
    case 'exit'
        prompt =  {'', '(MASK NOT SAVED)'};
        
        ConfirmExit = questdlg(...
            ['Are you sure to quit? ' prompt{2-ILD_MaskSaved}], ...
            ILD_ControlWindowName, 'Yes', 'No', ...
            'No');
        if ~strcmp(ConfirmExit, 'Yes')
            return
        end
        
        ILoveDrawingOutput = ILD_Mask;
        
        clear global ILD_*
        
        figDraw = findobj('Type', 'figure', 'Tag', 'ILDDrawingWindow');
        if ishandle(figDraw), delete(figDraw); end
        figCtrl = findobj('Type', 'figure', 'Tag', 'ILDControlWindow');
        if ishandle(figCtrl), delete(figCtrl); end
end
end


