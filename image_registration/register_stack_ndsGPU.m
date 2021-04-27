function [rt, regout] = register_stack_ndsGPU(moving, template, params)
%register_stack_ndsGPU.m fast image registration using GPU
%   RT = register_stack_ndsGPU.m(MOVING, TEMPLATE, PARAMS) analyses movements in the video 
%   and outputs a table comprising offsets in X-Y direction. 
%   [..., REGOUT] = register_stack_ndsGPU.m() also outputs registered stack if needed.
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

%% Input validation
% For simplicity, we make the following assumptions that:
%  * Inputs MOVING is a 3-dim matrix.
%  * Input MOVING and TEMPLATE share the same frame size.

if nargin < 3, params = []; end

[height, width, nFrames] = size(moving);    
maxsft = get_option(params, 'maxsft', round(min(height, width)/8.0));
% mcontsft = get_option(params, 'mcontsft', []);
% subpix = get_option(params, 'subpix', []);
verbose = get_option(params, 'verbose', 0); % function as a timer

%% computation
    
if verbose, t0 = tic; end

    % just to ensure they are in GPU now
    moving = gpuArray(moving); template = gpuArray(template);

    % lets define some fast & readable actions
    normalise = @(im) (double(im) - mean(im(:))) / std(double(im(:))) / sqrt(2);
    surround0 = @(im,w) [ zeros(w+w+size(im,1),w), [zeros(w,size(im,2));im;zeros(w,size(im,2))], zeros(w+w+size(im,1),w)];
    rotate180 = @(im) im(end:-1:1, end:-1:1);

    % ...as well as some rptdly used variables
    effsz = 2 * [maxsft, maxsft] + 1;
    onesShifted = cshift(ones(height,width), effsz-1);
    
    % process template 
    t = normalise(template); 
    tflip = rotate180(t); tflipShifted = cshift(tflip, effsz-1);
    tfliplarge = surround0(tflip, maxsft); % template rotated and padded
    sumt2 = conv2_fftvalid(tfliplarge.^2, onesShifted, effsz);
    
    % alarge the container for the unregistered frame
    alarge = gpuArray.zeros(height+2*maxsft, width+2*maxsft);
    
    % overlap pixels count
    denominator = conv2_fftvalid(surround0(ones(height,width),maxsft), onesShifted, effsz);
    
    % actual registration
    rt = gpuArray.zeros(nFrames, 2);
    
    if nargout == 1 % rt only
        
        for frm = 1:nFrames

            alarge(maxsft+(1:height), maxsft+(1:width)) = normalise(moving(:,:,frm));
            suma2 = conv2_fftvalid(alarge.^2, onesShifted, effsz);
            sumat = conv2_fftvalid(alarge, tflipShifted, effsz);

            equation = (suma2 + sumt2 - sumat * 2) ./ denominator;

            [~,mind] = min(equation(:));
            [dy,dx]  = ind2sub(effsz, mind); 

            % we were registering t onto a, and now we want a to be moved onto t, range flips
            rt(frm,:) = -([dy,dx] - maxsft - 1);          
        end
        
    elseif nargout == 2
        
        regout = gpuArray.zeros([height, width, nFrames], classUnderlying(moving));
        
        for frm = 1:nFrames

            alarge(maxsft+(1:height), maxsft+(1:width)) = normalise(moving(:,:,frm));
            suma2 = conv2_fftvalid(alarge.^2, onesShifted, effsz);
            sumat = conv2_fftvalid(alarge, tflipShifted, effsz);

            equation = (suma2 + sumt2 - sumat * 2) ./ denominator;

            [~,mind] = min(equation(:));
            [dy,dx]  = ind2sub(effsz, mind); 

            % we were registering t onto a, and now we want a to be moved onto t, range flips
            rt(frm,:) = -([dy,dx] - maxsft - 1); 
            
            % which area we need to copy & paste?
            if rt(frm,1)<=0 , rowsout = 1:height+rt(frm,1); rowsin = 1-rt(frm,1):height;
            else            , rowsout = 1+rt(frm,1):height; rowsin = 1:height-rt(frm,1); end
            if rt(frm,2)<=0 , colsout = 1:width +rt(frm,2); colsin = 1-rt(frm,2):width ;
            else            , colsout = 1+rt(frm,2):width ; colsin = 1:width -rt(frm,2); end
            regout(rowsout,colsout,frm) = moving(rowsin,colsin,frm);            
        end
        
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
    mout = gpuArray.zeros(size(m)+px); 
    % the indices below are optimised specifically for calculating conv2
    mout(1,1) = m(end,end);
    mout(px+2:end,1)=m(1:end-1,end);
    mout(1,px+2:end)=m(end,1:end-1);
    mout(px+2:end,px+2:end) = m(1:end-1,1:end-1);
end