%init_ORCA_online   add all functions to current path
% 
%   related to the following ORCA settings:
%       ORCA.RootPath

%   Weihao Sheng, 2020-03-22
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% Naming schemes:
%   variables, VariableLongNames, Struct.VarNames;
%   functions, some_functions, module_function_target

global ORCA
rootLocation = which(mfilename());
[rootPath, ~,~] = fileparts(rootLocation);

% graphics: plotting, ui, display etc
addpath(genpath([rootPath '/graphics']));
% utilities: assistant functions 
addpath(genpath([rootPath '/utilities']));
% image_registration: 
addpath(genpath([rootPath '/image_registration']));
addpath(genpath([rootPath '/mask_segmentation']));
addpath(genpath([rootPath '/trace_extraction']));
addpath(genpath([rootPath '/online_processing']));
% session and device specific: everything related to files and devices
addpath(genpath([rootPath '/session_manager']));

ORCA.RootPath = rootPath;
ORCA.Functions.ImageRegistration = 'register_stack_GPU';

online_init
online_with_slm