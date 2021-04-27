function ILDdisp(something)
%ILDDISP show some lines if ILD_DEBUG is set on.
%   This is an internal function used by ILoveDrawing.
%
%   See also ILOVEDRAWING.

%   Weihao Sheng, 2019-12-02
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China
global ILD_DEBUG
if ILD_DEBUG
    disp(something); 
end
end

