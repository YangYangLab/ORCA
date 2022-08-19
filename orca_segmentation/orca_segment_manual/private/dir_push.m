function dir_push(new_path)
%DIR_PUSH push current working directory to stack and cd to new path
%   DIR_PUSH(NEWPATH) puts current working directory to global variable
%   DIRSTACK and change directory to NEWPATH
%
%   See also DIR_POP.

%   Weihao Sheng, 2019-12-06
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

global DIRSTACK

if isdir(new_path)
    if isempty(DIRSTACK)
        DIRSTACK = {pwd};
    else
        DIRSTACK = [DIRSTACK {pwd}];
    end
    
    cd(new_path);
else
    disp([mfilename ': invalid directory ' new_path]);
end
end

