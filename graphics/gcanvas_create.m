function gobj = gcanvas_create(gobj, scalingfactor)
%GCANVAS_CREATE make a new grid for a figure, uipanel or axes
%   GOBJ = GCANVAS_CREATE(GOBJ, SCALINGFACTOR) clears everything in GOBJ
%   (deletes all its children GraphicalObjects) and calculates a new grid
%   based on screen resolution and GOBJ areas. It prepares a Canvas struct
%   in gobj.UserData (stored as gobj.UserData.Canvas).
%
%   See also UICANVAS_ALIGN.

%   Weihao Sheng, 2020-09-03
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

gobj_delchildren(gobj);
if nargin<2, scalingfactor = 1; end

gobj.UserData.Canvas = [];

cvs.GridSize = repmat(round(0.5*get(groot, 'ScreenPixelsPerInch')*scalingfactor), [1 2]);
cvs.DrawableArea = [gobj.InnerPosition(3) gobj.InnerPosition(4)];
cvs.GridObjects = cell(ceil(cvs.DrawableArea(1)/cvs.GridSize(1)), ceil(cvs.DrawableArea(2)/cvs.GridSize(2)));

gobj.UserData.Canvas = cvs;

end

