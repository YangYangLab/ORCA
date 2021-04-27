function exception = gobj_delchildren(gobj)
%GOBJ_DELETE_BRANCHES Delete all children GraphicalObjects of a GraphicalObject
%
%   See also DELETE, GOBJ_SETCHILDREN, GOBJ_DELTREE.

%   Weihao Sheng, 2020-09-03
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

exception = [];
try
    nchild = length(gobj.Children);
    for ch = nchild:-1:1
        if ~isempty(gobj.Children(ch).Children)
            exception = [exception gobj_delchildren(gobj.Children(ch))];
        end
        delete(gobj.Children(ch));
    end    
catch ME
    warning([mfilename ': ' ME.message])
    exception = [exception ME];
end
end