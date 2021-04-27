function [patchx, patchy] = rect(varargin)
%RECT convert left-bottom-width-height to patch format
%   [px,py] = RECT([l b w h])
%   [px,py] = RECT(l,b,w,h), while l,b,w,h are left, bottom, width, height accordingly.

if nargin == 1
    p = varargin{1};
elseif nargin == 4
    p = [varargin{:}];
else
    error([mfilename ': Invalid input.']);
end

patchx = [p(1) p(1)+p(3) p(1)+p(3) p(1)];
patchy = [p(2) p(2) p(2)+p(4) p(2)+p(4)];
end
    