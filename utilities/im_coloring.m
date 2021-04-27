function rgb = im_coloring(im, mask, color, option)
%IM_COLORING Apply color to a grayscale image.
%   RGB = IM_COLORING(GRAYINPUT, MASK, COLOR, OPTION) applies COLOR to
%   GRAYINPUT using MASK. MASK is a logical/binary input matrix that has
%   the same size as GRAYINPUT. 
%   GRAYINPUT   must be a 2-dimension grayscale matrix. If an RGB image is 
%               given, only the grayscale information will be used.
%   MASK        should be a binary image of the same size as GRAYINPUT.
%   COLOR       can be a single character (one in 'rgbcmy') or a vector of 
%               [r g b] values.
%   OPTION      is an optional parameter, which accepts:
%       'gradient' : apply the COLOR onto the GRAYINPUT where MASK is true,
%                    keeping the intensity information consisitent to the 
%                    original GRAYINPUT (default option)
%       'full' : apply the COLOR directly onto the GRAYINPUT where MASK is
%                true, with maximum intensity (similar to imoverlay
%                introduced in R2016a)
%   
%   See also IMOVERLAY, IMFUSE.

%   Weihao Sheng, 2019-11-29 (Happy Black Friday!)
%   Yang Yang's Lab of Neural Basis of Learning and  Memory
%   School of Life Sciences and Technology,  ShanghaiTech University,
%   Shanghai, China

%% input check
narginchk(3,4)
% must have a grayscale input
im = im2uint8(im);
if (ndims(im) == 3) && (size(im, 3) == 3) % 2-D RGB image    
    grayinput = rgb2gray(im);
    out_red   = im(:,:,1);
    out_green = im(:,:,2); 
    out_blue  = im(:,:,3);
elseif ndims(im) == 2 % 2-D grayscale image
    if max(im(:)) > 1, grayinput = mat2gray(im); end % only convert when its not 0-1 grayscale
    out_red   = im; 
    out_green = im; 
    out_blue  = im;
else
    error('im_coloring:image_format', 'only RGB or grayscale images are accepted');
end

% color: code or value?
if ischar(color)
    color = bitget(find('krgybmcw'== color(1))-1,1:3); % Marcs function
else
    validateattributes(color, {'numeric'}, {'size', [1,3]}, mfilename, 'color');
end

% option
if nargin == 3
    option = 'gradient';
else
    validatestring(option, {'gradient', 'full'}, mfilename, 'option'); 
end

%% 
% force mask to become binary
mask = (mask == 1);
% make colorful mask
if strcmp(option,'gradient')
    mask_gradient_r = im2uint8(color(1) .* mask .* grayinput .* 255); 
    mask_gradient_g = im2uint8(color(2) .* mask .* grayinput .* 255);
    mask_gradient_b = im2uint8(color(3) .* mask .* grayinput .* 255);
else
    mask_gradient_r = uint8(color(1) .* mask .* 255);
    mask_gradient_g = uint8(color(2) .* mask .* 255);
    mask_gradient_b = uint8(color(3) .* mask .* 255);
end
% mask out
out_red(mask) = mask_gradient_r(mask);
out_green(mask) = mask_gradient_g(mask);
out_blue(mask) = mask_gradient_b(mask);
% merge to rgb
rgb = cat(3, out_red, out_green, out_blue);
end

