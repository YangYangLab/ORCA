%% Quick-Start Guide for using ORCA with other programs
%    A typical processing pipeline of Calcium images involves registration, cell 
%    segmentation and trace extraction. ORCA is highly modular, and you can tailor ORCA to
%    what you see fit.

%% Use ORCA with third-party programs

%% ---
% 0. Many people use commercial imaging systems that come with their own controlling
%    softwares, most of which are not MATLAB-based. Two major troubles caused by this are
%    input and outputs: (1) it is hard to get newly acquired frames from another program's
%    memory, and (2) it is hard to tell another program the output of ORCA.
%
%    To circumvent this conditions, ORCA uses file systems to communicate with other
%    programs. Inputs (raw images) stored on disk are loaded into ORCA, and ORCA's outputs
%    are written to files as well. For "closed-loop" to work, ORCA needs to constantly
%    monitor changes in certain file/folder so that ORCA can be notified instantly of new
%    frames taken.
%    

%% --- 
% 1. Go to init_orca_online.m to give ORCA initialization parameters. It is well
%    documented and all options have an explanation. 
%    When you are done with that code, run the following line.

global ORCA
init_orca('online')

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
    'channels_color', [488,594], ...
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
% 3. Your imaging system is NOT MATLAB-based, so let's setup and start a daemon program.
%    This daemon program automatically runs the pipeline once file changes have been
%    detected on your disk. You need to define where your data is stored, and how to read
%    it.
% 
%    ORCA allows raw-file and tiff-folder reading by default, and you can implement your
%    own file reader as well. You can replace the loader to @read_images_raw or 
%    @read_images_tiff. You can also view load_images_from_Thorlabs_fast.m to see how to
%    load latest frames from the same file/folder.

ORCA.DataFile = '';
ORCA.method.loader = @load_images_from_Thorlabs_fast;
ORCA.methodparams.loader = {'D:\recording\20210923\', 0};

%% --- 
% 4. Now start the daemon and all should be automatic. In the demo orca_online_worker,
%    ROIs and traces are automatically saved to timestamped filenames. You can view and
%    change orca_online_worker.m to put your postprocessing code inside.

% start daemon
start_orca_daemon();

% to stop online process:
stop_orca_daemon();


%% Use individual ORCA components
%
%    ORCA is highly modular and you can use any combination of these modules! If you want
%    to know more about this, you may check out QS_API.m.
%
%    Enjoy using ORCA!