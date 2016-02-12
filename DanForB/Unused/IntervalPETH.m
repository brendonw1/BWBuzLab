function [epochs,PETH,epaligned] = IntervalPETH(data,int,tbins4norm,sf,plotparams)
%[epochs,intlengths] = IntervalPETH(data,int,tbins4norm,sf) plots the onset,
%offset, and time-normalized PETH of continuous time data to intervals.
%
%INPUT
%   data        [t x 1] time series data
%   int         [Nints x 2] set of interval on and offsets
%   tbins4norm  number of time bins for time normalization
%   sf          sampling frequency
%   plotparams   (optional)
%       .title
%       .sort
%       .figname
%       .saveloc
%       .xview
%       .figformat (default = jpg)
%       .prepostsec (default = [-10 20])
%
%OUTPUT
%   epochs      cell array of epoch times
%   intlengths  time duration of intervals (for later plotting)
%
%OPTIONAL: put in epochs/intlengths as data/int to plot previously calculated
%intervals. For example, to combine across recordings.
%
%
%Dependencies:
%   IsolateEpochs2, CellToNaNMat, TimeNormalize
%
%TO DO:
%   -Output PETH mean/var/t_align.
%
%
%Last Updated: 9/18/16
%DLevenstein
%%
%Distinguish between single time series input and interval timeseries input
plotting = 0;

ok = 1;
if iscell(data) && length(int(1,:))==1
    epochs = data;
    intlengths = int;
elseif ~iscell(data) 
    if isa(int,'intervalSet')
        ints = StartEnd(int,'s');
    elseif isa(int,'double') & length(int(1,:))==2
        intlengths = int(:,2)-int(:,1);
        [epochs,dropped] = IsolateEpochsBW(data,int,intlengths,sf);
    else
        display('Something is not right with your input!')
    end
end

numepochs = length(epochs);

%Make On/Offset aligned matrices
[align_onset,t_align_on] = CellToNaNMat(epochs,intlengths,intlengths,sf);
[align_offset,t_align_off] = CellToNaNMat(epochs,-intlengths,intlengths,sf);
onsetmean = nanmean(align_onset,2);
offsetmean = nanmean(align_offset,2);
onsetstd = nanstd(align_onset,[],2);
offsetstd = nanstd(align_offset,[],2);

%Make time normalized matrix
[timenormepochs] = TimeNormalize(epochs,tbins4norm*3);
[align_norm,t_norm] = CellToNaNMat(timenormepochs,1,0,tbins4norm);
normmean = nanmean(align_norm,2);
normstd = nanstd(align_norm,[],2);

%Output the PETH
PETH.onset = onsetmean(~isnan(onsetmean));
PETH.offset = offsetmean(~isnan(offsetmean));
PETH.norm = normmean(~isnan(normmean));

PETH.onset_std = onsetstd(~isnan(onsetmean));
PETH.offset_std = offsetstd(~isnan(offsetmean));
PETH.norm_std = normstd(~isnan(normmean));

PETH.onset_t =t_align_on(~isnan(onsetmean));
PETH.offset_t = t_align_off(~isnan(offsetmean));
PETH.norm_t =t_norm(~isnan(normmean));


%Output the Aligned Epochs
epaligned.align_onset = align_onset;
epaligned.align_offset = align_offset;
epaligned.align_norm = align_norm;
epaligned.t_align_on = t_align_on;
epaligned.t_align_off = t_align_off;
epaligned.t_norm = t_norm;

%% Figure
if plotting
    plotparams.init = [];
    if isfield(plotparams,'title')
        plottitle = plotparams.title;
    else
        plottitle = 1:numepochs;
    end
    if isfield(plotparams,'sort')
        sortepochs = plotparams.sort;
        %sortepochs(sortepochs==dropped) = [];
    else
        sortepochs = 1:numepochs;
    end
    if isfield(plotparams,'figname')
        figname = plotparams.figname;
        savename = plotparams.figname;
        saveloc = plotparams.saveloc;
    else
        figname = 'IntervalPETH';
    end

    if isfield(plotparams,'xview')
        xview_on = [-plotparams.xview(1) plotparams.xview(2)];
        xview_off = [-plotparams.xview(2) plotparams.xview(1)];
    else
        xview_on = [-10 20];
        xview_off = -fliplr(xview_on);
    end

    if isfield(plotparams,'sortname')
        ysort = ['Sorted by ',plotparams.sortname];
    else
        ysort = [];
    end

    if isfield(plotparams,'figformat')
        figformat = plotparams.figformat;
    else
        figformat = 'jpg';
    end

    if isfield(plotparams,'prepostsec')
        prepostsec = plotparams.prepostsec;
    else
        prepostsec = [-10 20];
    end
    prepostsec = sort(prepostsec);


    randex = randi(length(epochs));
    pethfig = figure('name',figname,'position',[2 2 600 600]);
        %All Epochs
        subplot(4,3,[1,4])
            hold on
%         images'c(t_align_on,1:numepochs,nanzscore(align_onset(:,sortepochs))')
        imagesc(t_align_on,1:numepochs,bwnormalizebymean_array(align_onset(:,sortepochs)'))
            xlim(xview_on);ylim([0.5 numepochs+0.5])
            ylabel({'Epochs',ysort})
            title('Align to Onset')
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,[3,6])
            hold on
%         imagesc('t_align_off,1:numepochs,nanzscore(align_offset(:,sortepochs))')
        imagesc(t_align_off,1:numepochs,bwnormalizebymean_array(align_offset(:,sortepochs)'))
            xlim(xview_off);ylim([0.5 numepochs+0.5])
            title('Align to Offset')
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,[2,5])
            hold on
%         imagesc(t_norm,1:numepochs,nanzscore(align_norm(:,sortepochs))')
        imagesc(t_norm,1:numepochs,bwnormalizebymean_array(align_norm(:,sortepochs)'))
            xlim([-0.2 1.2,]);ylim([0.5 numepochs+0.5])
            title({plottitle,'Time-Normalized'})
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
            plot([1 1],get(gca,'ylim'),'k')

        %Example Epoch
        subplot(4,3,7)
            hold on
            plot(t_align_on,align_onset(:,randex),'k')
            ylabel('Random Epoch')
            xlim(xview_on)
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,8)
            hold on
            plot(t_norm,align_norm(:,randex),'k')
            xlim([-0.2 1.2]);
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
            plot([1 1],get(gca,'ylim'),'k')
        subplot(4,3,9)
            hold on
            plot(t_align_off,align_offset(:,randex),'k')
            xlim(xview_off)
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        %Mean Epoch
        subplot(4,3,10)
            hold on
            plot(t_align_on,onsetmean,'k')
            plot(t_align_on,onsetmean+onsetstd,'k:')
            plot(t_align_on,onsetmean-onsetstd,'k:')
            ylabel('Mean/Std Epoch');xlabel('t, aligned to onset (s)')
            xlim(xview_on) 
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,11)
            hold on
            plot([0 0],[-100 100],'k')
            plot([1 1],[-100 100],'k')
            plot(t_norm,normmean,'k')
            plot(t_norm,normmean+normstd,'k:')
            plot(t_norm,normmean-normstd,'k:')
            xlabel('t, normalized (s)')
            xlim([-0.2 1.2])
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
            plot([1 1],get(gca,'ylim'),'k')
        subplot(4,3,12)
            hold on
            plot(t_align_off,offsetmean,'k')
            plot(t_align_off,offsetmean+offsetstd,'k:')
            plot(t_align_off,offsetmean-offsetstd,'k:')
            xlabel('t, aligned to offset (s)')
            xlim(xview_off)
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')

    if exist('savename','var')
        saveas(pethfig,fullfile(saveloc,savename),figformat)
    end
end

end

