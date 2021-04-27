function oldDir = dir_add_subdirs(startDir)
%DIR_ADD_SUBDIRS add directory and its sub-dirs to matlab PATH
%   OLDDIR = DIR_ADD_SUBDIRS(STARTDIR) adds STARTDIR and all its sub-folders to MATLAB 
%   path when running this instance, and returns the previous full string of PATH as 
%   backup for the user. If you want path to be added automatically upon matlab start, 
%   please refer to preference settings in matlab.
%
%   See also PATH, ADDPATH, RMPATH.

%   Weihao Sheng, 2020-01-12
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

if nargout > 0, oldDir = path; end

disp([mfilename ': Adding ' startDir ' and subfolders to path']);

subs = SearchSubdirs(startDir);
for idx = 1:length(subs)
    addpath(subs{idx});
end
rehash;
end

function celllist = SearchSubdirs(thisDir)
    celllist = {thisDir};
    d = dir(thisDir);
    d = d([d.isdir] == 1); % leave only folders
    for idx = 1:length(d)
        if d(idx).name(1) ~= '.'
            % not a dot-started folder, neither ./.. (console thing) nor
            % hidden folder (*nix things). We will consider it a normal
            % folder for our program, but we don't care whether it's
            % accessible or not
            celllist = [celllist SearchSubdirs(fullfile(d(idx).folder, d(idx).name))];
        end 
    end
end

