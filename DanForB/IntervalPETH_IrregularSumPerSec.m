function [epochdatapoints,PETH,epaligned] = IntervalPETH_IrregularSumPerSec(datavals,datatimes,int,tbins4norm,sf,plotparams)
%[epochdatapoints,intlengths] = IntervalPETH(data,int,tbins4norm,sf) plots the onset,
%offset, and time-normalized PETH of continuous time data to intervals.
%
%INPUT
%   datavals    [t x n] time series data points, over N dimensions
%   datatimes   [t x 1] time series time points, one for each datapoint row
%   int         [Nints x 2] set of interval on and offsets
%   tbins4norm  number of time bins for time normalization
%   sf          sampling frequency - used to set re-binning time for
%                   non-norm data
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
%   epochdatapoints      cell array of epoch times
%   intlengths  time duration of intervals (for later plotting)
%
%OPTIONAL: put in epochdatapoints/intlengths as data/int to plot previously calculated
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
%DLevenstein
%Brendon Watson

%%
% input handling and some presets
plotting = 0;

if isa(int,'intervalSet')
    int = StartEnd(int,'s');
end
sampoverhangs = int(:,2)-int(:,1);

% pull out epochdatapoints of data within and surrounding the ints.  epochdatapoints
% is a cell array of vectors/matrices, epochdatapointsamptimes is a cell array of
% vectors of timepoints
[epochdatapoints,epochdatapointsamptimes] = IsolateEpochsBW(datavals,int,sampoverhangs,datatimes);

% make re-binned version of epochdatapoints, based on the demanded sample frequency
[align_onset,align_offset,align_norm,onbins,offbins,normbins] = ...
    BinEpochsSumPerSecToOnOffNorm(epochdatapoints, epochdatapointsamptimes, int, sf, tbins4norm, sampoverhangs);
numepochdatapoints = length(epochdatapoints);

%Make On/Offset aligned matrices
% [align_onset,t_align_on] = CellToNaNMat(epochdatapoints,sampoverhangs,sampoverhangs,sf);
% [align_offset,t_align_off] = CellToNaNMat(epochdatapoints,-sampoverhangs,sampoverhangs,sf);
onsetmean = nanmean(align_onset,2);
offsetmean = nanmean(align_offset,2);
onsetstd = nanstd(align_onset,[],2);
offsetstd = nanstd(align_offset,[],2);

%Make time normalized matrix
% [timenormepochdatapoints] = TimeNormalize(epochdatapoints,tbins4norm*3);
% [align_norm,t_norm] = CellToNaNMat(timenormepochdatapoints,1,0,tbins4norm);
normmean = nanmean(align_norm,2);
normstd = nanstd(align_norm,[],2);

%Output the PETH
PETH.onset = onsetmean;
PETH.offset = offsetmean;
PETH.norm = normmean;

PETH.onset_std = onsetstd;
PETH.offset_std = offsetstd;
PETH.norm_std = normstd;

PETH.onset_t =onbins(~isnan(onsetmean));
PETH.offset_t = offbins(~isnan(offsetmean));
PETH.norm_t =normbins(~isnan(normmean));


%Output the Aligned Epochs
epaligned.align_onset = align_onset;
epaligned.align_offset = align_offset;
epaligned.align_norm = align_norm;
epaligned.t_align_on = onbins;
epaligned.t_align_off = offbins;
epaligned.t_norm = normbins;

%% Figure
if plotting
    plotparams.init = [];
    if isfield(plotparams,'title')
        plottitle = plotparams.title;
    else
        plottitle = 1:numepochdatapoints;
    end
    if isfield(plotparams,'sort')
        sortepochdatapoints = plotparams.sort;
        %sortepochdatapoints(sortepochdatapoints==dropped) = [];
    else
        sortepochdatapoints = 1:numepochdatapoints;
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


    randex = randi(length(epochdatapoints));
    pethfig = figure('name',figname,'position',[2 2 600 600]);
        %All Epochs
        subplot(4,3,[1,4])
            hold on
%         images'c(t_align_on,1:numepochdatapoints,nanzscore(align_onset(:,sortepochdatapoints))')
        imagesc(onbins,1:numepochdatapoints,bwnormalizebymean_array(align_onset(:,sortepochdatapoints)'))
            xlim(xview_on);ylim([0.5 numepochdatapoints+0.5])
            ylabel({'Epochs',ysort})
            title('Align to Onset')
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,[3,6])
            hold on
%         imagesc('t_align_off,1:numepochdatapoints,nanzscore(align_offset(:,sortepochdatapoints))')
        imagesc(offbins,1:numepochdatapoints,bwnormalizebymean_array(align_offset(:,sortepochdatapoints)'))
            xlim(xview_off);ylim([0.5 numepochdatapoints+0.5])
            title('Align to Offset')
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,[2,5])
            hold on
%         imagesc(t_norm,1:numepochdatapoints,nanzscore(align_norm(:,sortepochdatapoints))')
        imagesc(normbins,1:numepochdatapoints,bwnormalizebymean_array(align_norm(:,sortepochdatapoints)'))
            xlim([-0.2 1.2,]);ylim([0.5 numepochdatapoints+0.5])
            title({plottitle,'Time-Normalized'})
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
            plot([1 1],get(gca,'ylim'),'k')

        %Example Epoch
        subplot(4,3,7)
            hold on
            plot(onbins,align_onset(:,randex),'k')
            ylabel('Random Epoch')
            xlim(xview_on)
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,8)
            hold on
            plot(normbins,align_norm(:,randex),'k')
            xlim([-0.2 1.2]);
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
            plot([1 1],get(gca,'ylim'),'k')
        subplot(4,3,9)
            hold on
            plot(offbins,align_offset(:,randex),'k')
            xlim(xview_off)
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        %Mean Epoch
        subplot(4,3,10)
            hold on
            plot(onbins,onsetmean,'k')
            plot(onbins,onsetmean+onsetstd,'k:')
            plot(onbins,onsetmean-onsetstd,'k:')
            ylabel('Mean/Std Epoch');xlabel('t, aligned to onset (s)')
            xlim(xview_on) 
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
        subplot(4,3,11)
            hold on
            plot([0 0],[-100 100],'k')
            plot([1 1],[-100 100],'k')
            plot(normbins,normmean,'k')
            plot(normbins,normmean+normstd,'k:')
            plot(normbins,normmean-normstd,'k:')
            xlabel('t, normalized (s)')
            xlim([-0.2 1.2])
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')
            plot([1 1],get(gca,'ylim'),'k')
        subplot(4,3,12)
            hold on
            plot(offbins,offsetmean,'k')
            plot(offbins,offsetmean+offsetstd,'k:')
            plot(offbins,offsetmean-offsetstd,'k:')
            xlabel('t, aligned to offset (s)')
            xlim(xview_off)
            ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
            plot([0 0],get(gca,'ylim'),'k')

    if exist('savename','var')
        saveas(pethfig,fullfile(saveloc,savename),figformat)
    end
end

end

