function fig = canvas_cut(fig, gridsize_px)
%canvas_cut   grid-based plotting framework
%   cv = canvas_cut(FIGURE, GRIDSIZE_PX) 

w = fig.InnerPosition(3); h = fig.InnerPosition(4);
cols = fix(w/gridsize_px); rows = fix(h/gridsize_px);

fig.UserData.Canvas.list = cell(0,4); 
% stores {object, name, position_choice, grid_position}
% position_choice: Position(default), InnerPosition, OuterPosition

fig.UserData.Canvas.limit = [cols rows];
% grid_position should not exceed this
% if grid_position = 0, hide
% if grid_position < 0, +rows or +cols

fig.UserData.Canvas.posit = @(pos) ...
    [gridsize_px*(pos(1)-1) , ...
     h-gridsize_px*(pos(2)+pos(4)-1), ...
     gridsize_px*pos(3), ...
     gridsize_px*pos(4)];
% function handle to put objects to new position
