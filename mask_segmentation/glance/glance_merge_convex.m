function wmap = glance_merge_convex(wmap, stats)
%GLANCE_MERGE_CONVEX Summary of this function goes here
%   Detailed explanation goes here

wmap = zeros(size(wmap));
for idx = 1:length(stats)
    box = stats(idx).BoundingBox; % left-x, top-y, horz width, vert height
    box = fix(box);
    wmap(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1) = stats(idx).ConvexImage.*idx;
end

end
