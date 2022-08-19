function orcaui_online_worker(opt)
%GUI for online worker
%   orcaui_online_worker('init')
%   orcaui_online_worker('update')
%   orcaui_online_worker('exit')

% this is a general template, you may modify to fit your own pipeline

global ORCA

switch lower(opt)
case 'init'
    ORCA.workspace{1} = ONLINE_INIT();
    ORCA.methodparams.uiworker = [ORCA.methodparams.uiworker {'OnePageAxes', 24}];
case 'update'
    orcaui_online_worker_update(0);

case 'exit'
    if ~isempty(ORCA.workspace{2})
        stop_orca_daemon();
    end
    close(ORCA.workspace{1})
    ORCA.workspace{1} = [];
end
end


function fig = ONLINE_INIT
    % create a default window
    WinHeight = 960; WinWidth = 1280;
    Wincolor.Background = rgbcolor(30,30,30);

    Wincolor.Red = hexcolor('ff8383');
    Wincolor.Yellow = hexcolor('fadd86');
    Wincolor.Green = hexcolor('3eb99d');
    Wincolor.Blue = hexcolor('48aac0');
    Wincolor.DarkBlue = hexcolor('16537e');
    Wincolor.White = rgbcolor(255,255,255);
    Wincolor.Dimmed = rgbcolor(50,50,50);
    Wincolor.Darker = rgbcolor(25,25,25);
    Wincolor.Black = rgbcolor(0,0,0);
    
    Wincolor.Palette = jet(256);

    % --- remove extra things
    ORCAOnlineWindowTag = 'ORCAOnlineWindow';
    WindowDefaults = {...
        'MenuBar', 'none', 'ToolBar', 'none', 'DockControls', 'off', ...
        'NumberTitle','off', 'Color', Wincolor.Background,...
        'Name', 'ORCA Online', 'Tag', ORCAOnlineWindowTag, ...
        'Units', 'pixel'};
    try
        fig = figure(WindowDefaults{:}, 'Visible', 'off');
    catch
        % If such window exists, Tag is going to conflict, causing an error.
        fprintf('An existing ORCAOnline conflicts, using existing one\n')
        fig = findobj('Tag', ORCAOnlineWindowTag);
    end

    % -- adjust its position
    screens = get(groot, 'MonitorPosition'); scr1st = screens(1,:);
    fig.InnerPosition = [(scr1st(3)-WinWidth)/2 (scr1st(4)-WinHeight)/2 WinWidth WinHeight];
    
    % create objects based on Grids
    fig = canvas_cut(fig, 32);
    fig.UserData.Canvas.ColorPalette = Wincolor.Palette;
    
    % --- image placeholder
    [fig,obImageContainer] = canvas_put(fig, ...
        axes(fig,'Box','on','XTick',[],'YTick',[],'Color',Wincolor.Black), ...
        'ImageContainer', ...
        'InnerPosition', [1 1 16 16]);

    [fig,obImageHolder] = canvas_put(fig, ...
        imshow(zeros(512,512),'Parent',obImageContainer), ...
        'ImageData', ...
        'hidden', [0 0 0 0]);

    % --- colorbar
    [fig,obColorbarContainer] = canvas_put(fig, ...
        axes(fig,'Box','on','XTick',[],'YTick',[],'Color',Wincolor.Black), ...
        'ColorbarContainer', ...
        'InnerPosition', [1 17 16 1]);

    [fig,obColorbar] = canvas_put(fig, ...
        image(permute(fig.UserData.Canvas.ColorPalette, [3 1 2]),'Parent',obColorbarContainer), ...
        'ColorbarData', ...
        'hidden', [0 0 0 0]);

    % --- File Name label
    [fig, obFilename] = canvas_put(fig, ...
        uicontrol(fig,'Style','text','FontSize',16,'String','','BackgroundColor',Wincolor.Darker,'ForegroundColor',Wincolor.White),...
        'FileName', ...
        'Position', [1 18 16 2]);
    
    % --- Buttons
    [fig, obButtonExit] = canvas_put(fig, ...
        uicontrol(fig,'Style','pushbutton','Callback',@(~,~) orcaui_online_worker('exit'), ...
                'FontSize',16,'String','Exit','BackgroundColor',Wincolor.Red,'ForegroundColor',Wincolor.Background),...
        'ButtonExit', ...
        'Position', [2 28.5 4 2]);

    [fig, obButton2] = canvas_put(fig, ...
        uicontrol(fig,'Style','pushbutton', 'Visible', 'off', ...
                'FontSize',16,'String','Button2','BackgroundColor',Wincolor.Blue,'ForegroundColor',Wincolor.White),...
        'Button2', ...
        'Position', [7 28.5 4 2]);

    [fig, obButton3] = canvas_put(fig, ...
        uicontrol(fig,'Style','pushbutton', 'Visible', 'off', ...
                'FontSize',16,'String','Button3','BackgroundColor',Wincolor.Blue,'ForegroundColor',Wincolor.White),...
        'Button3', ...
        'Position', [12 28.5 4 2]);

    [fig, obButtonPageLeft] = canvas_put(fig, ...
        uicontrol(fig,'Style','pushbutton', 'Visible', 'off', 'Callback', @cb_page_back, ...
                'FontSize',16,'String','<','BackgroundColor',Wincolor.Darker,'ForegroundColor',Wincolor.White),...
        'ButtonPageLeft', ...
        'Position', [17.5 8 1 14]);

    [fig, obButtonPageRight] = canvas_put(fig, ...
        uicontrol(fig,'Style','pushbutton', 'Visible', 'off', 'Callback', @cb_page_next, ...
                'FontSize',16,'String','>','BackgroundColor',Wincolor.Darker,'ForegroundColor',Wincolor.White),...
        'ButtonPageRight', ...
        'Position', [39.5 8 1 14]);
    
    % --- Prepared 5x5 axes
    plotsize = 5; totalplots = 0;
    for r = 1:plotsize:30
        for c = 19:plotsize:38
            totalplots = totalplots + 1;
            [fig, cplot] = canvas_put(fig, ...
                axes(fig,'Box','off','YLim',[-0.5 3],'Visible','off',...
                    'Color',Wincolor.Dimmed,'XColor',Wincolor.White,'YColor',Wincolor.White),...
                sprintf('axes%02d', totalplots), ...
                'OuterPosition', [c r plotsize plotsize]);
        end
    end

    % One more thing: remember page
    fig.UserData.CurrentPage = 1;

    % finally
    fig.Visible = 'on';

end

% ------------------------------------------
% |||||||||||||||| Callback ||||||||||||||||
% ------------------------------------------

function cb_exit_ORCA(varargin)
    orcaui_online_worker('stop')
end

function cb_page_next(varargin)
    orcaui_online_worker_update(+1);
end

function cb_page_back(varargin)
    orcaui_online_worker_update(-1);
end