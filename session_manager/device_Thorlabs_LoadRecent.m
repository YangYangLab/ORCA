function status = ThorlabsLoadRecent( filePath )
%THORLABSLOADRECENT Summary of this function goes here
%   Detailed explanation goes here

global ORCA

if nargin < 1
    filePath = ORCA.Online.ImagesURL;
end
status = 1;
% read latest trial
bytes2load = ...
    ORCA.Experiment.Imaging.DataBytes * ...
    ORCA.Experiment.Imaging.Resolution(1) * ORCA.Experiment.Imaging.Resolution(2) * ...
    ORCA.Experiment.Trial.nFrames;
try
    fid = fopen(filePath, 'r');
    if fid == -1, disp([mfilename ': Failed opening file']); return; end
    fseek(fid, -bytes2load, 'eof');
    data = fread(fid, bytes2load, ORCA.Experiment.Imaging.DataPrecision);
    fclose(fid);
	data = permute(reshape(data, [ORCA.Experiment.Imaging.Resolution ORCA.Experiment.Trial.nFrames]), [2 1 3]);
    
    ORCA.Online.Images = data;
    disp([mfilename ': recent trial loaded.']); status = 0;
catch ME
    fprintf('%s ERROR: %s\n', mfilename, ME.message);   
end    
end

