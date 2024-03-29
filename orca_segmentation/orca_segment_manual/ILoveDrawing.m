function figCtrl = ILoveDrawing
%ILOVEDRAWING cell segmentation control main window.
%   ILOVEDRAWING will open a window for user to manually draw masks 
%   over a certain movie of 2-photon imaging. To use this, simply type
%   ILoveDrawing in the console.
%
%   See also ORCA_SEGMENT_MASK_MANUAL, ILDRESETGLOBALS.

%   This code is released as part of RAPID package.
%   Technical details: 
%   -   Each uicontrol is given a Tag that is descriptive of its
%       role. All callbacks are sent to ILDCallbacks.
%   -   All global variables are set beforehand (see segment_manually)
%       or in ILDResetGlobals. These globals control the behavior of this 
%       program.

%   Weihao Sheng, 2019-11-29(Happy Black Friday!)
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China


%% globals

global ILD_ControlWindowName ILD_ControlWindow_Pos

global ILD_CurrTrial ILD_CurrFrame
global ILD_MaskVisible ILD_MaskColor ILD_PenDiameter_px

global ILD_RawFile ILD_RawData ILD_RawDataSize
global ILD_Mask ILD_SaveMaskTo ILD_MaskSaved
global ILD_PreLoadMode
global ILD_RUNNINGLOCK
global ILD_VERSION

if ~isempty(ILD_RUNNINGLOCK)
    warning([mfilename ': only one instance of ' mfilename ' is allowed at one time.']);
    return
end

ILDResetGlobals('init');

figCtrl = [];
%% load necessary files

% check / load the raw data and trial information
if ~isempty(ILD_RawFile) || ~isempty(ILD_RawData)  % means we have some pre-loaded data
    if ~ILDLoadRawTrial
        warning([mfilename ': pre-loaded RAWFILE or RAWDATA not available']);
        return
    end
elseif ILD_PreLoadMode
    warning([mfilename ': pre-loaded RAWFILE or RAWDATA not available']);
    return
end

% pre-defined mask
if ~isempty(ILD_Mask)
    % yes we have a mask now
    sz = size(ILD_Mask);
    if (sz(1) == ILD_RawDataSize(1)) && (sz(2) == ILD_RawDataSize(2)) 
        % size match, force binary mask
        ILD_Mask = im2bw(ILD_Mask); 
        ILD_MaskSaved = true;
        ILDdisp ([mfileame ': MASK loaded.']);
        
        % btw if we have a place to put the file
        if isempty(ILD_SaveMaskTo), ILD_SaveMaskTo = maskpath; end
        
    else % we have different mask size?
        ILDdisp ([mfilename ': MASK size different from RAWDATA, discarded']);
        msgbox('MASK size different from RAWDATA', 'Load Mask', 'error', 'modal');
        ILD_Mask = zeros(ILD_RawDataSize(1), ILD_RawDataSize(2), 'uint8');
        ILD_MaskSaved = false;
    end
    
else % we don't have a mask now
    if ~isempty(ILD_RawData)
        ILD_Mask = zeros(ILD_RawDataSize(1), ILD_RawDataSize(2));
    else
        ILD_Mask = [];
    end
    ILD_MaskSaved = false;
end

% if SaveMaskTo is defined, is it available for writing permission?
if ~isempty(ILD_SaveMaskTo)
    if isempty(dir(ILD_SaveMaskTo)) % not found
        ILDdisp ([mfilename ': SAVEMASKTO destination unavailable (' ILD_SaveMaskTo ')']);
        ILD_SaveMaskTo = [];
    else
        % location found, write permission?
        testfile = [ILD_SaveMaskTo 'mask.tmp'];
        fid = fopen(testfile, 'w+');
        if fid ~= -1, fclose(fid); delete(testfile); end
        if fid == -1
            ILDdisp ([mfilename ': SAVEMASKTO destination unavailable (' ILD_SaveMaskTo ')']);
            ILD_SaveMaskTo = [];
        end
    end
end

%% main window

fig = figure('Name', ILD_ControlWindowName, ...
    'NumberTitle', 'off', 'Toolbar', 'none', 'MenuBar', 'none', ...
    'Tag','ILDControlWindow', 'Resize', 'on', 'Units', 'pixels', ...
    'Position', ILD_ControlWindow_Pos,... 
    'Visible', 'on', 'HandleVisibility', 'Callback', 'CloseRequestFcn', 'ILDCallbacks(''Goodbye'')');
set(fig, 'Units', 'normalized');

% alignment: full uic design
uicWidth  = 0.28;  
XLocs = 0.08:uicWidth:0.92; % use three vert refz lines
uicHeight = 0.045; 
YLocs = 0.91:-uicHeight:0.01; % use 20 horz refz lines
FrameBorder = 0.01;

% uicontrols
    uicontrol('Parent', fig, ...
       'Units', 'normalized', 'Position', [XLocs(1) YLocs(1) uicWidth*3 uicHeight], ...
       'Style', 'text', 'Tag', 'About', 'ButtonDownFcn', 'ILDCallbacks', 'Enable', 'inactive', ...
       'String', 'Manual Segmentation', 'FontSize', 12);

if ~ILD_PreLoadMode
    uicontrol('Parent', fig, ...
       'Units', 'normalized', 'Position', [XLocs(1) YLocs(2) uicWidth*2 uicHeight], ...
       'Style', 'text', 'Tag', 'Filename', ...
       'String', ' ', 'BackgroundColor', [0.7 0.7 0.7], 'TooltipString', 'Current raw file in use', 'FontSize', 10);
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(3) YLocs(2) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'OpenClose', 'Callback', 'ILDCallbacks', ...
        'String', 'Open', 'TooltipString', 'Load raw file');
else
    uicontrol('Parent', fig, ...
       'Units', 'normalized', 'Position', [XLocs(1) YLocs(2) uicWidth*3 uicHeight], ...
       'Style', 'text', 'Tag', 'Filename', ...
       'String', ' ', 'BackgroundColor', [0.7 0.7 0.7], 'TooltipString', 'Current raw file in use', 'FontSize', 10);
end

    uicontrol('Parent', fig, ...
       'Units', 'normalized', 'Position', [XLocs(1) YLocs(3) uicWidth*3 uicHeight], ...
       'Style', 'text', 'String', 'Trials', 'FontSize', 10);

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(4) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'PrevTrial', 'Callback', 'ILDCallbacks', ...
        'String', '<');
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(2) YLocs(4) uicWidth uicHeight], ...
        'Style', 'edit', 'Tag', 'CurrTrial', 'Callback', 'ILDCallbacks', ...
        'String', num2str(ILD_CurrTrial));
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(3) YLocs(4) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'NextTrial', 'Callback', 'ILDCallbacks', ...
        'String', '>');

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(5) uicWidth*3 uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'PlayAllTrials', 'Callback', 'ILDCallbacks', ...
        'String', 'Play All Trials', 'TooltipString', 'Play the full movie', 'FontSize', 10);

    uicontrol('Parent', fig, ...
       'Units', 'normalized', 'Position', [XLocs(1) YLocs(7) uicWidth*2 uicHeight], ...
       'Style', 'text', 'String', 'CurrentFrame');
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(3) YLocs(7) uicWidth uicHeight], ...
        'Style', 'edit', 'Tag', 'CurrFrame', 'Callback', 'ILDCallbacks', ...
        'String', num2str(ILD_CurrFrame), 'TooltipString', 'Press Enter to confirm');

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(8) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'PlayThisTrial', 'Callback', 'ILDCallbacks', ...
        'String', 'Play', 'TooltipString', 'Play all frames in this trial');
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(2) YLocs(8) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'PrevFrame', 'Callback', 'ILDCallbacks', ...
        'String', 'F-1', 'TooltipString', 'Show previous frame');
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(3) YLocs(8) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'NextFrame', 'Callback', 'ILDCallbacks',...
        'String', 'F+1', 'TooltipString', 'Show next frame');

    uicontrol('Parent', fig, ... 
       'Units', 'Normalized', 'Position', [XLocs(1)-FrameBorder YLocs(14)+uicHeight/2 uicWidth*3+2*FrameBorder uicHeight*5], ...
       'Style', 'frame');

    uicontrol('Parent', fig, ...
       'Units', 'normalized', 'Position', [XLocs(1) YLocs(10) uicWidth*3 uicHeight], ...
       'Style', 'text', 'String', 'Pen diameter (pixels)', 'FontSize', 10);

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(11) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'PenSmall', 'Callback', 'ILDCallbacks', ...
        'String', '-', 'TooltipString', 'Decrease pen size by 1 pixel (min 6px)');
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(2) YLocs(11) uicWidth uicHeight], ...
        'Style', 'edit', 'Tag', 'PenSize', 'Callback', 'ILDCallbacks', ...
        'String', num2str(ILD_PenDiameter_px), 'TooltipString', 'Press Enter to confirm');
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(3) YLocs(11) uicWidth uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'PenLarge', 'Callback', 'ILDCallbacks', ...
        'String', '+', 'TooltipString', 'Increase pen size by 1 pixel (max 32px)');

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(12) uicWidth*3 uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'DrawErase', 'Callback', 'ILDCallbacks', ...
        'String', 'Currently DRAWING', 'TooltipString', 'Click to switch between Draw or Erase mode');

    uicontrol('Parent',fig, ...
        'Units', 'Normalized', 'Position', [XLocs(1) YLocs(13) uicWidth*1.5 uicHeight], ...
        'Style', 'frame', 'Tag', 'ChooseColor', 'ButtonDownFcn', 'ILDCallbacks', 'Enable', 'inactive', ...
        'BackgroundColor', ILD_MaskColor, 'TooltipString', 'Change mask color');
    uicontrol('Parent',fig, ...
        'Units', 'Normalized', 'Position', [XLocs(2)+uicWidth/2+FrameBorder YLocs(13) uicWidth*1.3 uicHeight], ...
        'Style', 'checkbox', 'Tag', 'MaskShowHide', 'Callback', 'ILDCallbacks', ...
        'String', 'Show/Hide', 'Value', ILD_MaskVisible, 'TooltipString', 'Show/Hide mask');

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(16) uicWidth*3 uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'LoadMask', 'Callback', 'ILDCallbacks', ...
        'String', 'Load Mask', 'TooltipString', 'Load a mask with the same size of raw data');

    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(17) uicWidth*3 uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'SaveMask', 'Callback', 'ILDCallbacks', ...
        'String', 'Save Mask', 'TooltipString', 'Save current mask to disk');

if ~ILD_PreLoadMode
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(20) uicWidth*3 uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'Goodbye', 'Callback', 'ILDCallbacks', ...
        'String', 'Exit', 'TooltipString', 'Goodbye!');
else
    uicontrol('Parent', fig, ...
        'Units', 'normalized', 'Position', [XLocs(1) YLocs(20) uicWidth*3 uicHeight], ...
        'Style', 'pushbutton', 'Tag', 'Goodbye', 'Callback', 'ILDCallbacks', ...
        'String', 'Return', 'TooltipString', 'Goodbye!'); 
end

%% final init
disp(ILD_VERSION);
disp('   Manual ROI labelling program')
disp('   Yang Yang''s Lab of Neural Basis of Learning and Memory');
disp('   School of Life Sciences and Technology, ShanghaiTech University,');
disp('   Shanghai, China');
disp(' ');

if nargout > 0
    figCtrl = fig;
end


end

