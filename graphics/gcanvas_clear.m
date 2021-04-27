function status = gcanvas_clear(gparent,cvspos)
%GCANVAS_CLEAR align Graphical Objects onto pre-defined grids
%   GOBJ = GCANVAS_CLEAR(GPARENT, CANVASPOSITION) clears graphical objects on GPARENT
%   according to grids of CANVASPOSITION.
%   CANVASPOSITION is a vector of [x(left), y(top), width, height] and their units are 
%   relative to canvas.
%
%   See also GCANVAS_CREATE, GCANVAS_OVERWRITE.

%   Weihao Sheng, 2020-09-03
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

cvs = gparent.UserData.Canvas;
if isempty(cvs)
    %warning([mfilename ': GCANVAS not initiated. Use GCANVAS_CREATE to start one']);
    status = 1;
    return
end

x = cvspos(1); y = cvspos(2); width = cvspos(3); height = cvspos(4); 
% check in GridObjects that the slots are still empty
used = ~cellfun(@isempty, cvs.GridObjects(x:x+width-1, y:y+height-1));
if ~any(used(:))
    warning([mfilename ': grids not being used.']);
    status = 1;
    return
end

removeObject = @(x) {delete(x);[]};

for col = x:x+width-1
    for row = y:y+height-1
        try
            delete(cvs.GridObjects{col,row});
            cvs.GridObjects{col,row} = [];
        catch ME
        end
    end
end
status = 0;
end



