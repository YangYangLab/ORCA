function [trace, stats = trace_extract_continuous(data, roimap, params)
%TRACE_EXTRACT_CONTINUOUS extract brightness changes in a video
%   [TRACE, STATS] = TRACE_EXTRACT_CONTINUOUS(BLOCK, ROIMAP, PARAMS) extract traces of all ROIs
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

%   Written by Weihao Sheng, 2019-11-30
%   Yang Yang's Lab of Neural Basis of Learning and Memory,
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% version(date) & changes
%   20191130 first version ---weihao

outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

