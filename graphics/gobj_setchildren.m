function gobj_setchildren(GraphicalObject, varargin)
%GOBJ_SETCHILDREN Set Name to Value for a graphical object and all its children
%   GOBJ_SETCHILDREN(GRAPHICALOBJECT, Name,Value) sets GRAPHICALOBJECT and all its
%   children's Name to Value. GRAPHICALOBJECT can be either figure, axes, panel, or
%   anything that have 'Children' property.
%
%   See also set.

%   Weihao Sheng, 2019-12-22
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

set_recursive(GraphicalObject, varargin{:})
end

function set_recursive(GraphicalObject, varargin)
if isempty(GraphicalObject), return; end
try
    child = GraphicalObject.Children;
    for c = 1:length(child)
        set_recursive(child(c), varargin{:});
    end
    % set Children first, so that errors this step wont affect its children
    set(GraphicalObject, varargin{:});
catch e
    % maybe such attribute do not exist or whatever
    % doesnt matter
end
end