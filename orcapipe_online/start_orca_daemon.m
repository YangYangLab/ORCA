function start_orca_daemon()
% ORCA should be in active mode, watching file change on disk

global ORCA

if ~isempty(ORCA.workspace{2})
    warning('stop existing daemon')
    stop_orca_daemon()
end

if ispc
    % use .Net System.IO.FileSystem on Windows
    fprintf('watching ORCA.DataFile using System.IO.FileSystem: %s\n', ORCA.DataFile);
    ORCA.method.watchdog = @watchdog_windows_filechange;
    [obsv, resp] = watchdog_windows_filechange('start', ORCA.DataFile, @(~,~) ORCA.worker('FileChanged') );
    ORCA.workspace{2} = [obsv, resp];

else
    % use timer on Mac or Linux
    fprintf('watching ORCA.DataFile using timer: %s\n', ORCA.DataFile);
    ORCA.method.watchdog = @watchdog_linux_filechange;
    watcher = watchdog_linux_filechange('start', ORCA.DataFile, @(~,~) ORCA.worker('FileChanged'), ORCA.AcqDef.fps);
    ORCA.workspace{2} = {watcher, []};
end
