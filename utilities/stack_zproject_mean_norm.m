function im = stack_zproject_mean_norm(mov)
%STACK_ZPROJECT_MEAN_NORM Z-Project of a movie using average statistics and normalisation
%   IM = STACK_ZPROJECT_MEAN_NORM(MOV) projects MOV onto the first two dimensions and
%   compress information on the third dimension using matlab mean()
%   function. IM will be the projected image.
%
%   See also STACK_ZPROJECT_STDEV, MEAN.

%   Weihao Sheng, 2019-09-01
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

    im = zeros(size(mov, 1), size(mov, 2));
    
    for idx = 1 : size(mov, 3)
        frm = mat2gray(mov(:,:,idx));
        im = im + frm;
    end
    
    im = im ./ idx;
end
