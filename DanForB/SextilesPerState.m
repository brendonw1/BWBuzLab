function SextilesPerState(statename,sextilemode)
% sname can be 'SWS','REM','WAKE' or 'MA"

if ~exist('statename','var')
    statename = 'nrem';
end
if ~exist('sextilemode','var')
    sextilemode = 'WSWake';
end

[names,dirs] = GetDefaultDataset;
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    load(fullfile(basepath,[basename '_SSubtypes.mat']));
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
    switch lower(sextilemode)
        case('old')
            load(fullfile(basepath,[basename '_StateRates_ForOldSextiles.mat']));
            [~,sortrate] = sort(StateRates.EWakeRates);
            SeRates = StateRates.EWakeRates;
        case('wswake')
            load(fullfile(basepath,[basename '_StateRates.mat']));
            [~,sortrate] = sort(StateRates.EWSWakeRates);
            SeRates = StateRates.EWSWakeRates;
        case('wakea')
            load(fullfile(basepath,[basename '_StateRates.mat']));
            [~,sortrate] = sort(StateRates.EWakeARates);
            SeRates = StateRates.EWSWakeRates;
    end
    
    switch lower(statename)
        case 'sleep'            
            EpochInts = SleepInts;
            dt = 0.5; %s per mini-bin
            overlap = 10;%number of minibins til no overlap
        case {'sws','nrem','swspacket','nrempacket'}
            EpochInts = SWSPacketInts;
            EpochInts = intersect(EpochInts,SleepInts);
            dt = 0.5; %s
            overlap = 10;
        case {'swsep','nremep','swsepisode','nremepisode'}
            EpochInts = SWSEpisodeInts;
            EpochInts = intersect(EpochInts,SleepInts);
            dt = 0.5; %s
            overlap = 10;
        case 'rem'
            EpochInts = REMInts;
            EpochInts = intersect(EpochInts,SleepInts);
            dt = 0.5; %s
            overlap = 10;
        case 'ma'
            EpochInts = MAInts;
            EpochInts = intersect(EpochInts,SleepInts);
            dt = 0.1; %s
            overlap = 1;
        case 'wake'            
            EpochInts = WakeInts;
            dt = 0.5; %s
            overlap = 10;
    end
    EpochLen = Data(length(EpochInts,'s'));


    %%
    [spikemat,t] = SpktToSpkmat(Se, [], dt,overlap);
    spikemat = spikemat./(dt*overlap);

    [unitepochs,droppedints] = IsolateEpochs2(spikemat,StartEnd(EpochInts,'s'),EpochLen,1/dt,'includeNaN');

    if ~isempty(unitepochs) 

        %%
        numbins = 50;
        [normunit] = TimeNormalize(unitepochs,numbins*3);
        t_norm = [1:numbins*3]/numbins-1;

        %% handle masks ie if need to take out all non-SWS parts of sleep
        if strcmp(statename,'sleep')%doing this later because need t first
            sf = 1/dt;
            badperiods = StartEnd(minus(EpochInts,SWSPacketInts),'s');%anything ouside packets is bad
            badperiods = INTtoIDX({badperiods*sf},length(t));%convert to vector
            badperiods = double(badperiods>0);%find bad bins
            [maskepochs] = IsolateEpochs2(badperiods,StartEnd(EpochInts,'s'),EpochLen,1/dt,'includeNaN');%grab relevant epcochs of bins
            [normmask] = TimeNormalize(maskepochs,numbins*3);%time normalize
            numsleeps = size(normunit,1);
            for ee = 1:numsleeps
                normunit{ee}(normmask{ee}>0.5,:) = NaN;
            end
        end        
        
        Semeanfr = squeeze(mean(cat(3,normunit{:}),3));

        SeFRAll{a} = Semeanfr;
        SeRatesAll{a} = SeRates;
    else
        1;
    end
    
    disp(basename);
end


SeEpochFR = [SeFRAll{:}];
SeRate = vertcat(SeRatesAll{:});
[~,sortrate] = sort(SeRate);

numdistbins = 6;
[FR_percentile_means,FR_percentile_sds,FR_percentile_raw] = SortedPercentiles(SeEpochFR,sortrate,numdistbins);

%% Calculate correlations for each sextile vs normalized time:
corrmode = 'popmean';
switch corrmode
    case 'popmean'
        centert = t_norm(numbins+1:numbins+numbins);
        centervals = FR_percentile_means(numbins+1:numbins+numbins,:);
        [r,p] = corr(centert',centervals);
    case 'percellpctchange'
        for a = 1:numdistbins
            percellbaseline = nanmean(FR_percentile_raw{a}(numbins:numbins+1,:),1);
            FRPctChgPerCell = FR_percentile_raw{a}./repmat(percellbaseline,numbins*3,1);
            linearchanges = FRPctChgPerCell(:);
            linearchanges(linearchanges==Inf) = max(linearchanges<Inf);
            linearchanges(linearchanges==-Inf) = min(linearchanges>-Inf);
            linearchanges(isnan(linearchanges)) = 1;%from 0/0
            lineartimes = repmat(t_norm,size(FR_percentile_raw{a},2),1)';
            lineartimes = lineartimes(:);
            [r(a),p(a)] = corr(lineartimes,linearchanges);
        end
end
corrtable = {'Sextile','R:','P:';...
    '-','-','-';...
    '6',r(6),p(6);...
    '5',r(5),p(5);...
    '4',r(4),p(4);...
    '3',r(3),p(3);...
    '2',r(2),p(2);...
    '1',r(1),p(1)};

%% Save out
eval([statename 'SextileData = v2struct(SeEpochFR,SeRate,FR_percentile_means);'])
savedir = fullfile(getdropbox,'BW OUTPUT','SleepProject','SpikeChanges','SextileAnalyses');
eval(['MakeDirSaveVarThere(savedir,' statename 'SextileData);'])

%% Plot and save figures;
overhang = 0.5;

h = figure('name',[statename 'BasedOn' sextilemode 'Sextiles']);
subplot(2,1,1)
set(gca, 'ColorOrder', OrangeColorsConfined(numdistbins));
hold all
plot(t_norm,log10(FR_percentile_means),'LineWidth',3)
ylim(log10([min(min(FR_percentile_means)) max(max(FR_percentile_means))]))
% ylim([-1 0.5])
plot([0 0],get(gca,'ylim'),'k') 
plot([1 1],get(gca,'ylim'),'k') 
xlim([-overhang 1+overhang])
xlabel([statename ' Episode Normalized Time']);
ylabel('Mean FR (Hz)')
set(gca,'YTick',[-3:0.5:1])
set(gca,'YTickLabel',10.^[-3:0.5:1])
title({[statename ' Sextile Analysis, based on sextiles from ' sextilemode '.'];...
    ['Bins = ' num2str(dt) 's. Overlap = ' num2str(overlap) ' fold.']})

%subplot 2: table
subplot(2,1,2);
for a = 1:3;text(a,1,corrtable(:,a));end;
xlim([.5 3.5])
ylim([.5 1.5])
axis off

MakeDirSaveFigsThereAs(savedir,h,'fig')
MakeDirSaveFigsThereAs(savedir,h,'png')

%% Plotting figures in a way that lets look at transitions
h = figure('name',[statename 'BasedOn' sextilemode 'SextilesTranstion']);
subplot(2,1,1)
set(gca, 'ColorOrder', OrangeColorsConfined(numdistbins));
hold all
plot(t_norm,log10(FR_percentile_means),'LineWidth',3)
ylim(log10([min(min(FR_percentile_means)) max(max(FR_percentile_means))]))
% ylim([-1 0.5])
plot([0 0],get(gca,'ylim'),'k') 
plot([1 1],get(gca,'ylim'),'k') 
xlabel([statename ' Episode Normalized Time']);
ylabel('Mean FR (Hz)')
set(gca,'YTick',[-3:0.5:1])
set(gca,'YTickLabel',10.^[-3:0.5:1])
title({[statename ' Sextile Analysis, based on sextiles from ' sextilemode '.'];...
    ['Bins = ' num2str(dt) 's. Overlap = ' num2str(overlap) ' fold.']})

MakeDirSaveFigsThereAs(savedir,h,'fig')
MakeDirSaveFigsThereAs(savedir,h,'png')


