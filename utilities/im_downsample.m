function imout = im_downsample(im, ds)
%IM_DOWNSAMPLE Resize video to smaller frames
%   IMOUT = IM_DOWNSAMPLE(IM, DS) shrinks the image to a smaller size by a factor of DS.
%   Height & width of the new image will be 1/DS of the original one.
%
%   See also VID_DOWNSAMPLE.

%   Weihao Sheng, 2020-04-23
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

if ds == 2

    imout = ( im(1:2:end,1:2:end,:) + im(2:2:end,1:2:end,:) + ...
              im(1:2:end,2:2:end,:) + im(2:2:end,2:2:end,:)) ./ 4;

else
    
	hnew = 1/ds*size(im,1); wnew = 1/ds*size(im,2);

    imout(:,:) = cast(imresize(im(:,:,f), [hnew wnew], 'bilinear'), class(im));

    
end
end
