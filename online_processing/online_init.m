function fig = online_init
%ONLINE_INIT Initialisation for online monitoring

global ORCA

ORCA.Online.Functions.UpdateSLM = 'online_updateSLM';

% create a default window
WindowDefaults = {...
    'MenuBar', 'none', 'ToolBar', 'none', 'DockControls', 'off', ...
    'NumberTitle','off', ...
    'Units', 'pixel', };
fig = figure(...
    'Name', 'ORCA(Online): Main Window', 'Tag', 'ORCA_Online_Main', ...
    WindowDefaults{:}, 'Visible', 'off');
% If such window exists, Tag is going to conflict, causing an error.

% Adjust its position...
firstscreen = get(groot, 'MonitorPosition'); 
firstscreen = firstscreen(1,:); % Don't have experience using multiple screens...
fig.Position = [firstscreen(3)*0.1 firstscreen(4)*0.1 firstscreen(3)*0.8 firstscreen(4)*0.8];
fig = gcanvas_create(fig);    
ORCA.Online.GObj.Figure = fig;

% now load the canvas setting and put elements onto canvas
cvs = fig.UserData.Canvas;

% first the placeholder for image and the image itself
imgWidthGrid = fix(ORCA.Experiment.Imaging.Resolution(1)/cvs.GridSize(1));
imgHeightGrid = fix(ORCA.Experiment.Imaging.Resolution(2)/cvs.GridSize(2));
ORCA.Online.GObj.SummaryImagePlaceholder = axes(fig, 'Box', 'on', 'XTick', [], 'YTick', []);
gcanvas_align(ORCA.Online.GObj.SummaryImagePlaceholder, [1 1 imgWidthGrid imgHeightGrid]);
ORCA.Online.GObj.SummaryImage = image(zeros(imgWidthGrid, imgHeightGrid), 'Parent', ORCA.Online.GObj.SummaryImagePlaceholder); 

% text area
ORCA.Online.GObj.Text = uicontrol(fig, 'Style', 'text', 'FontSize', 16, 'String', ORCA.Online.ImagesURL);
gcanvas_align(ORCA.Online.GObj.Text, [1 imgHeightGrid+1 imgWidthGrid 2]);

% load file button
ORCA.Online.GObj.LoadDataButton = uicontrol(fig, 'Style', 'pushbutton', 'FontSize', 16, 'String', 'Manual Load', 'Callback', @cb_choose_raw_file);
gcanvas_align(ORCA.Online.GObj.LoadDataButton, [1 imgHeightGrid+1+3 floor(imgWidthGrid/2) 1]);

ORCA.Online.GObj.StartMonitor = uicontrol(fig, 'Style', 'pushbutton', 'FontSize', 16, 'String', 'Stop Monitor', 'Callback', @cb_stop_monitor);
gcanvas_align(ORCA.Online.GObj.StartMonitor, [floor(imgWidthGrid/2)+1 imgHeightGrid+1+3 ceil(imgWidthGrid/2) 1]);

ORCA.Online.GObj.GlanceMinPixels = uicontrol(fig, 'Style', 'edit', 'String', num2str(ORCA.MaskSegmentation.glance.MinimumPixels), 'FontSize', 16, 'Callback', @cb_update_minpix);
gcanvas_align(ORCA.Online.GObj.GlanceMinPixels, [imgWidthGrid+1 1 1 1]);
gcanvas_align(uicontrol(fig, 'Style', 'text', 'String', 'px threshold', 'FontSize', 16), [imgWidthGrid+2 1 3 1]);

ORCA.Online.GObj.SLMChoice = uicontrol(fig, 'Style', 'edit', 'String', num2str(ORCA.Experiment.SLMChoice), 'FontSize', 16, 'Callback', ORCA.Online.Callbacks.UpdateSLM);
gcanvas_align(ORCA.Online.GObj.SLMChoice, [imgWidthGrid+5 1 1 1]);
gcanvas_align(uicontrol(fig, 'Style', 'text', 'String', 'SLMPattern', 'FontSize', 16), [imgWidthGrid+6 1 3 1]);

% some plotting settings
cvssize = size(cvs.GridObjects);
ORCA.Plotting.LinePlotDefaults.Area = [imgWidthGrid+1 2 cvssize(1)-imgWidthGrid cvssize(2)-1];
ORCA.Plotting.LinePlotDefaults.PlotSize = 4;
ORCA.Plotting.LinePlotDefaults.Colour.Lines = [1 0 0];
ORCA.Plotting.LinePlotDefaults.Colour.Shades.Baseline = [0.9412    0.9412    0.9412];
ORCA.Plotting.LinePlotDefaults.Colour.Shades.Stimulus = [1.0000    0.9059    0.7608];
ORCA.Plotting.LinePlotDefaults.Scalings.YLim = [-0.5 3];

fig.Visible = 'on';
end

% ------------------------------------------
% |||||||||||||||| Callback ||||||||||||||||
% ------------------------------------------

function cb_choose_raw_file(varargin)
global ORCA

[fn,pn,~] = uiputfile('*.raw', mfilename);
if fn == 0
    fprintf('%s: User cancelled Load File\n', mfilename);
    return
end
ORCA.Online.ImagesURL = fullfile(pn, fn);
ORCA.Online.GObj.Text.String = ['Watching: ' fullfile(pn, fn)];
feval(ORCA.Device.FileWatcherCallback, 'init');
end

function cb_stop_monitor(varargin)
global ORCA
feval(ORCA.Device.FileWatcherCallback, 'stop');
end

function cb_update_minpix(varargin)
global ORCA
ORCA.MaskSegmentation.glance.MinimumPixels = str2num(ORCA.Online.GObj.GlanceMinPixels.String);
ORCA.Online.Processor{1}.Reload();
end

