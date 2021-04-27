function ok = save_stack_as_tiff_folder(data, folderPath, fileprefix, description)
%SAVE_STACK_AS_TIFF_FOLDER save a 3-D matrix into a pile of tiff files in folderPath folder
%   OK = SAVE_STACK_AS_TIFF_FOLDER(DATA, FOLDERPATH, FILENAMEPREFIX) saves each frame of data
%   to a tiff file in FOLDERPATH. FILEPREFIX is the naming prefix for saving tiff files.
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

if nargin < 4, description = ''; end

fid = fopen(fullfile(folderPath, 'test.tiff'), 'w');
if fid == -1
    disp([mfilename ': cannot open ' folderPath ' for writing']);
    return
end
fclose(fid);
delete(fullfile(folderPath, 'test.tiff'));

%% type check (tiff is kind of annoying)
if isfloat(data) 
    disp([mfilename ': grayscale detected']);
elseif class(data) == 'uint16'
    warning([mfilename ': uint16 detected, make sure it is fitting that range']);
    disp([mfilename ': program will continue']);
end

%% go them

try
    nFrames = size(data,3);
    
    for frm = 1:nFrames
        framedata = data(:,:,frm);  % no need to permute this; imwrite does it well
        fname = sprintf('%s%05d.tiff', fileprefix, frm);
        desc = sprintf('%s Frame %d/%d', description, frm, nFrames);
        imwrite(framedata, fullfile(folderPath, fname), 'tiff', 'Description', desc);
        ok = frm;
    end
    disp([mfilename ': stack matrix "' inputname(1) '" saved to ' folderPath]);
catch
    warning([mfilename ': an error occured while writing file.']); 
    disp([mfilename ': stack matrix PARTIALLY saved (' num2str(frm) ')']);
end
end
