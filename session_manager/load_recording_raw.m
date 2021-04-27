function data = load_recording_raw(filePath,width_x,height_y,maxframes,bpp,option)
%LOAD_RECORDING_RAW load a raw file into current workspace
%   DATA = LOAD_RECORDING_RAW(FILEPATH) 
%   loads the raw file FILEPATH, and prompt the user to tell the size of the raw file. 
%   DATA isa [width*height*frame] matrix of the file.
%   
%   DATA = LOAD_RECORDING_RAW(FILEPATH, WIDTH_X, HEIGHT_Y, FRAMES, BPP) loads 
%   the raw file according to the input parameters specified. BPP stands
%   for BYTES PER PIXEL (either 1 or 2). The prompt window will STILL show 
%   up with these parameters filled already, just for user confirmation. 
%   Partial inputs are allowed here.
%
%   DATA = LOAD_RECORDING_RAW(..., OPTIONS) allows to skip the user 
%   confirmation with OPTIONS '-quiet'.
%   
%   If any error happened before loading (e.g. user canceled/file not
%   accessible), DATA will be empty; if errored during loading (say, sudden 
%   File I/O error or corrupted file), DATA will contail the maximum 
%   available loaded data.
%
%   See also FOPEN.

%   Weihao Sheng, 2019-12-02
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

%% input check?
data = [];

fid = fopen(filePath, 'r+');
if fid == -1
    disp([mfilename ': cannot load file ' filePath]);
    return
end
fclose(fid);
[~,filename,~] = fileparts(filePath);

% param filling: width, height, maxframes, bpp
if nargin<6, option = ''; end
if nargin<5, bpp = 2; end
if (bpp~=1) && (bpp~=2)
    warning([mfilename ': invalid BPP input, using default value (16-bit)']); 
    bpp = 2; 
end
if nargin<4, maxframes = 6000; end
if nargin<3, height_y = 512; end
if nargin<2, width_x = 512; end

if ~strcmp(option, '-quiet')
    [width_x,height_y,maxframes,bpp] = prompt_for_params(filename,width_x,height_y,maxframes,bpp);
end
if isempty(height_y) || isempty(width_x) || isempty(maxframes) || isempty(bpp)
    disp([mfilename ': user canceled']);
    return
end

%% by now we should have file-height-width-maxframes-bpp
bitcode = {'uint8', 'uint16'};
try
    fid = fopen(filePath, 'r+');
    data = zeros(height_y, width_x, maxframes, bitcode{bpp});
    blocksize = width_x*height_y;
    kframe = 0;
    while ~feof(fid) && kframe<maxframes
        block = fread(fid, blocksize, ['*' bitcode{bpp}]);
        if isempty(block) 
            % end of file
            break;
        elseif length(block) < blocksize 
            % some data left at the end of this file, which is weird and should catch my
            % attention
            disp([mfilename ': residual data left at the end of this file (' num2str(length(block)) ' bytes), ignoring']);
            break; 
        end 
        kframe = kframe + 1;
        data(:,:,kframe) = permute(reshape(block, [width_x, height_y]), [2 1]);
    end
    fclose(fid);
    disp([mfilename ': ' num2str(kframe) ' frames loaded.']);
    data(:,:,kframe+1:end) = [];
catch
    warning([mfilename ': an error occured while loading file.']); 
end

% i think we are done here!
end

%% UI for param inputs, fold this! U don't need to see this! 
function [w,h,f,b] = prompt_for_params(filename,w,h,f,b)
% w-width, h-height, f-maxframe, b-bpp
uicWidth = 0.25;
XLocs = [0.125 0.5 0.75]; % 3 vert refz lines
uicHeight = 0.07;
YLocs = 0.9:-0.1:0.1; % 10 horz refz lines

winWidth = 200; winHeight = 300;

scrpos = get(0,'screensize');
fig = figure('Name', mfilename, ...
    'NumberTitle', 'off', 'ToolBar', 'none', 'MenuBar', 'none',...
    'Resize', 'off', 'Units', 'normalized', ...
    'Position', [0.5-winWidth/2/scrpos(3) 0.5-winHeight/2/scrpos(4) winWidth/scrpos(3) winHeight/scrpos(4)],... % 400x600 centered figure
    'Visible', 'off', 'HandleVisibility', 'Callback');
uicontrol('Parent', fig, ...
   'Units', 'normalized', 'Position', [XLocs(1) YLocs(1)-uicHeight uicWidth*3 uicHeight*2], ...
   'Style', 'text', 'String', ['Parameters for ' newline filename], 'FontSize', 10);
%width - x resolution
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(1) YLocs(3) uicWidth uicHeight], ...
    'Style', 'text', 'String', 'Width');
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(2) YLocs(3) uicWidth uicHeight], ...
    'Style', 'edit', 'Tag', 'width', 'String', num2str(w));
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(3) YLocs(3) uicWidth/2 uicHeight], ...
    'Style', 'text', 'String', 'px');
%height - y resolution
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(1) YLocs(4) uicWidth uicHeight], ...
    'Style', 'text', 'String', 'Height');
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(2) YLocs(4) uicWidth uicHeight], ...
    'Style', 'edit', 'Tag', 'height', 'String', num2str(h));
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(3) YLocs(4) uicWidth/2 uicHeight], ...
    'Style', 'text', 'String', 'px');
%frames
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(1) YLocs(5) uicWidth uicHeight], ...
    'Style', 'text', 'String', 'Frames');
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(2) YLocs(5) uicWidth*1.5 uicHeight], ...
    'Style', 'edit', 'Tag', 'frames', 'String', num2str(f));
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(1) YLocs(6) uicWidth*3 uicHeight], ...
    'Style', 'text', 'String', '(maximum frames to load)');
%bits
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(1) YLocs(7) uicWidth uicHeight], ...
    'Style', 'text', 'String', 'Bits');
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(2) YLocs(7) uicWidth*1.5 uicHeight], ...
    'Style', 'popupmenu', 'Tag', 'bits', 'String', {'8-bit', '16-bit'}, 'Value', b);
%OK / Cancel
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(1) YLocs(9) uicWidth*1.2 uicHeight], ...
    'Style', 'pushbutton', 'Tag', 'Confirm', ...
    'String', 'OK', 'Callback', @load_recording_internal_callback);
uicontrol('Parent', fig, ...
    'Units', 'normalized', 'Position', [XLocs(2)+uicWidth/3 YLocs(9) uicWidth*1.2 uicHeight], ...
    'Style', 'pushbutton', 'Tag', 'Cancel', ...
    'String', 'Cancel', 'Callback', @load_recording_internal_callback);

set(fig, 'Visible','on');
load_recording_internal_callback_answer = [];
uiwait(fig);

if isempty(load_recording_internal_callback_answer)
    h = []; w = []; f = []; b = [];
end
return

%% callbacks
    function load_recording_internal_callback(varargin)
        cboHandle = gcbo; tag = get(cboHandle, 'Tag');
        switch tag
            case 'Confirm'
                try
                    widthObj = findobj(fig, 'Tag', 'width');
                    w = str2num(get(widthObj, 'String'));
                    heightObj = findobj(fig, 'Tag', 'height');
                    h = str2num(get(heightObj, 'String'));
                    frameObj = findobj(fig, 'Tag', 'frames');
                    f = str2num(get(frameObj, 'String'));
                    bitsObj = findobj(fig, 'Tag', 'bits');
                    b = get(bitsObj, 'Value');
                    load_recording_internal_callback_answer = 'ok';
                    delete(fig)
                catch
                    uiwait(msgbox('You must give meaningful NUMBER inputs!','Angry Programmer','error','modal'));
                end
            case 'Cancel'
                delete(fig)
        end
        
    end

end