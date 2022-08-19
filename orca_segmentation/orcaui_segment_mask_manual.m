function mask = orcaui_segment_mask_manual(data, TRIALDEF, ACQ, varargin)
% ORCA's manual segmentation UI
%   MASK = orca_segment_mask_Amplifier(DATA, TRIALDEF, ACQ)
%       manually segment masks by drawing circles over playing frames

%   Weihao Sheng, 2020-05-09
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

global ILD_PreLoadMode
global ILD_RawFile    
global ILD_RawData    
global ILD_RawDataSize
global ILD_nTrials    
global ILD_TrialFrames
global ILD_FPS        

global ILoveDrawingOutput

ILD_PreLoadMode = true;
ILD_RawFile = '';
ILD_RawData = data; 
ILD_RawDataSize = size(data);
ILD_FPS = ACQ.fps;
ILD_TrialFrames = ACQ.fps*TRIALDEF.duration(2);
ILD_nTrials = fix(ILD_RawDataSize(3)/ILD_TrialFrames);

disp('Continue in ILoveDrawing (UI)...')
uiwait(ILoveDrawing);

mask = ILoveDrawingOutput;