function [fig,obj] = canvas_put(fig, obj, obj_name, pos_name, pos_grid )
%canvas_put   put object on certain position
%   cv = canvas_put(FIGURE, GRIDSIZE_PX) 

cv = fig.UserData.Canvas;

% --- duplicate check
dup = cellfun(@(x) x==obj, cv.list(:,1));
if any(dup)
    fprintf('failed to posit %s: Object already exists (%d)\n', obj_name, find(dup,1)); 
    return;
end

% --- pos_name: detect valid Position attribute
if isempty(pos_name)  
    if      isfield(obj, 'Position'),       pos_name = 'Position'; 
    elseif  isfield(obj, 'OuterPosition'),  pos_name = 'OuterPosition'; 
    elseif  isfield(obj, 'InnerPosition'),  pos_name = 'InnerPosition'; 
    else,   fprintf('failed to posit %s: No valid position attributes\n', obj_name); return;
    end
end
if any(pos_grid==0)
    % not really put this thing, just list it
    pos_name = 'hidden';
    pos_grid = [0 0 0 0];
end

% --- pos_grid: border check
if abs(pos_grid(1))>cv.limit(1) || abs(pos_grid(2))>cv.limit(2)
    fprintf('failed to posit %s: Position out of border\n', obj_name); 
    return;
end

%% valid item, continue

listitem = {obj, obj_name, pos_name, pos_grid};
cv.list = [cv.list; listitem];

if ~strcmpi(pos_name,'hidden')
    % --- if grid_position < 0, +rows or +cols
    if pos_grid(1)<0, pos_grid(1)=cv.limit(1)+1-pos_grid(1); end
    if pos_grid(2)<0, pos_grid(2)=cv.limit(2)+1-pos_grid(2); end

    % --- put object to position
    obj.Parent = fig;
    obj.Units = 'pixels';
    obj.(pos_name) = cv.posit(pos_grid);
end

% write back to figure
fig.UserData.Canvas = cv;

