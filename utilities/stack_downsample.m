function vout = stack_downsample(stack, ds)
%STACK_DOWNSAMPLE Resize stackeo to smaller frames
%   VOUT = STACK_DOWNSAMPLE(STACK, DS) shrinks the stackeo to a smaller size by a factor of DS.
%   Height & width of the new stackeo will be 1/DS of the original one.
%
%   See also STACK_UPSAMPLE.

%   Weihao Sheng, 2020-04-12
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

if ds == 2
    
    stack = [stack; stack(end,:,:)]; stack = [stack, stack(:,end, :)];
    vout = double(stack(1:2:end,1:2:end,:) + stack(1:2:end,2:2:end,:) + stack(2:2:end,1:2:end,:) + stack(2:2:end,2:2:end,:))./4;
    
else
    
	hnew = 1/ds*size(stack,1); wnew = 1/ds*size(stack,2);
    nFrames = size(stack, 3);
    vout = zeros(hnew, wnew, nFrames, class(stack));
    
    for f = 1:nFrames
        vout(:,:,f) = imresize(stack(:,:,f), [hnew wnew], 'bilinear');
    end 
    
end
end
