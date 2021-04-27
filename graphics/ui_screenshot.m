function cdata = ui_screenshot(fig)
%UI_GETCOLORS Get colour schemes defined in matlab
%   A simple wrapper for colormap() without figures appearing
%
%   See also COLORMAP.

%   Weihao Sheng, 2019-12-22
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

frame = getframe(fig);
cdata = permute(frame.cdata, [2 1 3]);
end

