function [trace, stats] = trace_extract_multiple_trials(data, roimap, trialstruct)
%TRACE_EXTRACT_TRIAL extract brightness changes in one trial for all ROIs
%   [TRACE, STATS] = TRACE_EXTRACT_TRIAL(BLOCK, ROIMAP, trialstruct) extract traces of all ROIs
%   defined in ROIMAP from BLOCK, and returns TRACE the normalised traces (using baseline 
%   window defined in PARAMS) as well as STATS the statistics about traces (requested in
%   PARAMS).
% Inputs:
%   BLOCK       an image stack of one trial
%   ROIMAP      a labelled image of the same height & width with BLOCK
%   TRIALSTRUCT 
%               Baseline  - [MUST-HAVE] two values indicating the frames of baseline. For 
%                   example, BLOCK is 50 fps video, and baseline in the experiment was
%                   designed as the first second in the trial (stimulus given at 1 sec),
%                   then this value should be [50*0+1,50*1] or [1,60]. This parameter 
%                   is required for TRACE_EXTRACT_TRIAL to work.
%               
%               stats - char or cell array of char containing statistics requests to be
%                   performed. Results of these analyses will be stored in STATS. Valid
%                   options are 'original' (keep original trace), 'stdev' (standard
%                   deviation of trace), 'max' (maximum value), 'auc' (area under curve).
%                   Unrecognised requests will be ignored.
%               GPU - use GPU for calculation (default='Off').
% Output:
%   TRACE       normalised trace of all ROIs
%   STATS       a struct containing statistical results requested by PARAMS.stats.
%               Possible fieldnames of this struct are 'original', 'stdev', 'max', 'auc'.
%
%   This function needs PARAMS.baseline to work. For baseline-free calculations of
%   activity, check out TRACE_EXTRACT_CONTINUOUS.
%
%   See also TRACE_EXTRACT_CONTINUOUS, TRACE_SORT.

%   Written by Weihao Sheng, 2020-04-23
%   Yang Yang's Lab of Neural Basis of Learning and Memory,
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% version(date) & changes
%   20200423 branched from trial code and modified for multiple trials ---weihao
%   20200517 add statistics support ---weihao

global ORCA
if isfield(ORCA, 'GPU'), shouldiusegpu = strcmpi(ORCA.GPU, 'on'); else, shouldiusegpu = 0; end
if ~shouldiusegpu, gpuArray = @(x) x; end 

trialstruct.Baseline; trialstruct.Duration;
if ~isfield(trialstruct, 'FPS'), trialstruct.FPS = 15; end
if ~isfield(trialstruct, 'Frames'), trialstruct.Frames = 15; end

trialstruct.Baseline = fix(trialstruct.Baseline .* trialstruct.FPS) + [1 0];
trialstruct.Frames = trialstruct.Duration * trialstruct.FPS;

[height, width, nFrames] = size(data); nPixels = height * width; 
data = reshape(data, [nPixels, nFrames]); 
roimap = reshape(roimap, [nPixels, 1]); 
nROIs = max(roimap);

    trace_original = gpuArray(zeros(nROIs, nFrames));
    for roi = 1:nROIs
        trace_original(roi,:) = mean(data(roimap==roi, :),1);
    end

    trace_original = reshape(trace_original, [nROIs, trialstruct.Frames, nFrames/trialstruct.Frames]);
    F0 = mean(trace_original(:, trialstruct.Baseline(1):trialstruct.Baseline(2), :), 2);
    trace = (trace_original - F0) ./ F0;
    trace = reshape(trace, [nROIs, nFrames]);
    
end

  