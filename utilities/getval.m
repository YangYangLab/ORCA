function val = get_option(s, opt, default)
%GETVAL     get value in struct; if non-existent, return default value or empty
%   [OPTION NAMES ARE CASE-INSENSITIVE]
%
%   VAL = GET_OPTION(S, 'OPTIONNAME') retrieves the values of S.OPTIONNAME or returns []
%   if the OPTIONNAME does not exist.
%
%   VAL = GET_OPTION(S, {'OPTION NAME1', 'OPTION NAME2', ...}) retrieves the values of all
%    S.(OPTIONNAME) or returns [] for the option names that do not exist.
%
%   VAL = GET_OPTION(..., DEFAULT) returns DEFAULT for the option names that do not exist.
%
%   See also GETFIELD, ISFIELD.

%   Weihao Sheng, 2020-03-10
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China


if nargin < 3, default = []; end

if ischar(opt) % GET_OPTION(S, 'OPTIONNAME')

    val = valfindfieldname(s, opt); 
    if isempty(val), val = default; end

elseif iscell(opt) % GET_OPTION(S, {'OPTION NAME', ...})

    val = cell(1, length(opt));

    for idx = 1:length(opt)
        val{idx} = valfindfieldname(s, opt{idx});
        if isempty(val{idx}), val{idx} = default; end
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

        