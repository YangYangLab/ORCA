function colors = im_hexcolor(varargin)
%im_hexcolor  convert Hex to 0-1

if nargin == 1
    hexcolorstr = varargin{1};
    colors = single([hex2dec(hexcolorstr(1:2)) hex2dec(hexcolorstr(3:4)) hex2dec(hexcolorstr(5:6))])./255;
elseif nargin == 3
    colors = single([hex2dec(varargin{1}) hex2dec(varargin{2}) hex2dec(varargin{3})])./255;
else
    colors = [0 0 0];
end
