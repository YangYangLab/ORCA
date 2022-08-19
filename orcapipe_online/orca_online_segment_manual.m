function ROIs = orca_online_segment_manual(data, TRIALDEF, ACQ, varargin)
% a wrapper function 

global ORCA

disp('you must be kidding to use manual drawing in online')

mask = orcaui_segment_mask_manual(data, TRIALDEF, ACQ, varargin{:});
ROIs = orca_segment_refine_labelROI(mask);
