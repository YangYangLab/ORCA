%% Quick-Start Guide for using ORCA in fully MATLAB environments
%    A typical processing pipeline of Calcium images involves registration, cell 
%    segmentation and trace extraction. ORCA is highly modular, and you can tailor ORCA to
%    what you see fit.

%% Use ORCA directly in an existing MATLAB program

%% --- 
% 1. Go to init_orca_online.m to give ORCA initialization parameters. It is well
%    documented and all options have an explanation. 
%    When you are done with that code, run the following line.

global ORCA
orca_init('online')

%% ---
% 2. It is totally possible to change ORCA.TrialDef and ORCA.AcqDef in the middle of
%    the way! 
%    ORCA.TrialDef defines timing information inside one trial. It is used for online
%    processing. The four parameters define a trial's temporal structure. Timing unit of
%    all temporal variables is second(s).
%    You can modify it here to fit your own trial settings.

ORCA.TrialDef = struct( ...
    'baseline', [0 1],  ...   when no stimulus is present, used as F0
    'stimulus', [1 1.2],...   when cue/stimulus is present
    'interest', [1 4],  ...   which time window might have Calcium activity
    'duration', [0 4]   ...   full length of a trial
    );


%    ORCA.AcqDef tells ORCA how the acquisition system is configured. It has two parts
%    inside: fluorescence indicator related & acquisition system related. Both groups of
%    parameters will affect how cell segmentation algorithms work.
%    Again you can change these parameters here. Some parameters are reserved for
%    potential future uses.

ORCA.AcqDef = struct(...
    ... fluorescence indicator related
    'channels', 1,           ... all channels available
    'channels_color', [488], ...
    'dynamic_channel', 1,   ... use which channel as calcium    
    'dynamic_time', 1,      ... sec
    ... acquisition system related
    'height', 512,          ... px
    'width', 512,           ... px
    'fps', 15,              ... 
    'pixel_size', 0.528,    ... um
    'cell_diameter',  10    ... px
    );

%% ---
% 3. Your imaging system is MATLAB-based, so it is totally possible that you can define
%    what happens after one trial is acquired. I believe you have read init_orca_online.m, 
%    so here please tell ORCA where to get your data. You may modify the code in 
%    load_images_from_memory.m directly.

% load data
load_images_from_memory();

% run pipeline
orca_online_worker('Refresh')

% get sorted ROIs 
ROIs = ORCA.result.ROIs;

%% --- 
% 4. With ROIs, you can do anything you want! You can write postprocessing codes in
% orca_online_worker.m directly, or you can put them somewhere you like.

%% Use individual ORCA components
%
%    ORCA is highly modular and you can use any combination of these modules! If you want
%    to know more about this, you may check out QS_API.m.
%
%    Enjoy using ORCA!