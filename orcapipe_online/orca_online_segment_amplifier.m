function ROIs = orca_online_segment_amplifier(data, TRIALDEF, ACQ, varargin)
% a choice function for different methods

p = inputParser; p.KeepUnmatched = true; p.CaseSensitive = false; p.PartialMatching = true;
addParameter(p, 'alpha', 2); % exponential factor
addParameter(p, 'significance', 1); % significance factor
addParameter(p, 'threshold_adjust', -1); % thresholding factor, for minor adjustment in amplify
addParameter(p, 'minpixels', ACQ.cell_diameter*ACQ.cell_diameter*pi/8); % ROI threshold 
addParameter(p, 'debug', false)
parse(p, varargin{:})
p = p.Results;

mask = orca_segment_mask_Amplifier(data, TRIALDEF, ACQ, p.alpha, p.significance, p.threshold_adjust);
mask = orca_segment_refine_sizing(mask, p.minpixels);
ROIs = orca_segment_refine_labelROI(mask);

end