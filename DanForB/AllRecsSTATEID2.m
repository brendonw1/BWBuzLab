%%AllRecsStateID.m

datafolder = 'Database/BWData/';
%Make List of all Recordings in data folder
recordings = dir(datafolder);
recordings(strncmpi('.',{recordings.name},1)) = [];   %Remove entries starting with .,~
recordings(strncmpi('~',{recordings.name},1)) = []; 

numrecs = length(recordings);
%%
for r = 1:numrecs;
        close all
display(['Recording ',num2str(r),' of ',num2str(numrecs)])


LFPdata = [datafolder,recordings(r).name,'/',...
    recordings(r).name,'_LFP.mat'];
load(LFPdata)
sf_LFP = 1250;
t_LFP = [1:length(LFP)]/sf_LFP;

EMGdata = [datafolder,recordings(r).name,'/',...
    recordings(r).name,'_EMGCorr.mat'];
load(EMGdata)
sf_EMG = 2;
EMG = EMGCorr(:,2);
t_EMG = EMGCorr(:,1);

StateIntdata = [datafolder,recordings(r).name,'/',...
    recordings(r).name,'_StateID.mat'];
load(StateIntdata)
%%
   
SWSints = stateintervals{2};
REMints = stateintervals{3};
WAKEints = stateintervals{1};

minPACKdur = 20;
SWSlengths = SWSints(:,2)-SWSints(:,1);
PACKints = SWSints(SWSlengths>=minPACKdur,:);

minintdur = 40;
minSWSdur = 20;
[episodeints{2}] = IDStateEpisode(SWSints,minintdur,minSWSdur);

minintdur = 40;
minWAKEdur = 20;
[episodeints{1}] = IDStateEpisode(WAKEints,minintdur,minWAKEdur);

minintdur = 40;
minREMdur = 20;
[episodeints{3}] = IDStateEpisode(REMints,minintdur,minREMdur);

episodeidx = INTtoIDX(episodeints,ceil(t_LFP(end)));
episodeints=IDXtoINT(episodeidx);
episodeints = episodeints(2:4);
% wakeints=IDXtoINT(stateidx~=1);
% 
% 
% minintdur = 120;
% minSLEEPdur = 20;
% [sleepints] = IDStateEpisode(wakeints{2},minintdur,minSLEEPdur);


    %% Spectrogram for Plot
%     LFP_ws = LFP(t_LFP >= WSint(1) & t_LFP <= WSint(2));    
%     t_LFP_ws = t_LFP(t_LFP >= WSint(1) & t_LFP <= WSint(2));  
    LFP_ws = LFP;    
    t_LFP_ws = t_LFP;  
    
    %Downsample
    downsamplefactor = 5;
    LFP_ws = downsample(LFP_ws,downsamplefactor);
    t_LFP_ws = downsample(t_LFP_ws,downsamplefactor);
    sf_LFP_ws = sf_LFP/downsamplefactor;
    
    filtbounds = [0.5 120];
    display(['Filtering ',num2str(filtbounds(1)),'-',num2str(filtbounds(2)),' Hz...']);
    LFP_ws = FiltNPhase(LFP_ws,filtbounds,sf_LFP_ws);
    
    display('FFT Spectrum for Broadband LFP')
    freqlist = logspace(0,2,100);
    window = 10;
    noverlap = 9;
    window = window*sf_LFP_ws;
    noverlap = noverlap*sf_LFP_ws;
    [FFTspec,FFTfreqs,t_FFT] = spectrogram(LFP_ws,window,noverlap,freqlist,sf_LFP_ws);
    t_FFT =t_FFT;
    FFTspec = log10(abs(FFTspec));
    [zFFTspec,mu,sig] = zscore((FFTspec)');
    %% Figure
    viewwin = [0 t_LFP(end)];
    figure
        subplot(8,1,[3:4])
            hold on
            imagesc(t_FFT,log2(FFTfreqs),(FFTspec))
            %plot(SLEEPint',log2(90)*ones(size(SLEEPint))','k','LineWidth',3)
            %plot(SWSints',log2(64)*ones(size(SWSints))','k','LineWidth',2)
            %plot(PACKints',log2(50)*ones(size(PACKints))','k','LineWidth',1)
            axis xy
            set(gca,'YTick',(log2([1 2 4 8 16 32 64 128])))
            set(gca,'YTickLabel',{'1','2','4','8','16','32','64','128'})
            %set(gca,'XTickLabel',{})
            caxis([min(mu)-2.5*max(sig) max(mu)+2.5*max(sig)])
            %colorbar('east')
            xlim(viewwin)
            ylim([log2(FFTfreqs(1)) log2(FFTfreqs(end))])
            ylabel({'LFP - FFT','f (Hz)'});xlabel('t(s)')
            
        subplot(8,1,6)
            plot(t_LFP_ws,zscore(LFP_ws),'k')
            xlim(viewwin);
            ylabel('LFP (z)')    
            set(gca,'XTickLabel',{})
        subplot(8,1,7)
            plot(t_EMG,EMG,'k')
            xlim(viewwin);ylim([0 1])
            ylabel('EMG')
             set(gca,'XTickLabel',{})
        subplot(8,1,1)
            %plot(t_FFT,-IDX,'LineWidth',2)
            hold on
            plot(stateintervals{1}',-1*ones(size(stateintervals{1}))','k','LineWidth',8)
            plot(stateintervals{2}',-2*ones(size(stateintervals{2}))','b','LineWidth',8)
            plot(stateintervals{3}',-3*ones(size(stateintervals{3}))','r','LineWidth',8)
            %title([recordings(r).name,':  Wake-Sleep Episode ',num2str(ws)]);
            xlim(viewwin)
            ylim([-4 0])
            ylabel('State Scoring')
            set(gca,'YTick',[-3:-1])
            set(gca,'YTickLabel',{'REM','SWS','Wake/MA'})
            set(gca,'XTickLabel',{})
            
        subplot(8,1,2)
            %plot(t_FFT,-IDX,'LineWidth',2)
            hold on
            plot(episodeints{1}',-1*ones(size(episodeints{1}))','k','LineWidth',8)
            plot(episodeints{2}',-2*ones(size(episodeints{2}))','b','LineWidth',8)
            plot(episodeints{3}',-3.5*ones(size(episodeints{3}))','r','LineWidth',8)
            plot(PACKints',-2.5*ones(size(PACKints))','b','LineWidth',5)
            %title([recordings(r).name,':  Wake-Sleep Episode ',num2str(ws)]);
            xlim(viewwin)
            ylim([-4 0])
            ylabel('Episodes')
            set(gca,'YTick',[-3:0])
            set(gca,'YTickLabel',{'REM','SWS','Wake','SLEEP'})
            set(gca,'XTickLabel',{})
            
            saveas(gcf,['AllRecsStateID/',recordings(r).name,'_epi'],'jpeg')

            
            %%
            stateidx = states;
save([datafolder,recordings(r).name,'/',...
    recordings(r).name,'_StateID2.mat'],...
    'stateintervals','stateidx','episodeints','episodeidx','PACKints')
end



