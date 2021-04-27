function val = test_field(s, fdname, replacement)
%PARAM_TESTVAL get value in a struct or return default value if non-existent
%   VAL = TEST_FIELD(STRUCT, FIELD2FIND, REPLACEMENT)
%   VAL = TEST_FIELD(STRUCT, {FIELDS2FIND}, REPLACEMENT)
%
%   See also GET_OPTION.

%   Weihao Sheng, 2020-03-10
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

import_functions;

if nargin < 3, replacement = []; end

if ischar(fdname) % TEST_FIELD(S, 'FIELD2FIND')

    val = ifelse(isfieldi(s,fdname), getfieldi(s,fdname), replacement);

elseif iscell(fdname) % TEST_FIELD(S, {'FIELDS2FIND', ...})

    val = cellfun(@ifelse, s, fdname, replacement);
%     
%     for idx = 1:length(fdname)
%         if any(strcmpi(fdname{idx}, names))
%             val{idx} = ifelse(any(strcmpi(x,names)), s.(names{strcmpi(x,names)}), replacement);
%         else
%             val{idx} = replacement; 
%         end
%     end
else
    error ([mfilename ': invalid FIELDNAMES']);
end
end

function val = valfindfieldname(s, fn)
    val = [];
    if isempty(s), return; end
    
    for n = 1:length(names)
        if strcmpi(fn, names{n}) % CASE_INSENSITIVE
            val = s.(names{n});
            return
        end
    end    
end

        