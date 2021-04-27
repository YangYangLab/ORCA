function y = im_convfft(x, m, shape)
%IM_CONVFFT - 2d convolution using FFT
%   a fast 2-d convolution algorithm using FFT and inverse FFT. All
%   parameters are kept compatible with the MATLAB conv2() function.
%
%   Y = IM_CONVFFT(X, M) 
%   Y = IM_CONVFFT(..., SHAPE) is almost same as conv2(..., SHAPE), 
%       while SHAPE can take one of 'full'(default), 'same' or 'valid'.
%   
%   Be aware that:
%   - Invalid SHAPE will raise errors
%   - This function takes integer or float matrixs, and the class of output
%     Y is kept same with input X.
%
%   See also CONV2.

%   Copyright David Young, April 2011. See LICENSE at the end of this file. 
%   Modified by Weihao Sheng, 2019/10/07

narginchk(2,3);
if nargin < 3, shape = 'full'; end

x = double(x); m = double(m);

[x, m, fsize] = thispadarrays(x, m, shape);
% no need to trap case of real x and m - fft2 handles efficiently
y = ifft2(fft2(x) .* fft2(m));   % central operation, basic form
% trim to correct output size
if ~isequal(fsize, size(y))
    y = y(1:fsize(1), 1:fsize(2));
end
y = real(y);
end

%% padarrays
function [x, m, fsize] = thispadarrays(x, m, shape)
% Pad arrays to make them the same size and allow for boundary effects
xsize = size(x);
msize = size(m);
switch shape
    
    case 'wrap'
        fsize = xsize;
        % ensure x no smaller than m
        if any(msize > xsize)  && ~isempty(x)
            x = repmat(x, ceil(msize ./ size(x)));
            xsize = size(x);
        end
        % pad m with zeros
        if any(msize < xsize)  % test, as user may have optimised already
            m = thisexindex(m, 1:xsize(1), 1:xsize(2), {0});
        end
        % recentre m so that y(1,1) corresponds to mask centred on x(1,1)
        mc = 1 + floor(msize/2);
        me = mc + xsize - 1;
        m = thisexindex(m, mc(1):me(1), mc(2):me(2), 'circular');
    
    case 'full'
        fsize = xsize + msize - 1;  % enough room for no overlap
        x = thisexindex(x, 1:fsize(1), 1:fsize(2), {0});
        m = thisexindex(m, 1:fsize(1), 1:fsize(2), {0});
    
    case 'valid'
        fsize = xsize - msize + 1;
        % pad m with zeros (don't test first, as likely to be needed)
        m = thisexindex(m, 1:xsize(1), 1:xsize(2), {0});
        % shift m so that y(1,1) corresponds to mask just inside x
        me = msize + xsize - 1;
        m = thisexindex(m, msize(1):me(1), msize(2):me(2), 'circular');
    case 'same'
        fsize = xsize;
        mmid = floor(msize/2);
        xsize = xsize + mmid;   % border to avoid edge effects
        x = thisexindex(x, 1:xsize(1), 1:xsize(2), {0});
        m = thisexindex(m, 1:xsize(1), 1:xsize(2), {0});
        % recentre m so that y(1,1) corresponds to mask centred on x(1,1)
        mc = 1 + mmid;
        me = mc + xsize - 1;
        m = thisexindex(m, mc(1):me(1), mc(2):me(2), 'circular');
        
    case 'reflect'
        fsize = xsize;
        xsize = xsize + msize - 1;   % border to avoid edge effects
        xc = 1 - floor((msize-1)/2);
        xe = xc + xsize - 1;
        x = thisexindex(x, xc(1):xe(1), xc(2):xe(2), 'symmetric');
        m = thisexindex(m, 1:xsize(1), 1:xsize(2), {0});
        % recentre m so that y(1,1) corresponds to mask centred on x(1,1)
        me = msize + xsize - 1;
        m = thisexindex(m, msize(1):me(1), msize(2):me(2), 'circular');
    otherwise
        error('conv_fft2:badshapeopt', 'Unrecognised shape option: %s', shape);
end
end

%%
function arr = thisexindex(arr, varargin)
%EXINDEX extended array indexing
%   ARROUT = EXINDEX(ARRIN, S1, S2, ...) indexes a virtual array made by
%   extending ARRIN with zeros in all directions, using subscripts S1, S2
%   etc.
%
%   ARROUT = EXINDEX(ARRIN, S1, R1, S2, R2, ...) extends ARRIN using rule
%   R1 on the first dimension, R2 on the second dimension etc.
%
%   ARROUT = EXINDEX(ARRIN, S1, S2, ..., R) extends ARRIN using rule R on
%   every dimension.
%
%   Subscripts
%   ----------
%
%   Broadly, if V is the virtual extended array, ARROUT = V(S1, S2, ...)
%
%   The elements of the subscript arguments S1, S2 etc must be integers.
%   They need not be positive and are not restricted in any way by the size
%   of ARRIN. Logical indexing and linear indexing are not supported.
%
%   There must be at least one subscript argument for each dimension of
%   ARRIN as reported by NDIMS, except that row and column vectors may have
%   1 or 2 subscripts. A single subscript is taken to refer to the
%   dimension along which the vector lies, as in normal vector indexing.
%   Scalars require 2 subscripts. If there are more subscripts than
%   dimensions, ARRIN is taken to have trailing singleton dimensions, as in
%   normal array indexing.
%
%   The number of dimensions of ARROUT will be the number of subscript
%   arguments, though trailing singleton dimensions will, as usual, be
%   suppressed. The size of ARROUT is given by the normal Matlab rules for
%   the result of indexing into ARRIN: that is
%
%       size(ARROUT) = size( ARRIN(ones(size(S1)), ones(size(S2)), ...) )
%
%   A subscript argument may be the string ':'. This behaves like a colon
%   in ordinary subscripting: a colon for the K'th subscript stands for
%   1:size(ARRIN, K). The 'end' keyword is not supported.
%
%   Rules
%   -----
%
%   Each rule may be one of the following:
%
%   A scalar cell: ARRIN is padded with elements equal to the contents of
%   the cell. The class of the cell contents must be compatible with the
%   class of ARRIN.
%
%       If different constants are used on different dimensions, padding is
%       done in the order of the subscripts. For example, a 2D array is
%       extended first in the row index direction and then in the column
%       index direction. For all other cases, the order in which dimensions
%       are extended has no effect.
%
%   'circular': ARRIN is extended with copies of itself; i.e. V is tiled
%   with ARRIN.
%
%   'symmetric': ARRIN is extended with copies of itself with reflection at
%   its boundaries; i.e. V is tiled with [ARRIN fliplr(ARRIN);
%   flipud(ARRIN) fliplr(flipud(ARRIN))].
%
%   'replicate': ARRIN is extended by copying its border elements; i.e. an
%   element of V is equal to the nearest element of ARRIN.
%
%   If no rule is given, padding is with zeros.
%
%   Examples
%   --------
%
%   Pad a 2D matrix with K extra rows and columns with reflection on both
%   axes:
%
%       b = exindex(a, 1-k:size(a,1)+k, 1-k:size(a,2)+k, 'symmetric');
%
%   Circularly shift a 2D matrix by R rows downwards and C columns
%   rightwards:
%
%       b = exindex(a, 1-r:size(a,1)-r, 1-c:size(a,2)-c, 'circular');
%
%   Force a row or column vector to be 1024 elements long, trimming or
%   padding with zeros as necessary:
%
%       u = exindex(v, 1:1024);
%
%   The same, with a non-zero padding value:
%
%       u = exindex(v, 1:1024, {-1});   % note constant in cell
%
%   Truncate or extend all the rows of a matrix to 1024 columns:
%
%       b = exindex(a, ':', 1:1024);
%
%   Extend a 2-D array into the third dimension by copying it:
%
%       b = exindex(a, ':', ':', 1:3, 'replicate');
%
%   Pad a 1-D cell array with cells containing the empty matrix:
%
%       cellout = exindex(cellin, 0:10, {{[]}}); 
%
%   See also: padarray, circshift, repmat
% Copyright David Young 2010
% Sort out arguments
[exindices, rules, nd, sz] = getinputs(arr, varargin{:});
consts = cellfun(@iscell, rules);  % Check for constants, as can be
constused = any(consts);           % more efficient if there are none
% Setup for constant padding
if constused
    tofill = cell(1, nd);
end
% Main loop over subscript arguments, transforming them into valid
% subscripts into arr using the rule for each dimension
if constused
    for i = 1:nd
        [exindices{i}, tofill{i}] = extend(exindices{i}, rules{i}, sz(i));
    end
else % no need for information for doing constants
    for i = 1:nd
        exindices{i} = extend(exindices{i}, rules{i}, sz(i));
    end
end
% Create the new array by indexing into arr. If there are no constants,
% this does the whole job
arr = arr(exindices{:});
% Fill areas that need constants
if constused
    % Get full range of output array indices
    ranges = arrayfun(@(x) {1:x}, size(arr));
    for i = nd:-1:1    % order matters
        if consts(i)
            ranges{i} = tofill{i};      % don't overwrite original
            c = rules{i};               % get constant and fill ...
            arr(ranges{:}) = c{1};      % we've checked c is scalar
            ranges{i} = ~tofill{i};     % don't overwrite
        end
    end
end
end
% -------------------------------------------------------------------------
function [exindices, rules, nd, sz] = getinputs(arr, varargin)
% Sort out and check arguments. Inputs are as given in the help comments
% for exindex. Outputs are cell arrays; each element of exindices is a
% set of integer extended indices which has been checked for validity; each
% element of rules is a rule which has not been checked for validity.
% Use index/rules arguments only to establish no. dimensions - ndims(arr)
% is no use, as trailing singleton dimensions truncated and vectors can be
% 2D or 1D
nd = length(varargin);
if nd == 0
    error('exindex:missingargs', 'Not enough arguments');
elseif nd == 1
    exindices = varargin;
    rules = {{0}};
elseif ~(isnumeric(varargin{2}) || strcmp(varargin{2}, ':'))
    % have alternating indices and rule
    nd = nd/2;
    if round(nd) ~= nd
        error('exindex:badnumargs', ...
            'Odd number of arguments after initial index/rule pair');
    end
    exindices = varargin(1:2:end);
    rules = varargin(2:2:end);
elseif nd > 2 && ~(isnumeric(varargin{end}) || strcmp(varargin{end}, ':'))
    % have a general rule at end
    nd = nd - 1;
    exindices = varargin(1:nd);
    [rules{1:nd}] = deal(varargin{end});
else
    % no rule is specified
    exindices = varargin;
    [rules{1:nd}] = deal({0});
end
% Sort out mismatch of apparent array size and number of dimensions
% indexed
sz = size(arr);
ndarr = ndims(arr);
if nd < ndarr
    if nd == 1 && ndarr == 2
        % Matlab allows vectors to be indexed with a single subscript and
        % to retain their shape. In all other cases (including scalars) a
        % single subscript causes the output to take the same shape as the
        % subscript array - we can't deal with this.
        if sz(1) == 1 && sz(2) > 1
            % have a row vector
            exindices = [{1} exindices {1}];
            rules = [rules rules];  % 1st rule doesn't matter
        elseif sz(2) == 1 && sz(1) > 1
            % have a column vector
            exindices = [exindices {1}];
            rules = [rules rules];  % 2nd rule doesn't matter
        else
            error('exindex:wantvector', ...
                'Only one index but array is not a vector');
        end
    else
        error('exindex:toofewindices', ...
            'Array has more dimensions than there are index arguments');
    end
    nd = 2;
elseif nd > ndarr
    % Effective array size
    sz = [sz ones(1, nd-ndarr)];
end
% Expand any colons now to simplify checking.
% It's tempting to allow the 'end' keyword here: easy to substitute the
% size of the dimension. However, to be worthwhile it would be necessary to
% use evalin('caller',...) so that expressions using end could be given as
% in normal indexing. This would mean moving the code up to exindex itself,
% and evalin makes for inefficiency and fragility, so this hasn't been
% done.
colons = strcmp(exindices, ':');
if any(colons)  % saves a little time
    exindices(colons) = arrayfun(@(x) {1:x}, sz(colons));
end
% Check the indices (rules are checked as required in extend)
checkindex = @(ind) validateattributes(ind, {'numeric'}, ...
    {'integer'}, 'exindex', 'index');
cellfun(checkindex, exindices);
end
% -------------------------------------------------------------------------
function [ind, tofill] = extend(ind, rule, s)
% The core function: maps extended array subscripts into valid input array
% subscripts.
if ischar(rule)    % pad with rule
    
    tofill = [];  % never used
    switch rule
        case 'replicate'
            ind = min( max(1,ind), s );
        case 'circular'
            ind = mod(ind-1, s) + 1;
        case 'symmetric'
            ind = mod(ind-1, 2*s) + 1;
            ott = ind > s;
            ind(ott) = 2*s + 1 - ind(ott);
        otherwise
            error('exindex:badopt', 'Unknown option');
    end
    
elseif iscell(rule) && isscalar(rule)     % pad with constant
    
    % The main messiness is due to constant padding. This can't be done
    % with indexing into the original array, but we want the indexing
    % structure to be preserved, so for now we index to element 1 on each
    % dimension, and record the indices of the regions that need to be
    % fixed.
    
    tofill = ind < 1 | ind > s;
    ind(tofill) = 1;
    
else
    
    error('exindex:badconst', 'Expecting string or scalar cell');
    
end
end

%% LICENSE

% Copyright (c) 2011, David Young
% Copyright (c) 2010, David Young
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
