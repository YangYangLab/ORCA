% NOT-A-FUNCTION
% code to import most common anomymous function 

% put many useful function handles into the current workspace

% retrieve values of a cell
getvec = @(vec, idx) vec(idx);
getmat = @(matrix, indexes) matrix(indexes{:});
getcell = @(cel, idx) cel{idx};
getstruct = @(st, name) st.(name);  % retrieve value of a field

% function handles for common uses
callfn = @(fun) fun();              % call a function_handle, kind of eval utility
ifelse = @(condition, truefn, falsefn) callfn(getcell({falsefn, truefn}, condition+1));
ifempty = @(condition, emptyfn) ifelse(condition, condition, emptyfn);

% case-insensitive struct operations
isfieldi = @(st, name) strcmpi(name,fieldnames(st));
matchfieldi = @(st, name) getcell(fieldnames(st), strcmpi(name,fieldnames(st))>0);
getfieldi = @(st, name) iff(any(isfieldi(st,name)), st.(matchfieldi(st, name)),{}); 



    
