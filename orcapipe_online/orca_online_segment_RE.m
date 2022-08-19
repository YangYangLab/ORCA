function ROIs = orca_online_segment_amplifier(varargin)
% a wrapper function 

global ORCA

disp('This function is still buggy, generates a lot of Fiji figures')
mask = orca_segment_mask_RenyiEntropy(ORCA.Data, ORCA.TrialDef, ORCA.AcqDef, varargin{:});
ROIs = orca_segment_refine_labelROI(mask);
