function [f, ROIs] = orca_trace_extract_dff(data, TRIALDEF, ACQ, ROIs, varargin)
% extract trace from ROI based on certain trial structure
%   f = orca_trace_extract_dff(data, TRIALDEF, ACQ, ROIs)
%       subtracts each ROI in DATA with its baseline (TRIALDEF.baseline) activity
%       returns subtracted fluorescence value 
%   ... = orca_trace_extract_dff(..., 'gauss', 1)
%       apply gauss filter with sigma=1
%   ... = orca_trace_extract_dff(..., 'sort', false)

p = inputParser; p.KeepUnmatched = true; p.CaseSensitive = false; p.PartialMatching = true;
addParameter(p, 'gauss', 1);
addParameter(p, 'sort', false); 
addParameter(p, 'debug', false);
parse(p, varargin{:})
p = p.Results;

data = double(data); [height, width, nFrames] = size(data);
fBaseline = TRIALDEF.baseline * ACQ.fps + [1 0]; 
fBaseline = floor(fBaseline(1)):ceil(fBaseline(2));

img_baseline = mean(data(:,:,fBaseline),3); 
img_baseline = imgaussfilt(img_baseline, p.gauss);
data = (data - img_baseline) ./ img_baseline;

data = reshape(data, [height*width nFrames]);
df = cellfun(@(mask) data(reshape(mask, [height*width 1]), :), ROIs, 'UniformOutput', false);
df = cellfun(@(traces) mean(traces, 1), df, 'UniformOutput', false);

if p.sort
    [~,fsort] = sort(cellfun(@max, df));
    ROIs = ROIs(fsort); 
    df = df(fsort);
end

f = zeros(length(ROIs), nFrames);
for x = 1:length(ROIs)
    f(x,:) = df{x};
end