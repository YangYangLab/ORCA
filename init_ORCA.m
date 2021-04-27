%init_ORCA   add all functions to current path
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
ORCA.RootPath = rootPath;

% session and device specific: everything related to files and devices
addpath(genpath([rootPath '/session_manager']));
ORCA.Methods.LoadExperiment = 'load_experiment_Thorlabs';
ORCA.Methods.LoadData = 'load_recording_raw';

% image_registration
addpath(genpath([rootPath '/image_registration']));
ORCA.Methods.ImageRegistration = 'register_stack_GPU';

% mask_segmentation
addpath(genpath([rootPath '/mask_segmentation']));
ORCA.Methods.ImageRegistration = 'register_stack_GPU';

% trace_extraction
addpath(genpath([rootPath '/trace_extraction']));

% graphics & utilities: plotting, ui, display etc
addpath(genpath([rootPath '/graphics']));
addpath(genpath([rootPath '/utilities']));

%%%%%%%% ORCA variable structure %%%%%%%%
% .RootPath
%
% --- Methods to use
% .Methods.ImageRegistration = 'register_stack_GPU';
% .Methods.LoadExperiment
% 
% --- Experiment space
% .Experiment.Trial                % trial settings, TASKDEF.Trial
% .Experiment.Session              % trial settings, TASKDEF.Session
% .Experiment.Imaging              % acquisition settings, ACQDEF
% .Experiment.Stimulation          % stimulation descriptions, TASKDEF.Stim
%
%
% --- Online workspace
% .Online.Functions.Main                % function to call in online mode
% .Online.ImagesURL = ' ';
% .Online.Images = []; % where images 
% .Online.Callback.FileWatcher = 'ThorlabsFileWatcher';
% .Online.LoadDataOnline = 'ThorlabsLoadRecent';
% .Online.SLMControl = 'ThorlabsWriteSLM';
% .Online.UseGPU

