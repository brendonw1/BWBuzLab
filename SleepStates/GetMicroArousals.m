function [MAs,WakeInterruptions,AnyWakish,REM] = GetMicroArousals(basepath,basename)
% finds microarousals and other elements based on WSRestrictedIntervals
% MAs are defined as <= 40sec and adjacent to only Packets, not adjacent to
% REM

% set max length
MAMaxDur = 40;

% load up
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
load(fullfile(basepath,[basename,'_WSRestrictedIntervals.mat']));

%get some intervals
IPIs = minus(SleepInts,SWSPacketInts);
REM = intersect(REMEpisodeInts,IPIs);
AnyWakish = minus(IPIs,REM);
MAs = dropLongIntervals(AnyWakish,MAMaxDur*10000);

%find MAs within 2sec of REM, get rid of them
mass = StartEnd(MAs,'s');
mass(:,1) = mass(:,1)-2;
mass(:,2) = mass(:,2)+2;
bad = InIntervalsBW(mass(:,1),StartEnd(REM,'s')) + InIntervalsBW(mass(:,2),StartEnd(REM,'s'));
maidxs = 1:length(length(MAs));
MAs = subset(MAs,maidxs(~bad));

% classify all other wake
WakeInterruptions = minus(AnyWakish,MAs);


