function [f, ROIs] = orca_trace_extract_f(data, TRIALDEF, ACQ, ROIs, varargin)
% extract trace from ROI based on certain trial structure
%   f = orca_trace_extract_f(data, fBaseline, ROIs)
%       subtracts each ROI in DATA with its baseline (TRIALDEF.baseline) activity
%       returns subtracted fluorescence value 
%   ... = orca_trace_extract_f(..., 'gauss', 1)
%       apply gauss filter with sigma=1
%   ... = orca_trace_extract_f(..., 'sort', false)

p = inputParser; p.KeepUnmatched = true; p.CaseSensitive = false; p.PartialMatching = true;
addParameter(p, 'gauss', 1);
addParameter(p, 'sort', false); 
addParameter(p, 'debug', false);
parse(p, varargin{:})
p = p.Results;

[height, width, nFrames] = size(data);
fBaseline = TRIALDEF.baseline * ACQ.fps + [1 0]; fBaseline = floor(fBaseline(1)):ceil(fBaseline(2));

img_baseline = mean(data(:,:,fBaseline),3); 
img_baseline = imgaussfilt(img_baseline, p.gauss);
data = data - img_baseline;

data = reshape(data, [height*width nFrames]);
f = cellfun(@(map) data(reshape(map, [height*width 1]), :), ROIs, 'UniformOutput', false);
f = cellfun(@(traces) mean(double(traces), 1), f);

if p.sort
    [~,fsort] = sort(cellfun(@max, f));
    ROIs = ROIs(fsort); 
    f = f(fsort);
end