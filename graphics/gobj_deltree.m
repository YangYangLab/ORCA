function exception = gobj_deltree(gobj)
%GOBJ_DELETE_BRANCHES Delete all children GraphicalObjects of a GraphicalObject
%
%   See also DELETE, GOBJ_SETCHILDREN, GOBJ_DELTREE.

%   Weihao Sheng, 2020-09-03
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

try
    exception = gobj_delchildren(gobj);
    delete(gobj_delchildren);
catch ME
    warning([mfilename ':' ME.message])
    exception = [exception ME];
end
end