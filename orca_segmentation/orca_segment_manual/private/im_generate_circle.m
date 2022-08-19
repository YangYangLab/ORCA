function im = im_generate_circle(imagesize, diameter, xcenter, ycenter, mode, value)
%IM_GENERATE_CIRCLE generate a circle with given radius and return a matrix containing the circle
%   IM = IM_GENERATE_CIRCLE(IMAGESIZE, DIAMETER, XCENTER, YCENTER, MODE) 
%   generates a matrix of IMAGESIZE containing the circle with given 
%   diameter positioned at (ycenter, xcenter). All units are in pixels.
%   IMAGESIZE : one number for a square output, or two numbers [x_px, y_px]
%               for rectangular output. Both integer.
%   DIAMETER : integer.
%   XCENTER, YCENTER : must be in the picture, integer.
%   MODE : one of 'stroke' (default, can be omitted) and 'fill', whether or
%          not to fill the circle.

%   im_generate_circle(isz, r*2, x+0.5, y+0.5) does better work

%   Weihao Sheng, 2019-12-04
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

narginchk(4,6)
if nargin<6, value = 1; end
if nargin<5, mode = 'stroke'; end

validatestring(mode,{'stroke','fill'},mfilename,'mode');

if length(imagesize) == 1
    imagesize = [imagesize, imagesize];
end

%
im = nan(imagesize);
r = diameter / 2;

% we do a local other than global computation
% yrange = round([max(1, ycenter-r-2), min(imagesize(1), ycenter+r+2)]);
% xrange = round([max(1, xcenter-r-2), min(imagesize(2), xcenter+r+2)]);

switch mode
    case 'stroke'
        for y = 1:imagesize(1)
            for x = 1:imagesize(2)
                if ((x-xcenter)^2 + (y-ycenter)^2) <  r*(r+1) && ...
                   ((x-xcenter)^2 + (y-ycenter)^2) >= r*(r-1)
                    im(y,x) = value;
                end
            end
        end
    case 'fill'
        for y = 1:imagesize(1)
            for x = 1:imagesize(2)
                if ((x-xcenter)^2 + (y-ycenter)^2) < r*(r+1)
                    im(y,x) = value;
                end
            end
        end
    otherwise
        error('How did you escape the validatestring eh?');
end

end

