function im = im_smart(im)
im = double(im);
m = mean(im(:));
s = std(im(:));
minim = m - 0.5*s;
maxim = m + 5*s;
im = (im-minim) / (maxim-minim);
im(im<0) = 0; im(im>1) = 1;
end