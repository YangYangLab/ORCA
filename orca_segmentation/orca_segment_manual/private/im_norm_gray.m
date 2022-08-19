function gray = im_norm_gray(im, cutoff)
%IM_NORM_GRAY normalize grayscale image or every frame in image stack.
%   GRAY = IM_NORM_GRAY(IM) converts a single-frame grayscale image IM, or 
%   image stack IM, to normalized grayscale image or image stack ranging 
%   from 0 to 1. The range of the output is determined by setting the 
%   maximum pixel value of all frames (the brightest point) as 1 in the
%   output, and the minimum pixel value of all frames (the darkest point)
%   as 0.
%
%   Currently we do not recommend using CUTOFF for performance issues.
%   GRAY = IM_NORM_GRAY(..., CUTOFF) allows user to give a range of
%   normalization (in percentage); values out of this percentage are
%   discarded (being either 0 or 1 in the output).
%   For example, you would like the brightest 5% of the pixels to be
%   totally white (1) in the output, you can specify CUTOFF as [0, 0.95].
%   If you only want the darkest 10% pixels to be totally black (0), set 
%   CUTOFF as [0.1, 1]. And certainly, you can use them together.
%
%   Using CUTOFF adds contrast to the image, but loses information on two 
%   tails. By default, IM_NORM_GRAY applies a normalization on these data
%   already, adding contrast without losing information; but if you want
%   more contrast and some info in the two tails are not that important
%   (for example in image display), you can use this. The choice is yours.
%   
%   For RGB version of this, see IM_NORM_RGB.
%
%   See also MAT2GRAY, IM_NORM_RGB.

%   Weihao Sheng, 2019-12-03
%   Yang Yang's Lab of Neural Basis of Learning and  Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

%% input check
narginchk(1,2)

[height, width, frames] = size(im);
if nargin < 2
    cutoff = [0, 1];
end

pixrange = [min(im(:)), max(im(:))];
minpix = range(pixrange)*cutoff(1) + pixrange(1);
maxpix = range(pixrange)*cutoff(2) + pixrange(1);

% performance update: frames more than 2000 will be stored in single type
% other than double --- weihao 2019.12.04
if frames <= 2000
    gray = double(im-minpix)./double(maxpix-minpix);
else
    gray = single(im-minpix)./single(maxpix-minpix);
end

gray (gray>1) = 1; gray (gray<0) = 0;   % force out of boundary values to be ok

end

