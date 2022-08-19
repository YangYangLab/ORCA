function status = write_ROIs_to_Thorlabs_SLM(ROIs)
% This code is not available to public as it contains information about the source code of the proprietary Thorlabs Imaging Software ThorImage.
%
% A simple description of this file: 
%   1. each ROI is approximated as an elliptic;
%   2. it's center x & y position, semi-major & semi-minor axis are calculated
%   3. an XML file in ThorImage's format is written containing the above information
%   4. Refresh ThorImage, and SLM pattern is instantly reconstructed to reflect newly defined ROIs.