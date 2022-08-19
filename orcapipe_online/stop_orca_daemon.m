function stop_orca_daemon()
% ORCA should be in active mode, watching file change on disk

global ORCA

if isempty(ORCA.workspace{2})
    warning('no running daemon')
    return
end

disp('stopping daemon\n');
obsv = ORCA.workspace{2}(1); resp = ORCA.workspace{2}(2);
[obsv, resp] = ORCA.method.watchdog('stop', obsv, resp);
ORCA.workspace{2} = [];

