function localcorrmap = im_localcorr(data)
%t = tic;
[h,w,nf] = size(data);
data = double(gather(data));
localcorrmap = zeros(h,w);
for r = 2:h-1
    for c = 2:w-1
        corrval = corr(squeeze(data(r,c,:)), reshape(data(r-1:r+1, c-1:c+1, :), [9, nf])');
        localcorrmap(r,c) = (sum(corrval)-1)/8;
    end
end
%fprintf('localcorr cost %.3f s\n', toc(t));
end