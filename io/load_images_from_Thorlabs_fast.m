function status = loadThorlabsRecent(filePath, lastnFrames)
%loadThorlabsRecent  read Thorlabs raw file into memory

global ORCA

try
    fid = fopen(filePath, 'r+');
    if fid == -1
        error(['cannot load file ' filePath]);
        return
    end

    height_y = 512; width_x = 512; datatype = 'uint16';
    bytes2load = lastnFrames * height_y * width_x * 2;
    data = zeros(height_y, width_x, lastnFrames, datatype);

    status = fseek(fid, -bytes2load, 'eof');
    if status~=0
        error(['read file error ' filePath]);
    end
    data = fread(fid, bytes2load, datatype);
    fclose(fid);
    
    data = permute(reshape(data, height_y, width_x, lastnFrames), [2 1 3]);
        
    ORCA.Data = data;
    disp([mfilename ': recent trial loaded.']); 
    status = 0;
catch ME
    if fid>-1, fclose(fid); end
    warning(ME.identifier, 'an error occured while loading file:\n%s', ME.message); 
    status = -1;
end    
