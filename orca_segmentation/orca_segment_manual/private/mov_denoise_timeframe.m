function mov = mov_denoise_timeframe(delta)
%MOV_DENOISE_TIMEFRAME denoise a movie by averaging every 2*DELTA+1 frames
%   MOV = MOV_DENOISE_TIMEFRAME(DELTA) smooth a movie by averaging every
%   2*DELTA+1 frames in the movie. 

%   Weihao Sheng, 2020-01-17
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

mov = [];
global ILD_RawData
global ILD_RawDataSize
if isempty(ILD_RawData), return; end

% arg in check
if nargin<1, delta = 1; end % by default
if delta == 0, mov = ILD_RawData; return; end

nFrames = ILD_RawDataSize(3);
mov = zeros(ILD_RawDataSize);

% start averaging
%first part: gradual average
for idx = 1:delta
    mov(:,:,idx) = mean(ILD_RawData(:,:,1:idx), 3);
end
%in the middle part: gradual average
for idx = delta+1:nFrames-delta
    mov(:,:,idx) = mean(ILD_RawData(:,:,idx-delta:idx+delta), 3);
end
%last part: gradual average
for idx = nFrames-delta:nFrames
    mov(:,:,idx) = mean(ILD_RawData(:,:,idx:nFrames), 3);
end

end
