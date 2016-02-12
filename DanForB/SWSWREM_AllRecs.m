%%SWSWREM_AllRecs.m
%Description:   Run state-dependent heterogeneities analyses on all 
%               recordings 
%
%TO DO:
%   -Comment and clean script
%   -Re-Run with goodsleeps
%   -Comment and clean functions
%   -Summary figures - for each recording
%
%DLevenstein

datafolder = '/mnt/data1/BWData/';


SAVERESULTS = true;
SAVEFIGS = true;

%Make List of all Recordings in data folder
recordings = dir(datafolder);
recordings(1:2) = [];   %Remove first two entries, which are .. and .

numrecs = length(recordings);
%%
for r =1:numrecs
    display(['Recording ',num2str(r),' of ',num2str(numrecs)])
    
    intervaldata = [datafolder,recordings(r).name,'/',...
        recordings(r).name,'_Intervals.mat'];
    spikesdata = [datafolder,recordings(r).name,'/',...
        recordings(r).name,'_SSubtypes.mat'];
    
    goodintervals = ['/home/dlevenstein/Dropbox/Science/Buzsaki Lab/Data Analysis/Database/GoodSleep/',...
        recordings(r).name,'_GoodSleepInterval.mat'];
    
    load(intervaldata)
    load(spikesdata)
    load(goodintervals)
    
%     if (RunCORR | RunPETH | RunstPR)
%     UPdata = [datafolder,recordings(r).name,'/',...
%     recordings(r).name,'_UPSpikeStatsE.mat'];
% 
%     load(UPdata)
% 
%     end


    %% Analyses - FR, Bursting, Pairwise Correlation, stPR

    states = [1,3,5];
    [StateFR_out] = StateFR(Se,intervals,states,GoodSleepInterval);
    [StateBurst_out] = StateBurst(Se,intervals,states,GoodSleepInterval);
    [StatePairCorr_out] = StatePairCorr(Se,intervals,states,GoodSleepInterval);

    dt = 0.02;
    [stPR,stxcorr,t_corr] = SpkTrigPopRate(Se,intervals,states,dt );


    if SAVERESULTS
        %Add analyses to structure
        recdata(r).FR_wake = StateFR_out(:,1)';
        recdata(r).FR_SWS = StateFR_out(:,2)';
        recdata(r).FR_REM = StateFR_out(:,3)';

        recdata(r).ISIhists = StateBurst_out.ISIhist;
        recdata(r).ISIhistbins = StateBurst_out.logISIhistbins;
        recdata(r).burstindex = StateBurst_out.burstindex;

        recdata(r).corrmat_wake = StatePairCorr_out(:,:,1);
        recdata(r).corrmat_SWS = StatePairCorr_out(:,:,2);
        recdata(r).corrmat_REM = StatePairCorr_out(:,:,3);

        recdata(r).stPR = stPR;
        recdata(r).stxcorr = stxcorr;
        recdata(r).t_corr = t_corr;


        save('SWSWREM_AllRecs/recdata','recdata')
    end

    %% For Summary Figures
    if SAVEFIGS   

    numcells = length(Se);
    numstates = length(states);
    statenames = {'Wake','SWS','REM'};

    %Spike Matrix with 10s bins
    for c = 1:numcells
        spiketimes{c} = Range(Se{c},'s');
    end
    lastspike = max(vertcat(spiketimes{:}));
    dt = 10;
    T = [0 lastspike];
    [spikemat,t] = SpktToSpkmat(spiketimes, T, dt);
    zspikemat = zscore(spikemat);


    %Sort by Wake FR
    [FR_sorted,sort_rate] = sort(StateFR_out(:,1));

    FR_wake = StateFR_out(:,1);
    FR_SWS = StateFR_out(:,2);
    FR_REM = StateFR_out(:,3);


    %Make Score vector
    scorevec = ones(size(t));
    for s = [1,3,5]   %1:Wake, 3:SWS, 5:REM, 6:Unscored
        statestarts = Start(intervals{s},'s'); 
        stateends = End(intervals{s},'s');
            for e = 1:length(statestarts)
                stateind = find(t>statestarts(e) & t<stateends(e));
                scorevec(stateind) = s;
            end
    end

    goodsleeps = [Start(GoodSleepInterval,'s'),End(GoodSleepInterval,'s')];
    %If whole recording is goodsleep...
    if isinf(goodsleeps(2))
        goodsleeps(2) = t(end);
    end


    %Correlations
    iFR_wake = [];
    jFR_wake = [];

    allcorr_wake = StatePairCorr_out(:,:,1);
    allcorr_SWS = StatePairCorr_out(:,:,2);
    allcorr_REM = StatePairCorr_out(:,:,3);


    %Make Matrix of neuron i and j FR
    iFR_wake = repmat(FR_wake,1,numcells);
    jFR_wake = repmat(FR_wake',numcells,1);
    %Remove Diagonal Entries
    iFR_wake(allcorr_wake==1)=[];
    jFR_wake(allcorr_wake==1)=[];
    allcorr_wake(allcorr_wake==1)=[];
    allcorr_SWS(allcorr_SWS==1)=[];
    allcorr_REM(allcorr_REM==1)=[];

    %Top 10% FR
    perc90 = FR_sorted(round(0.9*end));
    perc10 = FR_sorted(round(0.1*end));


    %% Summary Figure: Firing Rate

    figure
        subplot(3,1,1)
            hold on
            imagesc(t,1:numcells,zspikemat(:,sort_rate)')
            xlabel('t (s)');ylabel('Neuron, sorted by mean firing rate');
            cb = colorbar;
            set(get(cb,'Title'),'String','r(t) (Z-score)')
            axis xy
            caxis([-3 3])
            image(t,max(numcells)+[3 4],(scorevec.*10)')
            plot(goodsleeps,max(numcells)+[6 6],'k')
            xlim([t(1) t(end)]);ylim([0 max(numcells)+7])
            %title(['Recording ',num2str(r),recordings(r).name,'Firing rate in 10s bin'])
        subplot(3,2,[3,5])
            plot(log10(FR_wake),log10(FR_SWS),'.b',...
            log10(FR_wake),log10(FR_REM),'.g',...
            [-2 1.5],[-2 1.5],'k')
            xlim([-2 1.5]);ylim([-2 1.5])
            xlabel('Firing Rate Wake (Hz)');ylabel('Firing Rate Sleep (Hz)');
            legend('SWS','REM','Location','northwest')
            set(gca,'XTick',[-2:1])
            set(gca,'XTickLabel',num2cell(10.^(-2:1)))
        subplot(3,2,[4,6])
            plot(log10(FR_wake),log10(FR_SWS./FR_wake),'.b',...
                log10(FR_wake),log10(FR_REM./FR_wake),'.g',...
                [-2 1.5],[0 0],'k')
            xlim([-2 1.5]);ylim([-2 1.5])
            xlabel('Firing Rate Wake (Hz)');ylabel('FR Sleep:Wake (Hz)');
            legend('SWS','REM','Location','northeast')
            set(gca,'XTick',[-2:1])
            set(gca,'XTickLabel',num2cell(10.^(-2:1)))


    saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_FR'],'jpeg')


    %% Figure: Bursting
    figure
        for s = 1:numstates
        subplot(2,3,s)
            imagesc(StateBurst_out.logISIhistbins,1:numcells,StateBurst_out.ISIhist(:,sort_rate,s)')
            set(gca,'XTick',[-3:0]);
            set(gca,'XTickLabel',10.^[0:3]);
             xlim([-3,1])
            colorbar
            caxis([0 0.1])
            title(statenames(s))
            ylabel('Cell, Ordered by Wake FR');xlabel('t (ms)');
        end
        subplot(2,3,4)
            hold on
            plot([0 0.4],[0 0.4],'k')
            plot(StateBurst_out.burstindex(1,:,1),StateBurst_out.burstindex(1,:,2),'b.',...
                StateBurst_out.burstindex(1,:,1),StateBurst_out.burstindex(1,:,3),'r.')
            xlabel('Burst Index Wake');ylabel('Burst Index SWS')
        subplot(2,3,5)
            hold on
            plot(log10(StateFR_out(:,1)),StateBurst_out.burstindex(1,:,1),'g.')
            plot(log10(StateFR_out(:,1)),StateBurst_out.burstindex(1,:,2),'b.')
            %plot(log10(StateFR_out(:,1)),StateBurst_out.burstindex(1,:,3),'r.')
            set(gca,'XTick',[-3:1]);
            set(gca,'XTickLabel',10.^[-3:1]);
            xlabel('FR wake (Hz)');ylabel('Bust Index')
        subplot(2,3,6)
            plot(log10(StateFR_out(:,1)),...
                StateBurst_out.burstindex(1,:,2)-StateBurst_out.burstindex(1,:,1),'b.')
            set(gca,'XTick',[-3:1]);
            set(gca,'XTickLabel',10.^[-3:1]);
            xlabel('FR wake (Hz)');ylabel('Burst Index SWS-Wake')

    saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_Burst'],'jpeg')



    %% Figure: Pairwise Correlations
    colorrange = [-0.2 0.2];
    corrmat_wake = StatePairCorr_out(:,:,1);
    corrmat_SWS = StatePairCorr_out(:,:,2);
    corrmat_REM = StatePairCorr_out(:,:,3);


    figure
         subplot(3,3,1)
            imagesc(corrmat_wake(sort_rate,sort_rate))
            caxis(colorrange)
            title('Wake')
            colorbar
            xlabel('Neuron, Sorted by mean firing rate');
            ylabel('Neuron, Sorted by mean firing rate');
         subplot(3,3,2)
            imagesc(corrmat_SWS(sort_rate,sort_rate))
            caxis(colorrange)
            title('SWS')
            colorbar
            xlabel('Neuron, Sorted by mean firing rate');
            ylabel('Neuron, Sorted by mean firing rate');
         subplot(3,3,3)
            imagesc(corrmat_REM(sort_rate,sort_rate))
            caxis(colorrange)
            colorbar
            title('REM')
            xlabel('Neuron, Sorted by mean firing rate');
            ylabel('Neuron, Sorted by mean firing rate');
    %      subplot(3,12,15)
    %         plot(log10(FR_whole(sort_rate)),1:numcells,'.k')
    %         ylim([0 numcells]);xlim(log10([min(FR_whole) max(FR_whole)]));
    %         set(gca,'YDir','Reverse')
    %         xlabel('Log Firing Rate');ylabel('Cell, Ordered by Firing Rate')
    % 
    %     subplot(3,3,5)
    %         imagesc(corrmat_SWS(sort_rate,sort_rate)-corrmat_wake(sort_rate,sort_rate))
    %         caxis(colorrange)
    %         colorbar
    %         title('SWS-wake')
    %         xlabel('Neuron, Sorted by mean firing rate');
    %         ylabel('Neuron, Sorted by mean firing rate');
    %         
    %     subplot(3,3,6)
    %         imagesc(corrmat_REM(sort_rate,sort_rate)-corrmat_wake(sort_rate,sort_rate))
    %         caxis(colorrange)
    %         colorbar
    %         title('REM-wake')
    %         xlabel('Neuron, Sorted by mean firing rate');
    %         ylabel('Neuron, Sorted by mean firing rate');
    %         
    %     subplot(3,3,9)
    %         imagesc(corrmat_REM(sort_rate,sort_rate)-corrmat_SWS(sort_rate,sort_rate))
    %         caxis(colorrange)
    %         colorbar
    %         title('REM-SWS')
    %         xlabel('Neuron, Sorted by mean firing rate');
    %         ylabel('Neuron, Sorted by mean firing rate');
    % 
    %     subplot(2,3,4)
    %         plot(sum(corrmat_wake),sum(corrmat_SWS),'b.',...
    %             sum(corrmat_wake),sum(corrmat_REM),'g.',...
    %             [-0.5 3],[-0.5 3],'k')
    %         xlabel('Node Strength Wake');ylabel('Node Strength Sleep');
    %         legend('SWS','REM','Location','southeast')

        subplot(3,3,4)
            plot(log10(jFR_wake(iFR_wake>perc90)),allcorr_wake(iFR_wake>perc90),'.')
            lsline
            xlim([-3.5 1.2]);ylim([-0.2 0.3]);
            xlabel('FR cell j, Wake');ylabel('Corr(i,j)')
            title({'Wake','Cell i in top 10% FR'})
                set(gca,'XTick',[-3:1])
                set(gca,'XTickLabel',num2cell(10.^(-3:1)))
        subplot(3,3,5)
            plot(log10(jFR_wake(iFR_wake>perc90)),allcorr_SWS(iFR_wake>perc90),'.')
            lsline
            xlim([-3.5 1.2]);ylim([-0.2 0.3]);
            xlabel('FR cell j, Wake');ylabel('Corr(i,j)')
            title({'SWS','Cell i in top 10% FR'})
                set(gca,'XTick',[-3:1])
                set(gca,'XTickLabel',num2cell(10.^(-3:1)))
        subplot(3,3,6)
            plot(log10(jFR_wake(iFR_wake>perc90)),allcorr_REM(iFR_wake>perc90),'.')
            lsline
            xlim([-3.5 1.2]);ylim([-0.2 0.3]);
            xlabel('FR cell j, Wake');ylabel('Corr.')
            title({'REM','Cell i in top 10% FR'})
                set(gca,'XTick',[-3:1])
                set(gca,'XTickLabel',num2cell(10.^(-3:1)))

        subplot(3,3,7)
            plot(log10(jFR_wake(iFR_wake<perc10)),allcorr_wake(iFR_wake<perc10),'.')
            lsline
            xlim([-3.5 1.2]);ylim([-0.2 0.3]);
            xlabel('FR cell j, Wake');ylabel('Corr(i,j)')
            title({'Wake','Cell i in bottom 10% FR'})
                set(gca,'XTick',[-3:1])
                set(gca,'XTickLabel',num2cell(10.^(-3:1)))
        subplot(3,3,8)
            plot(log10(jFR_wake(iFR_wake<perc10)),allcorr_SWS(iFR_wake<perc10),'.')
            lsline
            xlim([-3.5 1.2]);ylim([-0.2 0.3]);
            title({'SWS','Cell i in bottom 10% FR'})
            xlabel('FR cell j, Wake');ylabel('Corr(i,j)')
                set(gca,'XTick',[-3:1])
                set(gca,'XTickLabel',num2cell(10.^(-3:1)))
        subplot(3,3,9)
            plot(log10(jFR_wake(iFR_wake<perc10)),allcorr_REM(iFR_wake<perc10),'.')
            lsline
            xlim([-3.5 1.2]);ylim([-0.2 0.3]);
            title({'REM','Cell i in bottom 10% FR'})
            xlabel('FR cell j, Wake');ylabel('Corr(i,j)')
                set(gca,'XTick',[-3:1])
                set(gca,'XTickLabel',num2cell(10.^(-3:1)))

    saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_PairCorr'],'jpeg')


    %% stPR


    %% Figure: stPR


    figure
        for s = 1:3
            subplot(2,3,s)
                imagesc(t_corr,1:numcells,squeeze(stxcorr(sort_rate,s,:)))
                colorbar
                caxis([-0.1 0.5])
                title(statenames(s))
            subplot(2,3,s+3)
                plot(log10(StateFR_out(:,1)),stPR(:,s),'.')
                xlabel('Firing Rate (log Hz)');ylabel('stPR (Z Score)');

        end
    saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_stPR'],'jpeg')

    end

    close all   %Close all Figures


end
end

%% UP state first spike PETH
if (RunPETH | RunPETH_SP)

UPstarts = isse.intstarts;
UPends = isse.intends;    
UPlengths = UPends - UPstarts;
[UPlengths_sorted, lengthsort] = sort(UPlengths);
numUPs = length(UPstarts);


%First spikes
firstspike = num2cell(isse.firstspktsfromstart);
firstspike(cellfun(@isnan,firstspike))={[]};
T_first = [zeros(size(UPstarts)), UPends-UPstarts];
T = [UPstarts, UPends];

dt = 0.001;


%Mean Time of first spike
meanstart = zeros(1,numcells);
for c = 1:numcells
    startspikes = vertcat(firstspike{:,c});
    meanstart(c) =  mean(startspikes(startspikes<0.3));
end
[init_sorted,sort_init] = sort(meanstart);


gausswidth = 0.02;
[PETHspikes,PETHrates_first,t] = SpktToPETH(firstspike,T_first,gausswidth,lengthsort,sort_init,dt);
[PETHspikes,PETHrates,t] = SpktToPETH(isse.spkts,T,gausswidth,lengthsort,sort_init,dt);
PETHrates_first = PETHrates_first(1:(1.5/dt),:);  %Keep only first second of PETH
                                    %rate... last bit is noisy
PETHrates = PETHrates(1:(1.5/dt),:);  %Keep only first second of PETH
                                    %rate... last bit is noisy
t = t(1:(1.5/dt));



%Some stuff for plots... add this to SpktToPETH()
[dum,rateindex] = sort(sort_rate);
cellsort = num2cell(repmat(rateindex-1,numUPs,1).*numUPs);  %by firing rate

if RunPETH
recdata(r).PETHrates_first = PETHrates_first;
recdata(r).PETHrates = PETHrates;
recdata(r).meanstart = meanstart;
recdata(r).t_PETH = t;
end

if RunPETH_SP
recdata(r).SPPETHrates_first = PETHrates_first;
recdata(r).SPPETHrates = PETHrates;
recdata(r).SPmeanstart = meanstart;

end

%% Figure: UP state PETH - First spikes
figure
    subplot(1,8,1:2)
        %hold on
        %plot(UPlengths,lengthindex,'r.','MarkerSize',1)
        plot(PETHspikes(:,1),PETHspikes(:,2),'.',...
            [zeros(numcells-1,1) 4*ones(numcells-1,1)]',...
            cumsum(numUPs*ones(numcells-1,2),1)','k',...
            'MarkerSize',1)
        xlim([0 0.02]);ylim([0 numcells*numUPs]);
        xlabel('time from UP onset (s)');
        ylabel('Cell - arranged by med. firing rate');
        set(gca,'YTick',sort([cellsort{1,:}]))
        set(gca,'YTickLabel',num2cell(1:numcells)) 
        title('All UP states, First 20ms')
    subplot(1,4,2:4)
        hold on
%         plot(UPlengths,lengthindex,'r.','MarkerSize',1)
        plot(PETHspikes(:,1),PETHspikes(:,2),'.',...
            [zeros(numcells-1,1) 4*ones(numcells-1,1)]',...
            cumsum(numUPs*ones(numcells-1,2),1)','k',...
            'MarkerSize',1)
        xlim([0 1.5]);ylim([0 numcells*numUPs]);
        xlabel('time from UP onset (s)')
        set(gca,'YTick',sort([cellsort{1,:}]))
        set(gca,'YTickLabel',num2cell(1:numcells))  
        title('First 500ms')
 
        saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_PETHspikes'],'jpeg')     
        
        
figure
    imagesc(t,1:numcells,zscore(PETHrates(:,sort_init))')
    %plot(meanstart,sort_init,'ok')
    xlim([0,1.5]);
    xlabel('t (s)');ylabel('Neuron. Sorted by med firing rate');
    axis xy
    cb = colorbar;
    set(get(cb,'Title'),'String','Firing Rate (Z-score)')
    
    saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_PETHrate'],'jpeg')     
    
end






