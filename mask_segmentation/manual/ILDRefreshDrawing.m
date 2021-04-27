function ILDRefreshDrawing(command)
%ILDREFRESHDRAWING Refresh the drawing window.
%   This is an internal function used by ILoveDrawing.
%
%   See also ILOVEDRAWING.

%   ILDRefreshDrawing() creates a new figure with the loaded frame if
%   needed, or refresh CDATA of the drawing axis on request.

%   Weihao Sheng, 2019-12-03
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

global ILD_DrawingWindowName ILD_DrawingWindow_Pos
global ILD_Window_DPI

global ILD_RawData ILD_RawDataSize 
global ILD_CurrFrameInternal
global ILD_Mask ILD_MaskColor ILD_MaskVisible ILD_MaskSaved
global ILD_PenDiameter_px ILD_PenMode

global ILD_Canvas_System

if isempty(ILD_RawData), return; end

if nargin == 0
    ILDRefreshDrawing('init');
    return
end

if isempty(ILD_RawData), return; end
        
% do we have the drawing window now?
figDrawing = findobj('Type', 'figure', 'Tag', 'ILDDrawingWindow');

switch command
    
    case 'init'
        
        if ~isempty(figDrawing) % if window exists, just switch to it
            figure(figDrawing);
            return
        end
        
        if isempty(ILD_Mask)
            ILD_Mask = zeros(ILD_RawDataSize(1), ILD_RawDataSize(2), 'uint8');
        end
        
        % create drawing window
        figDrawing = figure('Name', ILD_DrawingWindowName, ...
            'NumberTitle', 'off', 'Toolbar', 'none', 'MenuBar', 'none', ...
            'Tag','ILDDrawingWindow', 'Resize', 'on', 'Units', 'pixels', ...
            'Position', ILD_DrawingWindow_Pos,...
            'WindowButtonMotionFcn', @someFasterMouseMoveCallback, ...
            'WindowButtonDownFcn', @someFasterClickCallback); 
        %  'HandleVisibility', 'Callback', ...
        set(figDrawing, 'Units', 'normalized');
        
        % drawing axis
        canvasAxis = axes('Parent', figDrawing, ...
            'XLim', [0.5 ILD_RawDataSize(2)], 'YLim', [0.5 ILD_RawDataSize(1)], 'YDir', 'reverse',...
            'XColor', 'none', 'YColor', 'none', 'Position', [0 0 1 1], ...
            'Tag', 'CanvasAxis');
        canvas = image('Parent', canvasAxis, ...
            'CData', zeros(ILD_RawDataSize(1),ILD_RawDataSize(2), 3, 'uint8'),...
            'Tag', 'Canvas');
            % a little trick here: interruptible off allows no callback 
            % other than to canvas callback to be executed while a 
            % ButtonDown event is detected, giving it more priority 
            
        ILD_Canvas_System.figure = figDrawing;
        ILD_Canvas_System.axis = canvasAxis;
        ILD_Canvas_System.canvas = canvas;
        ILD_Canvas_System.dynamicDPI = 512/min(ILD_RawDataSize(1), ILD_RawDataSize(2));
        ILD_Canvas_System.timer = [];
        ILD_Canvas_System.hLastCursor = [];
        
        ILDRefreshDrawing('canvas');
        ILDRefreshDrawing('pen');
        
    case 'pen'

        if isempty(figDrawing)
            ILDRefreshDrawing('init');
        else
            someFasterMouseMoveCallback();
        end
      
    case 'canvas'
        
        if isempty(figDrawing)
            ILDRefreshDrawing('init');
        else
            someCanvasRedraw();
        end
        
end
    %% faster callback for Mouse movement
    % I need mouse movement callback to be very fast, or click events can
    % be ignored (don't know why)
    function someFasterMouseMoveCallback(varargin)
        % construct cursor
        currpos = get(ILD_Canvas_System.figure, 'CurrentPoint');
        x = ILD_RawDataSize(2) * currpos(1);
        y = ILD_RawDataSize(1) * (1-currpos(2));
        
        % delete last cursor point
        if ishandle(ILD_Canvas_System.hLastCursor), delete(ILD_Canvas_System.hLastCursor); end

        hold(ILD_Canvas_System.axis, 'on');
        ILD_Canvas_System.hLastCursor = plot(ILD_Canvas_System.axis, x,y, 'o', 'MarkerSize', ILD_PenDiameter_px*ILD_Canvas_System.dynamicDPI, 'MarkerEdgeColor', 'red');
        %hold(ILD_Canvas_System.axis, 'off');
       
    end

    function someFasterClickCallback(varargin)
        disp('Yes')
        currpos = get(ILD_Canvas_System.figure, 'CurrentPoint');
        x = round(ILD_RawDataSize(2) * currpos(1));
        y = round(ILD_RawDataSize(1) * (1-currpos(2)));
        
        disp(['Here:' num2str([x y])])
        
        filledCircle = im_generate_circle(size(ILD_Mask), ILD_PenDiameter_px, x, y, 'fill');
        ILD_MaskSaved = false;
        ILD_Mask(filledCircle==1) = ILD_PenMode;
        
        someCanvasRedraw();
    end

    function someCanvasRedraw(varargin)
        % constuct overlay
        if ILD_MaskVisible
            blend = im_coloring(ILD_RawData(:,:,ILD_CurrFrameInternal), ILD_Mask, ILD_MaskColor, 'full');
        else
            blend = repmat(ILD_RawData(:,:,ILD_CurrFrameInternal), [1,1,3]);
        end
        set(ILD_Canvas_System.canvas, 'CData', blend);
    end

end

