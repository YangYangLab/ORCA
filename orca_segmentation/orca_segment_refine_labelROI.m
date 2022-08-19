function rois = orca_segment_refine_labelROI(mask)
% label mask area to ROI id
%   ROIs = orca_segment_refine_labelROI(MASK)
%       returns cell array containing label maps

mapconn = bwconncomp(mask); 
labelimage = labelmatrix(mapconn);

nROIs = max(unique(labelimage));
rois = arrayfun(@(x) labelimage==x, 1:nROIs, 'UniformOutput', false);