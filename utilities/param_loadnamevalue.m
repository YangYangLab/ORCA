function params = param_loadnamevalue(varargin)
%PARAM_LOADNAMEVALUE get the Name-Value pair in varargin and put them in params

%   Weihao Sheng, 2020-02-01
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

params = struct();
for karg = 1:2:length(varargin)
    params.(varargin{karg}) = varargin{karg+1};
end

end