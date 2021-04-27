function im = stack_zproject_std(stk)
%STACK_ZPROJECT_STD Z-Project of a movie using standard deviation.
%   IM = STACK_ZPROJECT_STD(MOV) projects MOV onto the first two dimensions and
%   compress information on the third dimension using matlab std()
%   function. IM will be the projected image.
%
%   See also STACK_ZPROJECT_MEAN, STD.

%   Weihao Sheng, 2019-09-01
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

	im = std(single(stk), 0, 3);
    
end
