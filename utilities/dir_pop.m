function dir_pop
%DIR_POP pop a path from DIRSTACK and set it as current directory
%   DIR_POP takes the top path in DIRSTACK, removes it in stack, and 
%   change directory to the path just popped
%
%   See also DIR_PUSH.

%   Weihao Sheng, 2019-12-06
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

global DIRSTACK

if ~isempty(DIRSTACK)
    old_path = DIRSTACK{end};
    DIRSTACK{end} = [];
    cd(old_path);
else
    warning ([mfilename ': nothing to pop.']);
end
end

