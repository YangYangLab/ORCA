function ok = save_stack_as_raw(data, filePath, bpp)
%SAVE_STACK_AS_RAW save a matrix into a .raw file
%   OK = SAVE_STACK_AS_RAW(DATA, FILEPATH, BPP) saves the DATA to FILEPATH using default
%   datatype of the DATA. 
%       DATA is a non-negative matrix.
%       BPP stands for BYTES PER PIXEL (1/2/4 for uint8/uint16/uint32). BPP value other
%       than 1/2/4 will be considered illegal and 16-bit as default will be used.
%
%   If any error happened while writing, OK will contain the amount of written data.
%
%   See also FWRITE.

%   Weihao Sheng, 2020-04-20
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

%% input check?
ok = 0;

fid = fopen(filePath, 'wb');
if fid == -1
    disp([mfilename ': cannot open file ' filePath ' for writing']);
    return
end

[~,filename,~] = fileparts(filePath);

bitcode = {'uint8','uint16','uint32'};
switch bpp
    case 1,     data = uint8(data);
    case 2,     data = uint16(data);
    case 4,     data = uint32(data);
    otherwise,  data = uint16(data); bpp = 2;
end

%% by now we should have file-height-width-maxframes-bpp

try
    data = permute(data, [2,1,3]);
    fwrite(fid, data, bitcode{bpp});
    fclose(fid);

    ok = size(data,3);
    disp([mfilename ': stack matrix "' inputname(1) '" saved to ' filePath]);
catch
    warning([mfilename ': an error occured while writing file.']); 
    disp([mfilename ': stack matrix NOT saved.']);
end
end
