function colors = im_rgba2norm(varargin)
%im_rgb2norm  convert RGBA 0-255 to MATLAB 0-1

if nargin == 1
    colors = single(varargin{1})./255;
elseif nargin == 4
    colors = [single([varargin{1} varargin{2} varargin{3}])./255 varargin{4}];
else
    colors = [0 0 0 0];
end
        