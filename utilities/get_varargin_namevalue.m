%GET_VARARGIN_NAMEVALUE 
%   NOT A FUNCTION -- this allows it to access the current workspace
%
%   get the Name-Value pair in varargin and put them in current workspace

%   Weihao Sheng, 2019-11-30
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

for karg = 1:2:length(varargin)
    eval([varargin{karg} ' = varargin{karg+1};']);
end