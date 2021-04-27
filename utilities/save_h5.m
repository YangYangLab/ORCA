function save_h5(data, h5file, chunkSize)
%% SaveH5  save raw matrix as H5 file in /data
% SAVEH5(DATA, H5FILE, chunksize) writes DATA into H5 file under "/data".

if ischar(data), data = eval(data); end % char means a global variable name

if isa(data, 'gpuArray'), data = gather(data); end
[height, width, nframes] = size(data);
if nargin<3, chunkSize = round(height/8); end

h5create(h5file,'/data',[height width, nframes],'ChunkSize',[chunkSize, chunkSize, nframes]);

for frm = 1:nframes
    h5write( h5file, '/data', data(:,:,frm), [1, 1, frm], [height, width, 1]);
end

end
