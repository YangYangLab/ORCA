function im = plot_contour_(summaryimage, map)

im = imshow(mat2gray(summaryimage));
hold on
contour(map>0, 'Color', 'r'); 
%plot_add_scalebar(gobj.SummaryImage, ORCA.Experiment.Imaging.PixelSizeum, 'Color', [1 1 1]);
end