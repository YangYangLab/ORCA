function im = plot_add_scalebar(im, pixelsize, varargin)
%plot_add_scalebar  Display a scale bar on a certain image
%   im = plot_add_scalebar(hImage, PixelSizeUm, ...) adds a scale bar using default settings
%
%   im = plot_add_scalebar(..., Name,Value) customise scale bars.
%   Valid Name-Value pairs are: 
%   
%       IntendedLength  preferred scale bar length, in um. By default approximately 10% of
%                       width will be used as preferred.
%
%       Location        in which corner to put the scale bar. Valid options are 
%                       'southeast', 'northeast', 'southwest','northwest' indicating the
%                       four corners. 'southeast' by default.
%
%       LineWidth       thickness of bar, a percentage value relative to height pixels. By
%                       default 1, which means 1% of height is the thickness.
%
%       Color           three-element vector [R,G,B] ranging [0,1] indicating scale bar
%                       color.
%
%       BorderWidth
%
%
%   See also PLOT_REMOVE_SCALEBAR.

expected_locations = {'southeast','northeast', 'southwest','northwest'};

prs = inputParser; prs.CaseSensitive = false; prs.FunctionName = mfilename;
addOptional(prs, 'Location',        'southeast', 	@(x) any(validatestring(x,expected_locations)));
addOptional(prs, 'LineWidth',       1);
addOptional(prs, 'Color',           [1 1 1],        @(x) isvector(x)&&(length(x)==3));
addOptional(prs, 'BorderWidth',     0.03);
addOptional(prs, 'IntendedLength',  0,              @isscalar);
parse(prs, varargin{:});
p = prs.Results;

% if old one exists
if isfield(im.UserData, 'Scalebar') && ~isempty(im.UserData.Scalebar)
    try
        delete(im.UserData.Scalebar{1});
        delete(im.UserData.Scalebar{2});
        im.UserData.Scalebar = [];
    catch
    end
end

[h, w] = size(im.CData);
heightum = h * pixelsize; widthum = w * pixelsize;

if p.IntendedLength == 0, p.IntendedLength = FindNearestComfortableNumber(round(0.1 * widthum)); end
barthickness = p.LineWidth/100; 
barlength = p.IntendedLength / pixelsize / w;

textmult = 3;

if im.Parent.YDir == 'reverse' % imshow
    switch p.Location
        case 'southwest'
            lpos = [w,h,w,h].*[p.BorderWidth, 1-p.BorderWidth-barthickness, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)-lpos(4)*textmult];
        case 'northwest'
            lpos = [w,h,w,h].*[p.BorderWidth, p.BorderWidth, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)+lpos(4)*textmult];
        case 'southeast'
            lpos = [w,h,w,h].*[1-p.BorderWidth-barlength, 1-p.BorderWidth-barthickness, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)-lpos(4)*textmult];
        case 'northeast'
            lpos = [w,h,w,h].*[1-p.BorderWidth-barlength, p.BorderWidth, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)+lpos(4)*textmult];
    end
else % image or imagesc
    switch p.Location 
        case 'northwest'
            lpos = [w,h,w,h].*[p.BorderWidth, 1-p.BorderWidth-barthickness, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)-lpos(4)*textmult];
        case 'southwest'
            lpos = [w,h,w,h].*[p.BorderWidth, p.BorderWidth, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)+lpos(4)*textmult];
        case 'northeast'
            lpos = [w,h,w,h].*[1-p.BorderWidth-barlength, 1-p.BorderWidth-barthickness, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)-lpos(4)*textmult];
        case 'southeast'
            lpos = [w,h,w,h].*[1-p.BorderWidth-barlength, p.BorderWidth, barlength, barthickness];
            tpos = [lpos(1)+lpos(3)/2 lpos(2)+lpos(4)*textmult];
    end    
end
ax = im.Parent; hold(ax, 'on');
set(ax, 'Units', 'pixels'); 
[patchx, patchy] = rect(lpos);
im.UserData.Scalebar{1} = fill(ax, patchx, patchy, p.Color, 'EdgeColor','none');
im.UserData.Scalebar{2} = text(ax, tpos(1), tpos(2), sprintf('%d \\mu\\it{m}', p.IntendedLength), 'Color', p.Color, 'HorizontalAlignment','center', 'Interpreter', 'tex', 'FontName', 'Times New Roman');
hold(ax,'off'); set(ax, 'Units', 'normalized'); 
end

function num = FindNearestComfortableNumber(intendum)
comfortableum = [1:9, 10:5:29, 30:10:99, 100:20:199, 200:50:499, 500:100:1000];
[~,idx] = min(abs(comfortableum-intendum));
num = comfortableum(idx);
end