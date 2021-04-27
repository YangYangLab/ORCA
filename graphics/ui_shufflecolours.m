function cmap = ui_shufflecolours(cmap)
%UI_GETCOLORS Get colour schemes defined in matlab
%   A simple wrapper for colormap() without figures appearing
%
%   See also COLORMAP.

%   Weihao Sheng, 2019-12-22
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

cmap = [cmap(1:4:end,:); cmap(2:4:end,:); cmap(3:4:end,:); cmap(4:4:end,:)];
cmap = [cmap(1:4:end,:); cmap(2:4:end,:); cmap(3:4:end,:); cmap(4:4:end,:)];
end

