function [out1, out2, out3] = ui_ginput(n, varargin)
%UI_GINPUT Graphical input from mouse with custum cursor pointer.
%   [X,Y] = UI_GINPUT(N) gets N points from the current axes and returns the X- and 
%   Y-coordinates in length N vectors X and Y. 
%
%   [X,Y] = UI_GINPUT equals to [X,Y] = UI_GINPUT(1).
%
%   [X,Y,BUTTONS] = UI_GINPUT(...) adds an additional output BUTTONS which stores the 
%   keys pressed.
%
%   [...] = UI_GINPUT(..., 'Pointer', POINTERTYPE) is similar to UI_GINPUT(N) but the 
%   cursor pointer is changed to POINTERTYPE. Supported POINTERTYPE in this function
%   include 'crosshair', 'arrow', 'circle' etc. See "Mouse Pointer" in "Figure 
%   properties" in Matlab's documentation for available pointers.
%
%   [...] = UI_GINPUT(..., 'Pointer', 'custom', 'PointerShapeCData', CDATA, 'PointerShapeHotSpot', HOTSPOT) 
%   allows you to modify the Pointer with CDATA and HOTSPOT for use in ui_input. Other 
%   behaviors are consistent with above usage.
%
%   See also GINPUT, WAITFORBUTTONPRESS. 

%   Weihao Sheng, 2019-11-30
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

x = []; y = []; buttons = [];

%% input argument check
if nargin == 0
    n = 1;
end
if n == 0
    warning('No input given to ui_ginput(N = 0), return');
    return
end

Pointer = '';
if nargin >= 1
    get_varargin_namevalue;
    validatestring(Pointer, ...
        {'arrow', 'ibeam', 'crosshair', 'watch', 'circle', 'cross', 'hand', ...
         'topl', 'botr', 'topr', 'botl', 'fleur', 'left', 'right', 'top', 'bottom',...
         'custom'}, mfilename, 'Pointer');
    if strcmp(Pointer,'custom')
        validateattributes(PointerShapeCData, {'numeric'}, {'ndims', 2}, mfilename, 'PointerShapeCData');
        validateattributes(PointerShapeHotSpot, {'numeric'}, {'size', [1 2]}, mfilename, 'PointerShapeHotSpot');
    end
end

%% Preparations

fig = gcf; 

% backup original figure settings
drawnow;
oldstate = BackupFigure(fig);
c = onCleanup(@() RestoreFigure(oldstate)); % onCleanup, idea from ginput

% set pre-defined / custom cursor
if ~isempty(Pointer)
    set(fig, 'Pointer', Pointer);
    if strcmp(Pointer,'custom')
        set(fig, 'PointerShapeCData', PointerShapeCData, 'PointerShapeHotSpot', PointerShapeHotSpot);
    end
end

%% read key loop
kInput = 1;
while kInput <= n
    try
        key = waitforbuttonpress;
    catch
        clear c
        error('Error occured during user input');
    end
    if ~isequal(gcf, fig)  % the user clicked on another figure window
        x = [];
        y = [];
        buttons = [];
        break
    end
    if key == 0 % mouse input
        point2 = get(fig,'CurrentPoint'); 
        btn = get(fig, 'SelectionType');
        
        buttons = [buttons find(ismember({'normal','alt','extend'}, btn))];
        x = [x point2(1,1)];
        y = [y point2(1,2)];
    else % keyboard input
        char = get(fig, 'CurrentCharacter');
        if (char == 13) || (char == 27) % Enter or Esc
            break;
        end
        warning('Keyboard input detected while waiting for mouse input. To leave ui_ginput, press Enter or Esc.');
        kInput = kInput - 1;
    end
    drawnow;
    kInput = kInput + 1;
end

%% finished here
clear c
if nargout > 0
    out1 = x;
    if nargout > 1
        out2 = y;
        if nargout > 2
            out3 = buttons;
        end
    else
        out1 = [x y];
    end
end
end

%% Backup and Restore
function oldstate = BackupFigure(fig)
    oldstate.hFigure = fig;
    oldstate.uisuspend = uisuspend(fig);
    oldstate.fig_units = get(fig,'Units');
end
function RestoreFigure(oldstate)
    if ishghandle(oldstate.hFigure) % still valid window, not closed
        set(oldstate.hFigure,'Units',oldstate.fig_units);
        uirestore(oldstate.uisuspend);
    end
end

