function mask = RE(data, TRIALDEF, ACQ, a, sig, thradj)
% ORCA's RenyiEntropy-based algorithm for online trial-based cell segmentation
%   MASK = orca_segment_mask_RenyiEntropy(DATA, TRIALDEF, ACQ, a, sig, thradj)
% For explanations about this algorithm, see the ORCA paper.
% See also ORCA_SEGMENT_MASK_AMPLIFIER.

%   Weihao Sheng, 2020-11-14
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

    fBaseline = fix(TRIALDEF.baseline * ACQ.fps) + [1 0]; fBaseline = fBaseline(1):fBaseline(2); 
    fInterest = fix(TRIALDEF.interest * ACQ.fps) + [1 0]; fInterest = fInterest(1):fInterest(2);
    
    % compute df/f video and set <0 to 0
    data = single(data);
    vdf = orca_trace_stack_dff(data, fBaseline);
    vdf(vdf<0)=0;

    avdf = mean(vdf(:,:,fInterest), 3);

    % RenyiEntropy binarize as mask
    MIJ.createImage('thresh', avdf, true);
    MIJ.run("8-bit")
    MIJ.run("Auto Threshold", "method=RenyiEntropy white");
    mask = MIJ.getImage('thresh');
    MIJ.close()

    % smooth and binarize
    mask = imgaussfilt(mask, 2);
    mask = (mask>10);

    % leaving an annoying, unclosable Fiji window...
end

