function uionline_init
%UIONLINE_INIT Initialisation for online user interface

global RAPID

% Scaling 
RAPID.UIOnline.ScreenSize = get(groot, 'MonitorPosition');  % this value is fixed upon matlab start
RAPID.UIOnline.ScreenSize = RAPID.UIOnline.ScreenSize(1,:); % always use the first monitor
RAPID.UIOnline.ScreenRatio = RAPID.UIOnline.ScreenSize(3)/RAPID.UIOnline.ScreenSize(4);

% Default window settings
RAPID.UIOnline.Defaults = {...
    'MenuBar', 'none', 'ToolBar', 'none', 'DockControls', 'off', 'NumberTitle','off', ...
    'Units', 'pixel'};
RAPID.UIOnline.Title = 'RAPID(Online): ';
RAPID.UIOnline.Tags.ShowTrial = 'RAPID_UIOnline_ShowTrial';

RAPID.UIOnline.ColourLines = ui_shufflecolours(hsv); 
RAPID.UIOnline.ColourBaseline = [0.9412    0.9412    0.9412];
RAPID.UIOnline.ColourStimulus = [1.0000    0.9059    0.7608];
RAPID.UIOnline.PlotYLim = [-0.5 3];
end

