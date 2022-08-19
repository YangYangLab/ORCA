function data = read_images_tiffs(folderpath, filename_regexp, maxframes)
%read a sequence of tiff files
%   DATA = read_images_tiffs(FOLDERPATH, FILENAME_REGEXP) 
%       loads tiff files located in FOLDERPATH, tiff names containing FILENAME_REGEXP
%   ...  = read_images_tiffs(..., MAXFRAMES) 

%   Weihao Sheng, 2021-03-05
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

if nargin<3, maxframes = 100000; end

files = dir(folderpath); 
filepick = cellfun(@(x)~isempty(x), regexpi({files.name}, filename_regexp));
files = sort({files(filepick).name});

data = [];
kframes = 0;
try
    for idx = 1:length(files)
        kframes = kframes + 1;
        thisframe = imread(fullfile(folderpath, files{idx}));
        data = cat(3, data, thisframe);
        if kframes >= maxframes, break; end
    end
catch ME
    warning(ME.identifier, 'an error occured while loading folder:\n%s', ME.message); 
end
fprintf('%d frames loaded.\n', kframe);
end
