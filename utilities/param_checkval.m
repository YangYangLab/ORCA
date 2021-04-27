function parser = input_checksa(s, fieldname, valueConditions, conditions_unmet)
%INPUTRESOLVE
%   [OPTION NAMES ARE CASE-INSENSITIVE]
%   Fork of GET_OPTION.
%
%   See also GET_OPTION.

%   Weihao Sheng, 2020-03-10
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

error('not finished')

if nargin < 3
    % existence test
    valueConditions = [];
end

if isa(valueConditions, 'function_handle')

if ischar(fieldname) % GET_OPTION(S, 'OPTIONNAME')

    val = valfindfieldname(s, fieldname); 
    if isempty(val), val = valueConditions; end

elseif iscell(fieldname) % GET_OPTION(S, {'OPTION NAME', ...})

    val = cell(1, length(fieldname));

    for idx = 1:length(fieldname)
        val{idx} = valfindfieldname(s, fieldname{idx});
        if isempty(val{idx}), val{idx} = valueConditions; end
    end
else
    error ([mfilename ': invalid FIELDNAMES']);
end
end

function val = valfindfieldname(s, fn)
    val = [];
    if isempty(s), return; end
    
    names = fieldnames(s);
    for n = 1:length(names)
        if strcmpi(fn, names{n}) % CASE_INSENSITIVE
            val = s.(names{n});
            return
        end
    end    
end

        