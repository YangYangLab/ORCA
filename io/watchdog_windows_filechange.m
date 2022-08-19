function [observe_obj, respond_obj] = watchdog_windows_filechange(opt, varargin)
% Watchdog function for Windows file change
%   [OBSERVE, RESPOND] = watchdog_windows_filechange('start', FILEPATH, CALLBACK)
%       starts an OBSERVE (FileSystemWatcher) object to watch FILEPATH change
%       notifies RESPOND object to call CALLBACK when the file changes
%   [] = watchdog_windows_filechange('resume', OBSERVE, RESPOND)
%   [] = watchdog_windows_filechange('pause', OBSERVE, RESPOND)
%   [] = watchdog_windows_filechange('stop', OBSERVE, RESPOND)

% Inspired by https://www.mathworks.com/matlabcentral/answers/9957-using-net-filesystemwatcher-to-listen-for-new-files
% For more about FileSystemWatcher, see https://docs.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher.

switch lower(opt)
case 'start'
    filepath = varargin{1}; % file to monitor
    callback = varargin{2}; % function handle
    [filedir, filename, filesuffix] = fileparts(filepath);
    filename = [filename filesuffix];

    observe_obj = System.IO.FileSystemWatcher(filedir);
    observe_obj.NotifyFilter = System.IO.NotifyFilters.LastWrite;
    observe_obj.Filter = filename;
    observe_obj.IncludeSubdirectories = false;
    respond_obj = addlistener(observe_obj, 'Changed', callback);
    observe_obj.EnableRaisingEvents = true;

case 'resume'
    try
        observe_obj = varargin{1}; respond_obj = varargin{2};
        respond_obj.Enabled = true;
        observe_obj.EnableRaisingEvents = true;
    catch

    end

case 'pause'
    try
        observe_obj = varargin{1}; respond_obj = varargin{2};
        observe_obj.EnableRaisingEvents = false;
        respond_obj.Enabled = false;
    catch

    end

case 'stop'
    try
        observe_obj = varargin{1}; respond_obj = varargin{2};
        observe_obj.EnableRaisingEvents = false;
        respond_obj.Enabled = false;
        delete(respond_obj)
        delete(observe_obj)
    catch
        
    end

end

end




