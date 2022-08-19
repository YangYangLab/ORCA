function [observe_obj, respond_obj] = watchdog_linux_filechange(opt, varargin)
% Watchdog function for linux file change
%   [OBSERVE, RESPOND] = watchdog_linux_filechange('start', FILEPATH, CALLBACK, FPS)
%       starts an timer object to watch FILEPATH change
%       notifies RESPOND object to call CALLBACK when the file changes
%   [...] = watchdog_linux_filechange('resume', OBSERVE, RESPOND)
%   [...] = watchdog_linux_filechange('pause', OBSERVE, RESPOND)
%   [...] = watchdog_linux_filechange('stop', OBSERVE, RESPOND)

switch lower(opt)
case 'start'
    filepath = varargin{1}; % file to monitor
    callback = varargin{2}; % function handle
    if nargin < 4, fps = 5; else, fps = varargin{3}; end
    observe_obj = watchdog_linux_filechange_timer(filepath, callback, fps);
    respond_obj = [];
    observe_obj.start();

case 'resume'
    observe_obj = varargin{1}; respond_obj = varargin{2};
    observe_obj.Enabled = true;
    observe_obj.start();

case 'pause'
    observe_obj = varargin{1}; respond_obj = varargin{2};
    observe_obj.Enabled = false;
    observe_obj.stop();
    
case 'stop'
    try
        observe_obj = varargin{1};
        observe_obj.delete();
    catch
        
    end
    observe_obj = []; respond_obj = [];
end

end