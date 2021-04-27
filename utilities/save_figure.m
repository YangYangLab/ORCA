function ok = save_figure(hg, filePath, fileType)
%save_figure saves a graphic object as lossless file
%   OK = save_figure(HG, FILEPATH, FILETYPE) saves the graphic object HG to FILEPATH.
%       HG is a graphic object(figure,
%       BPP stands for BYTES PER PIXEL (1/2/4 for uint8/uint16/uint32). BPP value other
%       than 1/2/4 will be considered illegal and 16-bit as default will be used.
%
%   Simple wrapper for imwrite.
%
%   See also IMWRITE.

%   Weihao Sheng, 2020-04-20
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China


ok = false;

if nargin<3, fileType = 'fig'; end
[~, filename, ~] = fileparts(filePath);

if ~ishghandle(hg) || ~isprop(hg, 'Type')
    warning([mfilename ': first input is not a valid matlab hghandle.']);
    return
end

figure_plottable = {'axes', 'uipanel', 'uicontrol'};
% --- figure
if strcmpi(hg.Type, 'figure')
    figcontainer = hg;
    ok = save_lossless(figcontainer, filePath, fileType);
    return
end

figcontainer = figure('Color','w','Visible', 'off', 'Units', 'pixels');
figcontainer.Position = [100 100 100 100];
figcontainer.Name = filename;
old_units = hg.Units; hg.Units = 'pixels';

if any(strcmpi(hg.Type, figure_plottable))
    
    figcontainer.Position(3) = hg.Position(3) + 100; 
    figcontainer.Position(4) = hg.Position(4) + 100; 
    
    old_parent = hg.Parent; old_position = hg.Position; 
    hg.Parent = figcontainer; 
    
    hg.Position = [50 50 hg.Position(3) hg.Position(4)];
    ok = save_lossless(figcontainer, filePath, fileType);
    
    hg.Parent = old_parent; hg.Position = old_position; hg.Units = old_units;
    close(figcontainer);
    
else % everything that should be present in axes

    axescontainer = axes(figcontainer); axescontainer = copy_properties(axescontainer, hg.Parent);
    figcontainer.Position(3) = axescontainer.Position(3) + 100;
    figcontainer.Position(4) = axescontainer.Position(4) + 100;
    
    old_parent = hg.Parent; 
    hg.Parent = axescontainer;
    axescontainer.Position = [50 50 axescontainer.Position(3) axescontainer.Position(4)];
    
    ok = save_lossless(figcontainer, filePath, fileType);
    
    hg.Parent = old_parent; hg.Units = old_units;
end
end


function ok = save_lossless(fig, filepath, filetype)
ok = false;
[filepath, filename2, guessext] = fileparts(filepath);
if isempty(filepath), filepath = pwd; end
guessext = guessext(2:end);
if ~strcmpi(guessext, filetype)
    warning([mfilename ': filetype mismatch with filepath extension, using filepath format\n']);
    filetype = guessext;
end
filename = fullfile(filepath, [filename2 '.' filetype]);

try
    switch filetype
        case 'fig'
            savefig(fig,filename);
        case 'svg'
            saveas(fig,filename,'svg');
        otherwise
            saveas(gcf,filename, filetype);
    end
    disp([mfilename ': image "' filename2 '" saved to ' filepath]);
    ok = true;
catch
    warning([mfilename ': an error occured while writing image.']);
end
end

function obj1 = copy_properties(obj1, obj2)
fields = properties(obj1);
for x = 1:length(fields)
    try
        if isobject(obj1.(fields{x}))
            obj1.(fields{x}) = copy_properties(obj1.(fields{x}), obj2.(fields{x}));
        else
            obj1.(fields{x}) = obj2.(fields{x});
        end
    catch
        % maybe some read-only properties, nvm
    end
end
end