function mask = orca_segment_refine_sizing(wmap, varargin)
% filter and remove areas below MINIMUM_PIXELS
%   MASK = orca_segment_refine_sizing(MASK, MINIMUM_PIXELS)
%       checks each ROI in mask by minimum size
%   ... = orca_segment_refine_sizing(..., 'convex', false)

%   Weihao Sheng, 2021-04-09
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

%minpixels = celldia_px*celldia_px*pi/4;

p = inputParser; p.KeepUnmatched = true; p.CaseSensitive = false; p.PartialMatching = true;
addRequired(p, 'minpixels')
addParameter(p, 'convex', false); % use convexed mask
addParameter(p, 'debug', false)
parse(p, varargin{:})
p = p.Results;

mapconn = bwconncomp(wmap); 
nPixels = cellfun(@numel,mapconn.PixelIdxList);
Idx2Elim = 1:mapconn.NumObjects; Idx2Elim = Idx2Elim(nPixels<p.minpixels);
for id = 1:length(Idx2Elim)
    wmap([mapconn.PixelIdxList{Idx2Elim(id)}]) = 0;
end
mapconn = bwconncomp(wmap);
if isa(mapconn, 'gpuArray'), mapconn = gather(mapconn); end % tricky setting for regionprops that don't support GPU
stats = regionprops(mapconn, 'Area', 'BoundingBox');
if p.convex
    stats_convex = regionprops(mapconn, 'ConvexArea', 'ConvexImage');
    [stats.ConvexArea] = stats_convex.ConvexArea;
    [stats.ConvexImage] = stats_convex.ConvexImage;
    mask = zeros(size(wmap));
    for idx = 1:length(stats)
        box = stats(idx).BoundingBox; % left-x, top-y, horz width, vert height
        box = fix(box);
        mask(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1) = stats(idx).ConvexImage .* idx;
    end
else
    mask = wmap;
end