function [Semeanfr,Semeanfr_norm,Semeanfr_mean,SeRates_W,SeRates_S,t_norm,...
    aligned_onset_norm,aligned_onset,aligned_onset_mean,...
    aligned_offset_norm,aligned_offset,aligned_offset_mean,...
    t_align_onoff,...
    FR_percentiles] = SleepUnitAnalysis(recname,figfolder)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%Started: 9/25/15
%Last Updated: 9/25/15
%DLevenstein
%% DEV
% recname = '20140526_277um';
% figfolder = 'PacketUnitAnalysis/';


%%
load(['Database/BWData/',recname,'/',recname,'_SSubtypes.mat'])
load(['Database/BWData/',recname,'/',recname,'_StateIDM.mat'])
load(['Database/BWData/',recname,'/',recname,'_WSRestrictedIntervals.mat'])
load(['Database/BWData/',recname,'/',recname,'_StateRates.mat'])


SLEEPints = [Start(SleepInts,'s'), End(SleepInts,'s')];
packetints = [Start(SWSPacketInts,'s'), End(SWSPacketInts,'s')];
packetints = RestrictInts(packetints,SLEEPints);
SWSints = [Start(SWSEpisodeInts,'s'), End(SWSEpisodeInts,'s')];
SWSints = RestrictInts(SWSints,SLEEPints);
WAKEints = [Start(WakeInts,'s'), End(WakeInts,'s')];


SLEEPlen = SLEEPints(:,2)-SLEEPints(:,1);



arousalints = [Start(stateintervals{1},'s'), End(stateintervals{1},'s')];
arousallengths = arousalints(:,2)-arousalints(:,1);
arousalints = RestrictInts(arousalints(arousallengths>=40,:),SLEEPints);
REMints = [Start(episodeintervals{3},'s'), End(episodeintervals{3},'s')];

numcells = length(Se);
[~,sortrate] = sort(StateRates.EWakeRates);
SeRates_W = StateRates.EWakeRates;
SeRates_S = StateRates.ESWSRates;

%% Spike Rate Matric
dt = 0.5; %s
overlap = 10;
[spikemat,t] = SpktToSpkmat(Se, [], dt,overlap);
spikemat = spikemat./(dt*overlap);
%%
zspikemat = ZScoreToInt(spikemat,WAKEints,1/dt);
meanspikemat = mean(spikemat,2);
spikemat = [spikemat zspikemat meanspikemat];

%% Get non-NREM times to mask out 
sf = 1/dt;
nonSWSidx = INTtoIDX({arousalints*sf,REMints*sf},length(t));
nonSWSidx = double(nonSWSidx>0);
%%
pad = 0.15;
[unitepochs,droppedints] = IsolateEpochs2(spikemat,SLEEPints,round(pad*SLEEPlen),1/dt);
SLEEPints(droppedints,:) = [];
SLEEPlen(droppedints) = [];
numpack = length(SLEEPlen);

[maskepochs] = IsolateEpochs2(nonSWSidx,SLEEPints,round(pad*SLEEPlen),1/dt);

%% Onset/Offset align
spikemat(nonSWSidx>0,:) = NaN;

twin = [40 40];
onsetints = [SLEEPints(:,1)-twin(1) SLEEPints(:,1)+twin(2)];
[aligned_onset,droppedints] = IsolateEpochs2(spikemat,onsetints,0,1/dt);
aligned_onset = mean(cat(3,aligned_onset{:}),3);

offsetints = [SLEEPints(:,2)-twin(1) SLEEPints(:,2)+twin(2)];
[aligned_offset,droppedints] = IsolateEpochs2(spikemat,offsetints,0,1/dt);
aligned_offset = mean(cat(3,aligned_offset{:}),3);

t_align_onoff = [-twin(1):dt:twin(2)];

aligned_onset_mean = aligned_onset(:,end);
aligned_onset_norm = aligned_onset(:,numcells+1:end-1);
aligned_onset = aligned_onset(:,1:numcells);

aligned_offset_mean = aligned_offset(:,end);
aligned_offset_norm = aligned_offset(:,numcells+1:end-1);
aligned_offset = aligned_offset(:,1:numcells);


%%
numbins = 50;
[normunitpack] = TimeNormalize(unitepochs,numbins+2*pad*numbins);
t_norm = [1:(numbins+2*pad*numbins)]/numbins-pad;

[normmask] = TimeNormalize(maskepochs,numbins+2*pad*numbins);

for ee = 1:numpack
    normunitpack{ee}(normmask{ee}>0.5,:) = NaN;
end

Semeanfr = squeeze(nanmean(cat(3,normunitpack{:}),3));
%stdfr = squeeze(std(cat(3,normunitpack{:}),[],3));

Semeanfr_mean = Semeanfr(:,end);
Semeanfr_norm = Semeanfr(:,numcells+1:end-1);
Semeanfr = Semeanfr(:,1:numcells);

numdistbins = 6;
FR_percentiles = SortedPercentiles(Semeanfr,sortrate,numdistbins);
%%
frplot = figure;
    subplot(3,1,1)
        imagesc(t_norm,1:numcells,Semeanfr_norm')
        axis xy
        xlim([-0.1 1.1])
         ylabel({'Cell', 'Ordered by Mean FR'});
         title([recname,': SLEEP - Averaged Firing Rate'])
        caxis([-1.5 1.5])
        %colorbar
	subplot(3,1,2)
    set(gca, 'ColorOrder', RainbowColors(numcells));
        hold all
        plot(t_norm,log10(Semeanfr(:,sortrate)))
        xlim([-0.1 1.1])
        set(gca,'YTick',[-2:0.5:1])
        set(gca,'YTickLabel',10.^[-2:0.5:1])
        ylabel('Firing Rate (Hz)');xlabel('SLEEP Normalized Time')
	subplot(3,1,3)
    set(gca, 'ColorOrder', RainbowColors(numcells));
        hold all
        plot(t_norm,(Semeanfr_norm(:,sortrate)))
        xlim([-0.1 1.1])
        %set(gca,'YTick',[-2:0.5:1])
        %set(gca,'YTickLabel',10.^[-2:0.5:1])
        ylabel({'Firing Rate', '(Z Score to SWS Rate)'});
        xlabel('SLEEP Normalized Time')
    
    saveas(frplot,[figfolder,recname,'_SleepFR'],'jpeg')
end