function [trace, stats] = trace_extract_trial(data, roimap, params)
%TRACE_EXTRACT_TRIAL extract brightness changes in one trial for all ROIs
%   [TRACE, STATS] = TRACE_EXTRACT_TRIAL(BLOCK, ROIMAP, PARAMS) extract traces of all ROIs
%   defined in ROIMAP from BLOCK, and returns TRACE the normalised traces (using baseline 
%   window defined in PARAMS) as well as STATS the statistics about traces (requested in
%   PARAMS).
% Inputs:
%   BLOCK       an image stack of one trial
%   ROIMAP      a labelled image of the same height & width with BLOCK
%   PARAMS      a struct consisting of:
%               useGPU - use GPU for calculation (default=1).
%               baseline  - [compulsory] two values indicating the frames of baseline. For 
%                   example, BLOCK is 50 fps video, and baseline in the experiment was
%                   designed as the first second in the trial (stimulus given at 1 sec),
%                   then this value should be [50*0+1,50*1] or [1,60]. This parameter 
%                   is required for TRACE_EXTRACT_TRIAL to work.
%               stats - char or cell array of char containing statistics requests to be
%                   performed. Results of these analyses will be stored in STATS. Valid
%                   options are 'original' (keep original trace), 'stdev' (standard
%                   deviation of trace), 'max' (maximum value), 'auc' (area under curve).
%                   Unrecognised requests will be ignored.
% Output:
%   TRACE       normalised trace of all ROIs
%   STATS       a struct containing statistical results requested by PARAMS.stats.
%               Possible fieldnames of this struct are 'original', 'stdev', 'max', 'auc'.
%
%   This function needs PARAMS.baseline to work. For baseline-free calculations of
%   activity, check out TRACE_EXTRACT_CONTINUOUS.
%
%   See also TRACE_EXTRACT_CONTINUOUS, TRACE_SORT.

%   Written by Weihao Sheng, 2019-08-21
%   Yang Yang's Lab of Neural Basis of Learning and Memory,
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% version(date) & changes
%   20190821 first version ---weihao
%   20200422 branched from original code and modified for one single trial ---weihao
%   20200517 add statistics support ---weihao

gpuArray = @(x) x;

[height, width, nFrames] = size(data); nPixels = height * width;
data = reshape(data, [nPixels, nFrames]); 
roimap = reshape(roimap, [nPixels, 1]); nROIs = max(roimap);

fps = get_option(params, 'FPS', 15);
if isempty(fps), error([mfilename, ': fps not defined.']); end
baseline = get_option(params, 'Baseline', []); 
if isempty(baseline), error([mfilename, ': baseline not defined.']); end
baseline = baseline .* fps + [1 0];


    traceOriginal = gpuArray(zeros(nROIs, nFrames));
    for roi = 1:nROIs
        traceOriginal(roi,:) = mean(data(roimap==roi, :),1);
    end
    F0 = mean(traceOriginal(:, baseline(1):baseline(2)), 2);
    trace = (traceOriginal - F0) ./ F0;

statoptions = get_option(params, 'stats', '');
stats = [];
    if any(contains(statoptions, 'original')),  stats.original = traceOriginal; end
    if any(contains(statoptions, 'stdev')),     stats.stdev = std(trace,[],2); end
    if any(contains(statoptions, 'max')),       stats.max = max(trace, [], 2); end
    if any(contains(statoptions, 'auc')),       stats.auc = cumsum(trace, 2); end

end

  