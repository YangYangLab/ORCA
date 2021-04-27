function [im] = stack_zproject_mean_contrast(stk)
%STACK_ZPROJECT_MEAN Z-Project of a movie using average statistics.
%   IM = STACK_ZPROJECT_MEAN(MOV) projects MOV onto the first two dimensions and
%   compress information on the third dimension using matlab mean()
%   function. IM will be the projected image.
%
%   See also STACK_ZPROJECT_STDEV, MEAN.

%   Weihao Sheng, 2019-09-01
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

	im = mean(stk, 3);
    im = imadjust(im);
end
