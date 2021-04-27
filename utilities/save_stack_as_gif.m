function ok = save_stack_as_gif(data, folderPath, filename, params)
%SAVE_STACK_AS_GIF save a 3-D matrix into a GIF file in folderPath folder
%   OK = SAVE_STACK_AS_GIF(DATA, FOLDERPATH, FILENAME) saves data into a GIF file in
%   FOLDERPATH. FILENAME is the naming prefix for saving tiff files.
%   Files will be named as "FILEPREFIX00000.tif", so maximum frames would be 99999.
%
%   If any error happened while writing, OK will contain the amount of written data.
%
%   See also IMWRITE.

%   Weihao Sheng, 2020-04-26
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

%% input check?
ok = 0;

if nargin<4, params = []; end
fps = get_option(params, 'fps', 10); delaytime = 1/fps;

fid = fopen(fullfile(folderPath, 'test.gif'), 'w');
if fid == -1
    disp([mfilename ': cannot open ' folderPath ' for writing']);
    return
end
fclose(fid);
delete(fullfile(folderPath, 'test.gif'));

%% type check (gif treats)
if ndims(data) == 3
    if isfloat(data) 
        disp([mfilename ': grayscale detected']);
        convertfunc = @gray2ind;
    elseif isa(data,'uint16')
        warning([mfilename ': uint16 detected, make sure it is fitting that range']);
        disp([mfilename ': program will continue']);
        convertfunc = @gray2ind;
    end
elseif ndims(data) == 4 % height, width, nChannel, nFrame
    disp([mfilename ': rgb stacks currently not supported']);
    return
    convertfunc = @rgb2ind;
end

%% go them

try
    nFrames = size(data,3);
    fname = fullfile(folderPath, filename);
    
    framedata = data(:,:,1);
    [A,map] = convertfunc(framedata,256);
    imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',delaytime);
    for frm = 2:nFrames
        framedata = data(:,:,frm);  % no need to permute this; imwrite does it well
        [A,map] = convertfunc(framedata,256);
        imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',delaytime);
        ok = frm;
    end
    disp([mfilename ': stack matrix "' inputname(1) '" saved to ' folderPath]);
catch
    warning([mfilename ': an error occured while writing file.']); 
    disp([mfilename ': stack matrix PARTIALLY saved (' num2str(frm) ')']);
end
end
