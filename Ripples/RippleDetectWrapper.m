function RippleDetectWrapper(basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
bmd = load(fullfile(basepath,[basename,'_BasicMetaData.mat']));

num_ch = bmd.Par.nChannels;
rip_ch = bmd.Ripplechannel;
if isfield(bmd,'RippleNoiseChannel');
    noise_ch = bmd.RippleNoiseChannel;
else
    noise_ch = [];%this is the default in FindRipples.m
end

%% Get LFP ready
eeglfppath = findsessioneeglfpfile(basepath,basename);
if isempty(noise_ch)
    lfp = LoadLfp(eeglfppath,num_ch,rip_ch);    
    lfp = [Range(lfp, 's') double(Data(lfp))];
    noiselfp = [];
else
    lfp = LoadLfp(eeglfppath,num_ch,[rip_ch noise_ch]);    
    lfp = [Range(lfp, 's') double(Data(lfp))];
    noiselfp = [lfp(:,1) lfp(:,3)];
    lfp = [lfp(:,1) lfp(:,2)];
end

%% Filter LFP
filtered = FilterLFP(lfp,'passband','ripples');

%% Find baseline period
load(fullfile(basepath,[basename,'_WSRestrictedIntervals.mat']),'SWSPacketInts');
%for now just use first packet
baselinetime = StartEnd(subset(SWSPacketInts,[1]),'s');

%% Detect ripples
if isempty(noise_ch)
    [ripples,sd,bad] = FindRipples(filtered,'baseline',baselinetime,'frequency',bmd.Par.lfpSampleRate);
else    
    [ripples,sd,bad] = FindRipples(filtered,'baseline',baselinetime,'frequency',bmd.Par.lfpSampleRate,'noise',noiselfp);
end

%% Get rid of ripples during super high emg
load(fullfile(basepath,[basename,'_EMGCorr.mat']),'EMGCorr');
EMGCorrCutoff = 0.75;
hiemg = find(decimate(EMGCorr(:,2),2) > EMGCorrCutoff); %seconds when all shanks are very coordinated... ie movement... good ripples VERY unlikely during these times
ripstarts = round(ripples(:,1));
bads = ismember(ripstarts,hiemg);
ripples(bads,:) = [];
ripends = round(ripples(:,1));
bads = ismember(ripends,hiemg);
ripples(bads,:) = [];

%% Write output re all spindles (normal and High Voltage)
% ripple_file = strcat(basename, num2str(rip_ch), 'ripples');
% save (ripple_file, 'ripples')
ripple_evt_filename = fullfile(basepath,[basename, '_Ch', num2str(rip_ch), '.rip.evt']);
SaveRippleEvents(ripple_evt_filename,ripples,rip_ch);

%% Get Zugaro stats
[maps,data,stats] = RippleStats(filtered,ripples,'frequency',bmd.Par.lfpSampleRate);
% PlotRippleStats(ripples,maps,data,stats)
data.peakAmplitude = data.peakAmplitude * bmd.voltsperunit;
maps.amplitude = maps.amplitude * bmd.voltsperunit;

%% Export final data
RippleData = v2struct(ripples,rip_ch,maps,data,stats);
MakeDirSaveVarThere(fullfile(basepath,'Ripples'),RippleData);

1;