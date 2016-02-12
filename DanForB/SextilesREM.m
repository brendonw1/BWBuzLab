
[names,dirs] = GetDefaultDataset;
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    load(fullfile(basepath,[basename '_SSubtypes.mat']));
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
    load(fullfile(basepath,[basename '_StateRates.mat']));
 
    SWSints = REMInts;
    SWSints = intersect(SWSints,SleepInts);
    SWSlen = Data(length(SWSints,'s'));

    [~,sortrate] = sort(StateRates.EWSWakeRates);
    SeRates_W = StateRates.EWSWakeRates;

    %%
    dt = 0.5; %s
    overlap = 10;
    [spikemat,t] = SpktToSpkmat(Se, [], dt,overlap);
    spikemat = spikemat./(dt*overlap);

    [unitepochs,droppedints] = IsolateEpochs2(spikemat,StartEnd(SWSints,'s'),SWSlen,1/dt);

    %%
    numbins = 50;
    [normunitpack] = TimeNormalize(unitepochs,numbins*3);
    t_norm = [1:numbins*3]/numbins-1;

    Semeanfr = squeeze(mean(cat(3,normunitpack{:}),3));

    SeFRAll{a} = Semeanfr;
    SeRatesAll{a} = SeRates_W;
    % I return Semeanfr and SeRates_W for each recording in a cell array. Which I then combine and plot with this:
    disp(basename);
end


SePacketFR = [SeFRAll{:}];
SeRate = vertcat(SeRatesAll{:});
[~,sortrate] = sort(SeRate);

numdistbins = 6;
FR_percentiles = SortedPercentiles(SePacketFR,sortrate,numdistbins);



    subplot(2,1,2)
        set(gca, 'ColorOrder', OrangeColorsConfined(numdistbins));
        hold all
        plot(t_norm,log10(FR_percentiles),'LineWidth',3)
        ylim([-1 0.5])
        plot([0 0],get(gca,'ylim'),'k') 
        plot([1 1],get(gca,'ylim'),'k') 
        xlim([-0.1 1.1])
        xlabel('NREM Episode Normalized Time');
        ylabel('Mean FR (Hz)')
        set(gca,'YTick',[-3:0.5:1])
        set(gca,'YTickLabel',10.^[-3:0.5:1])