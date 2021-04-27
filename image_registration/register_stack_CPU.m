function [rt, regout] = register_stack_CPU(moving, template, params)
%REGISTER_STACK_CPU fast image registration using CPU and downsampling
%   RT = REGISTER_STACK_CPU(MOVING, TEMPLATE, PARAMS) analyses movements in the video 
%   and outputs a table comprising offsets in X-Y direction. 
%   [..., REGOUT] = REGISTER_STACK_CPU() also outputs registered stack if needed.
% Inputs:
%   MOVING      a 3-D matrix [height * width * nFrames], the video that needs registration
%   PARAMS      a struct consisting of:
%               maxsft - maximum shift (in pixels). Offset pairs shall not exceed this
%                   limit. By default this is 1/5 of height or width
%               mcontsft - maximum continuous shift (in pixels). Maximum shifts
%                   between one frame and one frame before. Say, Frame #4 shifts 7px in
%                   some direction, and mcontsft=10, so Frame #5 shifts no more than 17px.
%               verbose - 0/1 indicating whether to display a lot of useless info
%               
% Output:
%   RT          a 2-D matrix result table [nFrames*2], each row [yshift, xshift] 
%   STACKOUT    a 3-D matrix [height * width * nFrames], registered video
%
%   See also IM_CONVFFT, REGISTER_STACK_GPU.

%   Written by Weihao Sheng, 2019-10-09
%   Yang Yang's Lab of Neural Basis of Learning and Memory,
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% version(date) & changes
%   20191009 first version ---weihao
%   20200323 normalised for better results ---weihao
%   20200422 add mcontsft & verbose ---weihao
%   20200508 rewrite for full-range registration, and temporarily disable mcontsft ---weihao
%   20200517 downsampling implemented ---weihao

%% Input validation
% For simplicity, we make the following assumptions that:
%  * Inputs MOVING is a 3-dim matrix.
%  * Input MOVING and TEMPLATE share the same frame size.
% The code is based on the above assumptions, and may fail if these requirements are not met.

if nargin < 3, params = []; end

[height, width, nFrames] = size(moving);    
maxsft = get_option(params, 'maxsft', round(min(height, width)/8.0)); maxsft = floor(maxsft/2)*2;
% mcontsft = get_option(params, 'mcontsft', []);
% subpix = get_option(params, 'subpix', []);
verbose = get_option(params, 'verbose', 0); % function as a timer

if any([mod(height,2) mod(width,2)]), error('%s: height and width must be even numbers\n', mfilename); end
    
%% computation
    
if verbose, t0 = tic; end

    % lets define some fast & readable actions
    normalise = @(im) (double(im) - mean(im(:))) / std(double(im(:))) / sqrt(2);
    surround0 = @(im,w) [ zeros(w+w+size(im,1),w), [zeros(w,size(im,2));im;zeros(w,size(im,2))], zeros(w+w+size(im,1),w)];
    rotate180 = @(im) im(end:-1:1, end:-1:1);
    downscale = @(im) double(im(1:2:end,1:2:end) + im(1:2:end,2:2:end) + im(2:2:end,1:2:end) + im(2:2:end,2:2:end))./4;
    
    % ...as well as some rptdly used variables
    dseffsz =   [maxsft, maxsft] + 1;
    dsonesShifted = cshift(ones(height/2,width/2), dseffsz-1);
    
    % process template 
    t = normalise(template);
    % ... in downsampled space
    dst = downscale(t);
    dstflip = rotate180(dst); dstflipShifted = cshift(dstflip, dseffsz-1);
    dstfliplarge = surround0(dstflip, maxsft/2); % template rotated and padded
    sumdst2 = conv2_fftvalid(dstfliplarge.^2, dsonesShifted, dseffsz);
    % ...and in upsampled space
    tcentral = t(maxsft+1:height-maxsft, maxsft+1:width-maxsft);
    tcentralshift = cshift(rotate180(tcentral),[2 2]);
    
    % alarge the container for the unregistered frame
    dsalarge = zeros(height/2+maxsft, width/2+maxsft);
    
    % overlap pixels count
    denominator = conv2_fftvalid(surround0(ones(height/2,width/2),maxsft/2), dsonesShifted, dseffsz);
    
    % actual registration
    rt = zeros(nFrames, 2);
    regout = zeros([height, width, nFrames], class(moving));
        
    for frm = 1:nFrames

        a = normalise(moving(:,:,frm));

        % in downsample space:
        dsalarge(maxsft/2+(1:height/2), maxsft/2+(1:width/2)) = downscale(a);
        sumdsa2 = conv2_fftvalid(dsalarge.^2, dsonesShifted, dseffsz);
        sumdsat = conv2_fftvalid(dsalarge, dstflipShifted, dseffsz);

        dsequation = (sumdsa2 + sumdst2 - sumdsat * 2) ./ denominator;

        [~,mind] = min(dsequation(:));
        [dr,dc]  = ind2sub(dseffsz, mind); 

        % in normal space:
        dr = (dr - maxsft/2 - 1)*2; dc = (dc - maxsft/2 - 1)*2; 
        a = a(maxsft+dr:height-maxsft+dr+1, maxsft+dc:width-maxsft+dc+1);
        equation = conv2_fftvalid(a,tcentralshift,[3 3]);
        [~,maxd] = max(equation(:));
        [ddr,ddc] = ind2sub([3 3], maxd); 
        
        % flip this! We were registering t onto a, but time changes dude!
        rt(frm,:) = -[dr+ddr-2, dc+ddc-2];
        
        % which area we need to copy & paste?
        if rt(frm,1)<=0 , rowsout = 1:height+rt(frm,1); rowsin = 1-rt(frm,1):height;
        else            , rowsout = 1+rt(frm,1):height; rowsin = 1:height-rt(frm,1); end
        if rt(frm,2)<=0 , colsout = 1:width +rt(frm,2); colsin = 1-rt(frm,2):width ;
        else            , colsout = 1+rt(frm,2):width ; colsin = 1:width -rt(frm,2); end
        regout(rowsout,colsout,frm) = moving(rowsin,colsin,frm);            
    end


%% some final stuff
if verbose, fprintf('%s: %d frames cost %.2fs\n', mfilename, nFrames, toc(t0)); end
end

function y = conv2_fftvalid(x, mshift, fsize)
% 2d convolution using FFT. A simplified implementation of conv2, with option 'valid'.
% Written by Weihao Sheng, 2020-05-24
    y = ifft2(fft2(x) .* fft2(mshift));   % use fft & ifft to calculate conv2
    y = real(y(1:fsize(1), 1:fsize(2)));  % trim to proper size, 'valid' should be size(x-m+1)
end

function mout = cshift(m, px)
% circularly shift the matrix in px pixels so that it matches conv2_fftvalid
    % first, we need to make it larger    
    mout = zeros(size(m)+px); 
    % the indices below are optimised specifically for calculating conv2
    mout(1,1) = m(end,end);
    mout(px+2:end,1)=m(1:end-1,end);
    mout(1,px+2:end)=m(end,1:end-1);
    mout(px+2:end,px+2:end) = m(1:end-1,1:end-1);
end