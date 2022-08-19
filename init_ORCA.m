function init_orca(opt)
% initialization of ORCA, default for online
%   INIT_ORCA() or INIT_ORCA('online')
%   INIT_ORCA('online_noui')
%   INIT_ORCA('offline') 

oldpath = pwd;

cd(fileparts(which(mfilename)))
addpath('.');
addpath(genpath('./orca_registration'));
addpath(genpath('./orca_segmentation'));
addpath(genpath('./orca_trace_extraction'));
addpath(genpath('./orca_activity_inference'));
addpath(genpath('./orca_utils'));
addpath(genpath('./io'));

if nargin < 1, opt = ''; end

if strfind(lower(opt),'onlineui')
    disp 'Initializing ORCA online UI'
    addpath(genpath('./orcapipe_online'));
    init_orca_online(true)
    
elseif strfind(lower(opt),'offline')
    disp 'Initializing ORCA offline'
    addpath(genpath('./orcapipe_offline'));
    init_orca_offline()
    
else
    disp 'Initializing ORCA online (noUI)'
    addpath(genpath('./orcapipe_online'));
    init_orca_online(false)
    
end

cd(oldpath)
clear oldpath
