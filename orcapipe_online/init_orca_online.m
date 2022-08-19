function init_orca_online(showUI)
if nargin < 1, showUI = false; end

% ///// DONT touch these lines ///// 
clear global
global ORCA
% ///// DONT touch these lines /////

%% major definitions below

ORCA.Data = []; % you won't fill frame data here right?
ORCA.DataFile = ''; % if you are using active mode; see below
ORCA.DataDir = ''; % where ORCA writes data to

%% define online parameters
ORCA.TrialDef = struct( ...
    'baseline', [0 1],  ...
    'stimulus', [1 1.2],...
    'interest', [1 4],  ...
    'duration', [0 4]   ...
    );

ORCA.AcqDef = struct(...
    ... fluorescence indicator related
    'channels', 1,           ... all channels available
    'channels_color', [488,594], ...
    'dynamic_channel', 1,   ... use which channel    
    'dynamic_time', 1,      ... sec
    ... acquisition system related
    'height', 512,          ... px
    'width', 512,           ... px
    'fps', 15,              ... 
    'pixel_size', 0.528,    ... um
    'cell_diameter',  10    ... px
    );

%% choose online methods: data loader

% how to load data to ORCA.Data?
%
%   We have multiple ways to read data into ORCA (This is the start of EVERYTHING!). 
%
%   (1) If your imaging system has access to this MATLAB workspace (say, your imaging
%   software is MATLAB-based), then loading data is very easy! ORCA prepared a code snippet 
%   in io\load_images_from_memory.m. You just need to let 
%
%       ORCA.method.loader=@load_images_from_memory; 
%
%   and everything should be fine. ORCA will work in *PASSIVE* mode, waiting for callbacks.
%   
%   (2) Unfortunately your imaging software *DO NOT* have access to MATLAB, and the 
%   imaging software writes everything to disk. In this case you need MATLAB WATCHING for 
%   changes in some file or some folder. 
%
%   You need a file loader with a file change watcher (defined below), and ORCA will work
%   in *ACTIVE* mode (to monitor file change!). Also you need to call start_orca_daemon and 
%   stop_orca_daemon to start and stop watcher.

% --- data loader method
ORCA.method.loader = @load_images_from_Thorlabs_fast;
ORCA.methodparams.loader = {'D:\recording\20210923\', 0};

% --- data watcher method (only in active mode)
%   For Windows, use watchdog_windows_filechange
%   For Mac & Linux, use watchdog_linux_filechange
ORCA.method.watchdog = @watchdog_windows_filechange;

%% choose online methods: core functions
% register moving stacks?
% --- leave empty to disable registration:
ORCA.method.registration = [];
ORCA.methodparams.registration = {};

% --- or use @function_handle to define registration method:
%ORCA.method.registration = @orca_register_video_GPU;
%ORCA.methodparams.registration = {}; % <--- params explained? see the function 

% segmentation method?
% --- use which segmentation algorithm: amplifier (recommended, balanced performance)
ORCA.method.segmentation = @orca_online_segment_amplifier; 
ORCA.methodparams.segmentation = {'alpha', 2, 'sig', 1.5, 'thr', -1, 'minpix', 10};

% --- or use RE-based method (use when sparse and dim activity)
%     RenyiEntropy depends on Fiji and MIJ plugin. You need to follow guidelines here:
%     https://ww2.mathworks.cn/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab 
%
%ORCA.method.segmentation = @orca_online_segment_RE; 
%ORCA.methodparams.segmentation = {'alpha', 2, 'sig', 1.5, 'thr', -1, 'minpix', 10};
%addpath('C:\Fiji.app\scripts') % <-- set as your Fiji corresponding paths
%javaaddpath('C:\Program Files\MATLAB\R2017b\java\mij.jar')
%try
%    MIJ.exit
%catch
%end
%Miji(false)

% extract trace?
ORCA.method.traceextraction = @orca_trace_extract_dff;
ORCA.methodparams.traceextraction = {'sort', true}; % <--- params explained? see the function 

%% online functions: callback function for online processing
% --- define a full pipeline when new frames are acquired. You may modify and write your
%     own worker code to fit your pipelines. 
% Note: Postprocessing procedures like optogenetics or SLM are also included in this 
%     worker file as a demo. However if you just need the ROIs in passive mode, you can 
%     use ROIs directly as a returning variable of this worker. It is NOT necessary to put
%     postprocessings here inside the worker.

ORCA.worker = @orca_online_worker; 

%% online functions: user interface
% --- everything about UI. UIs are time-consuming, but user-friendly. You may also write
%     your own UIs and use it here.
%     By default UI is not used. But if you init_orca_online(true) then this will show up.

ORCA.showUI = showUI;
ORCA.method.uiworker = @orcaui_online_worker;
ORCA.methodparams.uiworker = {'YLim',[-0.5 3]};

ORCA.workspace = cell(1,10); % reserved, don't use this
if ORCA.showUI
    ORCA.method.uiworker('init'); 
end

end
