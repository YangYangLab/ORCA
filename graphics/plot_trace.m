function ax = PlotTrace(trace, tracenames, trialStructure)

idxstart = (mapidx-1)*tcnum+1;
idxend = min(mapidx*tcnum,size(roitc,2));
xtick = explog(:,6)';

fig=figure('Visible', 'off');

maxtc = max(roitc(:));

[nTrace, nTrials, 
for i = 1:tcnum+1
    subplot('Position',[0.05 0.9-(0.9/(tcnum+1))*(i-1) 0.9 0.9/(tcnum+1)]);
    hold on
    for j = 1:stimnum
        if (mapidx-1)*tcnum+i<=size(roitc,2) || i==tcnum+1
            x = [explog(j,5) explog(j,6) explog(j,6) explog(j,5)]/zbin;
            y = [0 0 maxtc maxtc];
            patch(x,y,[0.5,0.3,0.3],'EdgeColor','none','FaceAlpha',.6*explog(j,3)/VolGrad)
            x = [explog(j,6)/zbin j*totalframe j*totalframe explog(j,6)/zbin ];
            y = [0 0 maxtc maxtc];
            patch(x,y,[0.7,0.7,0.7],'EdgeColor','none','FaceAlpha',.6)
        end
    end
    
    if i <= tcnum
        tcidx = (mapidx-1)*tcnum+i;
        if tcidx <=size(roitc,2)
            plot(roitc(:,tcidx));
            ylabel(strcat('',num2str(tcidx)));
            set(gca,'FontSize',8);
            set(gca,'xlim',[0,framenum+1],'ylim',[min(roitc(:)), maxtc])
            %                     set(gca,'xlim',[0,framenum+1],'ylim',[min(roitc(:,tcidx)),max(roitc(:,tcidx))])
            set(gca, 'XTick', [], 'XTickLabel', [],'YTick', [])
        else
            set(gca, 'XTick', [], 'XTickLabel', [],'YTick', [])
        end
        
    else
        meantc= mean(roitc,2);
        plot(meantc);
        ylabel('AVG');
        set(gca,'xlim',[0,framenum+1],'ylim',[min(roitc(:)),max(roitc(:))])
        %                 set(gca, 'YTick', ytick,'YTickLabel',{'0','1','2','3'})
        set(gca,'Xtick',xtick,'XTickLabel',xticklable)
        set(gca,'FontSize',8);
        
        axesPosition = get(gca, 'Position');
        rightAxes = axes('Position', axesPosition, ...  % Place a new axes on top...
            'Color', 'none', ...           %   ... with no background color
            'YLim', [0,maxtc], ...            %   ... and a different scale
            'YAxisLocation', 'right', ...  %   ... located on the right
            'XTick', [],...
            'Box', 'off');
    end
    hold off
end
set(gcf,'unit','normalized','position',[0.05,0.05,0.9,0.8]);
set(gcf,'color','white','paperpositionmode','auto');
savename = strcat(resultfolder,'_Timecourse',num2str(idxstart),'--',num2str(idxend),'.Tiff');
f=getframe(gcf);
imwrite(f.cdata,savename,'tif');
close(fig);
end