function mask = amplifier(data, TRIALDEF, ACQ, alpha, sig, thradj)
% ORCA's Amplifier algorithm for online trial-based cell segmentation
%   BMAP = orca_segment_mask_Amplifier(DATA, TRIALDEF, ACQ, a, sig, thradj)
%       identifies possible cell-like pixels in ONE-TRIAL-containing DATA
%       trial structure defined in TRIALDEF, a struct containing 
%           baseline(pre-stim time, s),
%           interest(post-stimulus-onset or post-stimulus, the time range to observe, s)        
%       acquisition params defined in ACQ, containing 
%           fps(frame rate), 
%           cell_diameter(in pixels), 
%           dynamic_time(fluo rise&decay time, s)
%       returns binary BMAP with pixels
%       
% For explanations on the Amplifier algorithm, see the ORCA paper.
% See also ORCAUI_TEST_AMPLIFIER.

%   Weihao Sheng, 2021-08-12
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China


    data = single(data);

    % convert time(s) to frame
    fBaseline = fix(TRIALDEF.baseline * ACQ.fps) + [1 0]; fBaseline = fBaseline(1):fBaseline(2); 
    fInterest = fix(TRIALDEF.interest * ACQ.fps) + [1 0]; fInterest = fInterest(1):fInterest(2);
    
    % acquisition 
    cdiameter = ACQ.cell_diameter; 
    fluotime = ACQ.dynamic_time;
    
    % data binarized by baseline activity
    zeromap = mean(data(:,:,fBaseline),3);
    varmap  = std(data(:,:,fBaseline),[],3);
    data    = data > (zeromap + sig*varmap); 

    % compute cumulative significance
    sigcumul = zeros(size(data));
    for x = fInterest(1):fInterest(end)
        sigframe = (sigcumul(:,:,x-1) + 1/alpha) .* alpha .* data(:,:,x);
        sigframe(sigframe<0) = 0;
        sigcumul(:,:,x) = sigframe;
    end
    sigcumul = sum(sigcumul, 3);

    % smooth to connect neighbours
    weightmap = im_convfft(sigcumul, gauss2d(ones(cdiameter),1,[cdiameter/2 cdiameter/2]), 'same');
    
    % cutoff threshold: how many continuous frames would be considered a valid signal?
    mask = weightmap>(alpha ^ (ACQ.fps*fluotime) + thradj);

end

function mat = gauss2d(mat, sigma, center)
    % generate a 2d gauss curve
    gsize = size(mat);
    for r=1:gsize(1)
        for c=1:gsize(2)
            mat(r,c) = gaussC(r,c, sigma, center);
        end
    end
end
function val = gaussC(x, y, sigma, center)
    xc = center(1);
    yc = center(2);
    exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma);
    val       = (exp(-exponent));
end
