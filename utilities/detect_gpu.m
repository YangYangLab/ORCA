% NOT-A-FUNCTION
% code to mask out gpuArray if useGPU==0

% every time this function is called, we should either have a "params.GPU" in the current 
% workspace, or we have a global GPU option defined in global ORCA.GPU

if isfield(ORCA, 'GPU'), shouldiusegpu = strcmpi(ORCA.GPU, 'on'); else, shouldiusegpu = 0; end
%shouldiusegpu = param_testval(params, 'GPU', shouldiusegpu);  % params.GPU overrides global 

if ~shouldiusegpu, gpuArray = @(x) x; end 
