function uiset_recursive(GraphicalObject, varargin)
%UISET_RECURSIVE Set Name to Value for a graphical object and all its children
%   UISET_RECURSIVE(GRAPHICALOBJECT, Name,Value) sets GRAPHICALOBJECT and all its
%   children's Name to Value. GRAPHICALOBJECT can be either figure, axes, panel, or
%   anything that has a 'Children' property.
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
    set(GraphicalObject, varargin{:});
    child = GraphicalObject.Children;
    for c = 1:length(child)
        set_recursive(child(c), varargin{:});
    end
catch e
    % whatever
end
end