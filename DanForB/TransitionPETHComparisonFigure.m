function pethfig = TransitionPETHComparisonFigure(pethtimes,pethdata)
% Makes figure to plot data in format of output of IntervalPETH.m

1;

if iscell(pethdata)
    numstates = size(pethdata,2);
else
    numstates = 1;
end

figname = 'IntervalPETH';
pethfig = figure('name',figname,'position',[2 2 600 600]);

if numstates > 1
    for a = 1:numstates
        numepochs = size(pethdata,1);

        normmean(:,a) = nanmean(pethdata{a},2);
        normstd(:,a) = nanstd(pethdata{a},[],2);
    end        

    boundedline(repmat(pethtimes',1,numstates),...
        normmean,...
        normstd,...
        'transparency',.5,'alpha');
    plot([0 0],get(gca,'ylim'),'k')
end