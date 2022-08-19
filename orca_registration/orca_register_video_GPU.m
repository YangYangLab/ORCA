function [rt, regout] = orca_register_video_GPU(moving, template, varargin)
%orca_register_video_GPU  faster image registration using GPU and downsampling
%   same inputs and outputs as orca_register_video_CPU
%
% Inspired by moco algorithm:
%   Dubbs, A., Guevara, J., & Yuste, R. (2016). moco: Fast Motion Correction for Calcium 
%   Imaging. Frontiers in neuroinformatics, 10, 6. https://doi.org/10.3389/fninf.2016.00006

%   Written by Weihao Sheng, 2019-10-09
%   Yang Yang's Lab of Neural Basis of Learning and Memory,
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

%% Input validation

[height, width, nFrames] = size(moving); 
if any([mod(height,2) mod(width,2)]), error('height and width must be even numbers\n'); end

p = inputParser; p.KeepUnmatched = true; p.CaseSensitive = false; p.PartialMatching = true;
addParameter(p, 'maxshift', round(min(height, width)/8.0));
addParameter(p, 'debug', false)
parse(p, varargin{:})
p = p.Results;
maxsft = floor(p.maxshift/2)*2; % round maxshift to even number
p.regout = (nargout == 2);

%% computation
    
    if p.debug, t0 = tic; end

    % move into GPU
    moving = gpuArray(moving); template = gpuArray(template);

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
    dsalarge = gpuArray.zeros(height/2+maxsft, width/2+maxsft);
    
    % overlap pixels count
    denominator = conv2_fftvalid(surround0(ones(height/2,width/2),maxsft/2), dsonesShifted, dseffsz);
    
    % actual registration
    rt = gpuArray.zeros(nFrames, 2);
    if p.regout, regout = gpuArray.zeros([height, width, nFrames], classUnderlying(moving)); end
        
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
        if p.regout
            if rt(frm,1)<=0 , rowsout = 1:height+rt(frm,1); rowsin = 1-rt(frm,1):height;
            else            , rowsout = 1+rt(frm,1):height; rowsin = 1:height-rt(frm,1); end
            if rt(frm,2)<=0 , colsout = 1:width +rt(frm,2); colsin = 1-rt(frm,2):width ;
            else            , colsout = 1+rt(frm,2):width ; colsin = 1:width -rt(frm,2); end
            regout(rowsout,colsout,frm) = moving(rowsin,colsin,frm); 
        end
    end

%% some final stuff
if p.debug, fprintf('%s: %d frames cost %.2fs\n', mfilename, nFrames, toc(t0)); end
end

function y = conv2_fftvalid(x, mshift, fsize)
% 2d convolution using FFT. A simplified implementation of conv2, with option 'valid'.
% GPU-based fft2 & ifft2 is way faster
% Written by Weihao Sheng, 2020-05-24

    y = ifft2(fft2(x) .* fft2(mshift));
    y = real(y(1:fsize(1), 1:fsize(2)));
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
