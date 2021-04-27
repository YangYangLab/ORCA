function im = plot_remove_scalebar(im)
%PLOT_REMOVE_SCALEBAR   remove scalebar created by PLOT_ADD_SCALEBAR
%
%   See also PLOT_ADD_SCALEBAR.

% if old one exists
if isfield(im.UserData, 'Scalebar') && ~isempty(im.UserData.Scalebar)
    try
        delete(im.UserData.Scalebar{1});
        delete(im.UserData.Scalebar{2});
        im.UserData.Scalebar = [];
        im.UserData = rmfield(im.UserData, 'Scalebar');
    catch
    end
end
end