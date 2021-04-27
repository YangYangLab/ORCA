function trace = trace_extract_original(data, roimap, varargin)
%TRACE_EXTRACT_ORIGINAL extract raw brightness values recorded 
%   TRACE = TRACE_EXTRACT_ORIGINAL(BLOCK, ROIMAP, PARAMS) extract traces of all ROIs
%   defined in ROIMAP from BLOCK, and returns TRACE the normalised traces (using baseline 
%   window defined in PARAMS) as well as STATS the statistics about traces (requested in
%   PARAMS).
% Inputs:
%   BLOCK       either a stacked image, or chars containing the variable name of data
%               (used for big shared memory)
%   ROIMAP      a labelled image of the same height & width with BLOCK
%   PARAMS      a struct consisting of:
%               useGPU - use GPU for calculation (default=1).
%               baseline  - [compulsory] two values indicating the frames of baseline. For 
%                   example, BLOCK is 50 fps video, and baseline in the experiment was
%                   designed as the first second in the trial (stimulus given at 1 sec),
%                   then this value should be [50*0+1,50*1] or [1,60]. This parameter 
%                   is required for TRACE_EXTRACT_TRIAL to work.

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

global ORCA
if ischar(data), eval(['data = ' data]); end

[height, width, nFrames] = size(data); 
nPixels = height * width; % improve GPU efficiency, squeeze dim 1 & 2 into one dim
data = reshape(data, [nPixels, nFrames]); 
roimap = reshape(roimap, [nPixels, 1]); nROIs = max(roimap);

    trace = gpuArray(zeros(nROIs, nFrames));
    for roi = 1:nROIs
        trace(roi,:) = mean(data(roimap==roi, :),1);
    end




end

  