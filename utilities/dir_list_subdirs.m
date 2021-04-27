function subfolders = dir_list_subdirs(startDir)
%DIR_LIST_SUBDIRS add directory and its sub-dirs to matlab PATH
%   subfolders = DIR_LIST_SUBDIRS(STARTDIR) lists STARTDIR and all its sub-folders into 
%   cell array of chars containing full path to each folder.
%
%   See also DIR, PATH, DIR_PUSH, DIR_POP, DIR_ADD_SUBDIRS.

%   Weihao Sheng, 2020-01-12
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

subfolders = SearchSubdirs(startDir);
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
