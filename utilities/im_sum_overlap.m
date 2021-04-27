function y = im_sum_overlap(x, m, shape)
%IM_SUM_OVERLAP - calculate all sums of dot product of two areas when overlapping
%   computes all sums of dot porducts of possible overlapping areas between two images.
%   This function is just another IM_CONVFFT, but M will be rotated 180 degrees 
%   automatically to calculate all sums of dot products.
%   
%   Y = IM_SUM_OVERLAP(X, M, SHAPE).
%
%   See also IM_CONVFFT.

%   Weihao Sheng, 2020-04-24
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

narginchk(2,3);
if nargin < 3, shape = 'valid'; end

m = m(end:-1:1, end:-1:1);

y = im_convfft(x,m,shape);

end
