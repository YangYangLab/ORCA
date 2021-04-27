function im = stack_zproject_mean_within_std(stk, fold)
%STACK_ZPROJECT_MEAN_WITHIN_STD Z-Project of a movie using average.
%   IM = STACK_ZPROJECT_MEAN_WITHIN_STD(STK, FOLD) reserves mean image
%
%   See also STACK_ZPROJECT_STDEV, MEAN.

%   Weihao Sheng, 2019-09-01
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

if nargin < 2, fold = 3; end
    
	im = mean(stk, 3);
    imstd = std( single(stk),0,3 );
    
    minimg = im - imstd.*fold; maximg = im + imstd.*fold;
    
    im ( im<minimg ) = minimg( im<minimg );
    im ( im>maximg ) = maximg( im>maximg );
   
    im = cast(im, class(stk));
end
