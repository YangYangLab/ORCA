function status = gcanvas_align(gchild,cvspos)
%GCANVAS_ALIGN align Graphical Objects onto pre-defined grids
%   GOBJ = GCANVAS_ALIGN(GPARENT, GCHILD, CANVASPOSITION) sets GPARENT as parent of GCHILD
%   and align it onto grids of CANVASPOSITION.
%   CANVASPOSITION is a vector of [x(left), y(top), width, height] and their units are 
%   relative to canvas.
%
%   See also GCANVAS_CREATE, GCANVAS_OVERWRITE.

%   Weihao Sheng, 2020-09-03
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

gparent = gchild.Parent;
cvs = gparent.UserData.Canvas;
if isempty(cvs)
    warning([mfilename ': GCANVAS not initiated. Use GCANVAS_CREATE to start one']);
    status = 1;
    return
end
gchild.Parent = gparent;

x = cvspos(1); y = cvspos(2); width = cvspos(3); height = cvspos(4); 
% check in GridObjects that the slots are still empty
used = ~cellfun(@isempty, cvs.GridObjects(x:x+width-1, y:y+height-1));
if any(used(:))
    warning([mfilename ': designated grids are being used. Use GCANVAS_OVERWRITE to force overwrite the area']);
    status = 1;
    return
end
% calculate the location
gchild.Units = 'pixels';
gchild.Position(1) = cvs.GridSize(1) * (x-1) + 1; % left
gchild.Position(2) = cvs.DrawableArea(2) - cvs.GridSize(2) * (height+y-1); % bottom
gchild.Position(3) = cvs.GridSize(1) * width; % width
gchild.Position(4) = cvs.GridSize(2) * height; % height
% set corresponding location as occupied by the GraphicalObject
[cvs.GridObjects(x:x+width-1, y:y+height-1)] = deal({gchild});

gparent.UserData.Canvas = cvs;
status = 0;
end



