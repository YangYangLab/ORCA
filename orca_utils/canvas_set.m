function canvas_set(fig, name, varargin)
if isfield(fig.UserData, 'Canvas')
    cvlist = fig.UserData.Canvas.list;
else
    warning('figure canvas uncut');
    return
end

match = arrayfun(@(x) ~isempty(strfind(lower(cvlist{x,2}),lower(name))), 1:size(cvlist,1));
if any(match)
    for x = find(match)
        fprintf('set %s attributes (%s)\n', cvlist{x,2}, cvlist{x,1}.Type);
        set(cvlist{x,1},varargin{:});
    end
    fig.UserData.Canvas.list = cvlist;
end

