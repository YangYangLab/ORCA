function s = set_option(s, name, value)
%GET_OPTION get value in a struct or return default value if non-existent
%   [OPTION NAMES ARE CASE-INSENSITIVE]
%
%   VAL = GET_OPTION(S, 'OPTIONNAME') retrieves the values of S.OPTIONNAME or returns []
%   if the OPTIONNAME does not exist.
%
%   VAL = GET_OPTION(S, {'OPTION NAME'}) retrieves the values of all S.(OPTIONNAME) or 
%   returns [] for the FIELDNAMES that do not exist.
%
%   VAL = GET_OPTION(..., DEFAULT) returns DEFAULT for the OPTIONNAMES that do not exist.
%
%   See also GETFIELD, ISFIELD.

%   Weihao Sheng, 2020-03-10
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

findname = findfieldname(s, name);
if isempty(findname)
    s.(lower(name)) = value;
else
    s.(findname) = value;
end

end

function name = findfieldname(s, fn)
    name = [];
    if isempty(s), return; end
    names = fieldnames(s);
    for n = 1:length(names)
        if strcmpi(fn, names{n}) % CASE_INSENSITIVE
            name = names{n};
            return
        end
    end    
end

        