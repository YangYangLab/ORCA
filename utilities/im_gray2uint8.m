function out = im_gray2uint8(im)
%IM_GRAY2UINT8 convert grayscale image/image-stack to uint8
%   GRAY = IM_NORM_GRAY(IM) converts a single-frame grayscale image IM, or 
%   image stack IM, to normalized grayscale image or image stack ranging 
%   from 0 to 1. The range of the output is determined by setting the 
%   maximum pixel value of all frames (the brightest point) as 1 in the
%   output, and the minimum pixel value of all frames (the darkest point)
%   as 0.
%
%   See also IM_NORM_GRAY, IM2UINT8.

%   Weihao Sheng, 2019-12-05
%   Yang Yang's Lab of Neural Basis of Learning and  Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

out = uint8(round(im.*255));
end

