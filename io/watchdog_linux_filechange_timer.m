classdef watchdog_linux_filechange_timer < handle
    properties
        Enabled
        filepath
        callback
    end

    properties (Access = private)
        file_last_datenum
        CheckChangeClock
        WaitChangeFinalizeClock
    end

    methods
        function obj = watchdog_linux_filechange_timer(filepath, callback, fps)
            
            obj.CheckChangeClock = timer('Name', 'FileChangeWatcher', 'Period', 0.5, 'ExecutionMode', 'fixedRate', 'BusyMode', 'drop');
            obj.CheckChangeClock.TimerFcn = @(~,~) obj.Tick();
            
            obj.filepath = filepath;
            obj.callback = callback;
            obj.file_last_datenum = 0;
            obj.Enabled = true;

            obj.WaitChangeFinalizeClock = timer('Name', 'FileChangeConfirm', 'Period', 1.2/fps, 'ExecutionMode', 'fixedRate', 'BusyMode', 'drop');
            obj.WaitChangeFinalizeClock.TimerFcn = @(~,~) obj.WaitChangeFinalize();
            obj.WaitChangeFinalizeClock.StopFcn = @(~,~) obj.FileChanged();
        end

        function start(obj)
            obj.Enabled = true;
            try
                stop(obj.WaitChangeFinalizeClock);
            catch
            end
            try
                start(obj.CheckChangeClock);
            catch
            end            
        end

        function stop(obj)
            obj.Enabled = false;
            try
                stop(obj.WaitChangeFinalizeClock);
            catch
            end
            try
                stop(obj.CheckChangeClock);
            catch
            end
        end

        function delete(obj)
            delete(obj.WaitChangeFinalizeClock)
            delete(obj.CheckChangeClock)
            delete(obj)
        end

        function Tick(obj)
            if ~obj.Enabled, return; end
            f = dir(obj.filepath);
            if f.datenum > obj.file_last_datenum
                stop(obj.CheckChangeClock);
                fprintf('file change detected @ %s\n', datestr(now))
                start(obj.WaitChangeFinalizeClock);
            end
        end

        function WaitChangeFinalize(obj)
            if ~obj.Enabled, return; end
            f = dir(obj.filepath);
            if f.datenum > obj.file_last_datenum
                % update file time
                obj.file_last_datenum = f.datenum;
            else
                % file is no longer changing
                stop(obj.WaitChangeFinalizeClock);
            end
        end

        function FileChanged(obj)
            if ~obj.Enabled, return; end
            
            obj.Enabled = false;
            fprintf('file changed @ %s\n', datestr(now))
            obj.callback();
            obj.Enabled = true;
            
            disp('done')
            
            start(obj.CheckChangeClock);
        end

    end
end
