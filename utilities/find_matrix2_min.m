function [pos, val] = find_m2d_min(m)
%FIND_MATRIX_MIN Finds the maximum value and its position in a matrix
%   POS = FIND_MATRIX_MIN(M) finds minimum value and returns the position of it in the
%   matrix.
%   [POS, VAL] = FIND_MATRIX_MIN(M) lets VAL to be the minimum value.
%   
%   See also MIN, FIND_MATRIX_MAX.

%   Weihao Sheng, 2020-04-21
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

function [ysft, xsft] = find_matrix_min(mtx, lastsft, mcontsft)
% find the minimum value in a matrix.
if nargin == 1
    rowtop = 1; coltop = 1;
    rows = 1:size(mtx,1); 
    cols = 1:size(mtx,2);
else
    rowtop = max(1, lastsft(2)-mcontsft);
    coltop = max(1, lastsft(1)-mcontsft);
    rows = rowtop : min(size(mtx,1), lastsft(2)+mcontsft);
    cols = coltop : min(size(mtx,2), lastsft(1)+mcontsft);
end
mtx = mtx(rows, cols);
[~, ind] = min(mtx(:));
[ysft, xsft] = ind2sub(size(mtx), ind);

ysft = ysft + rowtop - 1;
xsft = xsft + coltop - 1;
end

end
