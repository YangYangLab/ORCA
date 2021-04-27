function [fileobj, listener] = ThorlabsFileWatcher(option, varargin)
%THORLABSFILEWATCHER File Change Watcher callback for Thorlabs Imaging System
%   option: 'init', 'watch', 'stop'
%   [FILEOBJ, LISTENER] = ThorlabsFileWatcher('init', FileURL)
%   

% Inspired by
%   https://www.mathworks.com/matlabcentral/answers/352051-errors-with-polling-directory-for-new-files-to-process#answer_277367
%   https://www.mathworks.com/matlabcentral/answers/9957-using-net-filesystemwatcher-to-listen-for-new-files

global ORCA

switch option
    case 'init'
        if isfield(ORCA.Online, 'ThorlabsFileWatcher') && ~isempty(ORCA.Online.ThorlabsFileWatcher)
            error([mfilename 'INIT: you need to stop your last FileWatcher to init a new one. \nTo watch another file, use ''update'' instead.']);
        end
        [pathstr] = fileparts(ORCA.Online.ImagesURL);
        fileobj = System.IO.FileSystemWatcher(pathstr);
        % Notify when the file changes
        fileobj.NotifyFilter = System.IO.NotifyFilters.LastWrite;
        fileobj.Filter = '*.tmp';
        fileobj.IncludeSubdirectories = true;
        listener = addlistener(fileobj, 'Changed', @cbFileChange);
        fileobj.EnableRaisingEvents = true;
        % write the global workspace
        ORCA.Online.ThorlabsFileWatcher = {fileobj, listener};
    case 'update'
        if isfield(ORCA.Online, 'ThorlabsFileWatcher') && ~isempty(ORCA.Online.ThorlabsFileWatcher)
            ThorlabsFileWatcher('stop');
            ThorlabsFileWatcher('init',varargin{:});
        else
            error([mfilename 'UPDATE: you need to have one FileWatcher to update.']);
        end
    case 'stop'
        if isfield(ORCA.Online, 'ThorlabsFileWatcher') && ~isempty(ORCA.Online.ThorlabsFileWatcher)
            delete(ORCA.Online.ThorlabsFileWatcher{2});
            fileobj = ORCA.Online.ThorlabsFileWatcher{1};
            fileobj.EnableRaisingEvents = false;
            delete(ORCA.Online.ThorlabsFileWatcher{1});
            ORCA.Online.ThorlabsFileWatcher = {};
        else
            % should be a warning
        end
        ORCA.Online.GObj.Text.String = 'Not working';
end

    function cbFileChange(obj, eData)
        fprintf('%s: file change %s\n', mfilename, char(eData.FullPath));
        ORCA.Online.ImagesURL = char(eData.FullPath);
        ORCA.Online.Processor{1}.FileChanged();
    end
end



