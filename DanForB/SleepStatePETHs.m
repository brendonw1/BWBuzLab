%SleepStatePETHs.m
%Description: Aligned to Transitions - Extract for all recordings
%Date Started: 6/09/15
%
%TO DO:
%
%
%DLevenstein

%
datafolder = '/mnt/data1/BWData/';

%Make List of all Recordings in data folder
recordings = dir(datafolder);
recordings(1:2) = [];   %Remove first two entries, which are .. and .

numrecs = length(recordings);

for r =1:numrecs
    display(['Recording ',num2str(r),' of ',num2str(numrecs)])
    
    %Load Intervals and Spikes
    intervaldata = [datafolder,recordings(r).name,'/',...
        recordings(r).name,'_Intervals.mat'];
    spikesdata = [datafolder,recordings(r).name,'/',...
        recordings(r).name,'_SSubtypes.mat'];    
    load(intervaldata)
    load(spikesdata)
    
   
%% Get PETH's
%figparms.sort = sort_rate;
[ transPETH(r).WS ] = WakeSleepPETH(Se, intervals);
[ transPETH(r).RSR ] = REMSWSREMPETH(Se, intervals );
end

%% After Running... Combine and figure
load('SWSWREM_AllRecs/recdata.mat')
%load('SleepStatePETHs/transPETH.mat')


numrecs = length(recdata);
weirdrecs = [1,2,7,11,13,15,16,17,18,27];
%weirdrecs = [];
goodrecs = setdiff(1:numrecs,weirdrecs);

%Sort
FR_wake = [recdata(goodrecs).FR_wake];
[FR_sorted,sort_rate] = sort(FR_wake);

numcells = length(FR_wake);

allRSR = [transPETH(goodrecs).RSR];
allWS = [transPETH(goodrecs).WS];

perc = 0.1;
numperc = ceil(numcells*perc);

zRSR = zscore(allRSR);
zWS = zscore(allWS);

lowcellsPETH = mean(allRSR(:,sort_rate(1:numperc)),2);
highcellsPETH = mean(allRSR(:,sort_rate((end-numperc):end)),2);
%%
t = 1:length(highcellsPETH);
figure
    subplot(4,1,[1:3])
    imagesc(zRSR(:,sort_rate)')
    colorbar
    axis xy
    caxis([-2 2])
    subplot(4,1,4)
        plotyy(t,highcellsPETH,t,lowcellsPETH)

%%
