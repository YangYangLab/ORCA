function sig = orca_infer_significance(ff, TRIALDEF, ACQ, siglevel)
% test if activity is significant by mean+n*std
%   sig = orca_infer_significance(f, TRIALDEF, ACQ)
%       computes mean and std in baseline
%       returns if peak activity is over mean+3*std
%   ... = orca_infer_significance(..., siglevel)
%       uses custom siglevel instead of 3

fBaseline = TRIALDEF.baseline * ACQ.fps + [1 0]; fBaseline = floor(fBaseline(1)):ceil(fBaseline(2));
fInterest = TRIALDEF.interest * ACQ.fps + [1 0]; fInterest = floor(fInterest(1)):ceil(fInterest(2));
if nargin<4, siglevel = 3; end

mean_bl = cellfun(@(f) mean(f(fBaseline)), ff);
std_bl = cellfun(@(f) std(f(fBaseline)), ff);
level_bl = mean_bl + siglevel .* std_bl;
peak_it = cellfun(@(f) max(f(fInterest)), ff);
sig = (peak_it > level_bl);
