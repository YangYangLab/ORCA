function ok = save_screenshot(fig, filePath, fileType)
%SAVE_SCREENSHOT save an image
%   OK = SAVE_SCREENSHOT(FIGURE, FILEPATH, FILETYPE) saves the FIGURE to FILEPATH using 
%   default datatype of the FILEPATH. 
%
%   simple wrapper for imwrite.
%
%   See also IMWRITE.

%   Weihao Sheng, 2020-04-20
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China


ok = false;

if nargin<3, fileType = 'bmp'; end

gf = getframe(fig); 
data = gf.cdata;

try
    imwrite(data, filePath, fileType);
    disp([mfilename ': figure "' inputname(1) '" saved to ' filePath]);
    ok = true;
catch
    warning([mfilename ': an error occured while saving figure.']); 
end

end
