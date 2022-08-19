function data = read_images_raw(filePath, width_x, height_y, datatype, maxframes)
%read a raw file into current workspace
%   DATA = read_images_raw(FILEPATH, WIDTH, HEIGHT, DATATYPE) 
%       loads the raw file at FILEPATH, with WIDTH (px) and HEIGHT(px), each pixel is of DATATYPE type
%       DATATYPE can be uint8, uint16, uint32, single, etc.
%       returns loaded [height, width, nFrames] matrix.
%   ... = read_images_raw(..., maxframes) 
%       defines maximum frames to read

%% input check?

if nargin <= 4, maxframes = 10000; end

fid = fopen(filePath, 'r+');
if fid == -1
    error(['cannot load file ' filePath]);
end

data = zeros(height_y, width_x, 0, datatype);
try
    fid = fopen(filePath, 'r+');
    if fid == -1
        error(['IO error, cannot load file ' filePath]);
    end
    blocksize = width_x*height_y;
    kframe = 0;
    while ~feof(fid) && kframe<maxframes
        block = fread(fid, blocksize, ['*' datatype]);
        if isempty(block) 
            % end of file
            break;
        elseif length(block)<blocksize 
            % some data left at the end of this file, which is weird and should catch my
            % attention
            warning(['residual data left at the end of this file (' num2str(length(block)) ' bytes), ignoring']);
            break; 
        end 
        kframe = kframe + 1;
        thisframe = permute(reshape(block, [width_x, height_y]), [2 1]);
        data = cat(3, data, thisframe); 
    end
    fclose(fid);
catch ME
    if fid>-1, fclose(fid); end
    warning(ME.identifier, 'an error occured while loading file:\n%s', ME.message); 
end
fprintf('%d frames loaded.\n', kframe);
end