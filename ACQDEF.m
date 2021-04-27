% AcquisitionDefinition Helper File
% This file helps eliminate platform-differences between acquisition hardwares.
%
% AQ: AcquisitionDefinition, a struct variable
%
% --- most common settings
% AQ.FrameResolution_px
% AQ.FrameSize_um
% AQ.FrameRate
% AQ.PixelSize_um
% AQ.ScanDirection                % 1 Uni-direction; 2 Bi-directional
% AQ.ChannelsWavelength           % N-by-1 vector
% AQ.TotalFrames                  % int
% AQ.nFramesPerStim               % nFrames per stimulus
%
% --- how to process data
% AQ.DataFormat                   % 'raw', 'tif'/'tiff', ...
% AQ.DataBytes                    % 1 uint8, 2 uint16, ...
% AQ.DataProcessor                % code to process data. ORCA.Methods.LoadExperiment overtakes the job.
%
% --- things related to hardware. Might be helpful in the future
% AQ.Device.Software              % 
% AQ.Device.Lens.Name             % 
% AQ.Device.Lens.Zoom             %   
% AQ.Device.LSM.Name              % 
% AQ.Device.PMT.ChannelsGain      % N-by-1 vector
% --- some other things 
% AQ.Notes                        % Notes during acquisition (if possible)




