function StateRates = StateRates(basepath,basename)
% Gets and stores simple spike rates for each cell in a number of states.
% Note this is based on  GatherStateIntervalsets.m, which restricts to
% GoodSleepIntervals.
% Brendon Watson July 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;

t = load(fullfile(basepath,[basename '_SSubtypes.mat']));
Se = t.Se;
Si = t.Si;

t = load(fullfile(basepath,[basename '_StateIntervals.mat']));%from GatherStateIntervalSets.m
% t = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
StateIntervals = t.StateIntervals;

AllAllRates = Rate(S);
AllWakeSleepRates = Rate(S,StateIntervals.WakeSleepCycles);
AllWSWakeRates = Rate(S,StateIntervals.WSWake);
AllWakeARates = Rate(S,StateIntervals.wakea);
AllWSSleepRates = Rate(S,StateIntervals.WSSleep);
AllREMRates = Rate(S,StateIntervals.REM);
AllSWSRates = Rate(S,StateIntervals.SWS);
% AllMWakeRates = Rate(S,StateIntervals.MWake);
% AllNMWakeRates = Rate(S,StateIntervals.NMWake);

EAllRates = Rate(Se);
% EAllWakeRates = Rate(Se,interasect(
EWakeSleepRates = Rate(Se,StateIntervals.WakeSleepCycles);
EWSWakeRates = Rate(Se,StateIntervals.WSWake);
EWakeARates = Rate(Se,StateIntervals.wakea);
EWSSleepRates = Rate(Se,StateIntervals.WSSleep);
EREMRates = Rate(Se,StateIntervals.REM);
ESWSRates = Rate(Se,StateIntervals.SWS);
% EMWakeRates = Rate(Se,StateIntervals.MWake);
% ENMWakeRates = Rate(Se,StateIntervals.NMWake);

if prod(size(Si))>0
    IAllRates = Rate(Si);
    if isempty(IAllRates)
        IAllRates = 0;
    end
    IWakeSleepRates = Rate(Si,StateIntervals.WakeSleepCycles);
    IWSWakeRates = Rate(Si,StateIntervals.WSWake);
    IWakeARates = Rate(Si,StateIntervals.wakea);
    IWSSleepRates = Rate(Si,StateIntervals.WSSleep);
    IREMRates = Rate(Si,StateIntervals.REM);
    ISWSRates = Rate(Si,StateIntervals.SWS);
%     IMWakeRates = Rate(Si,StateIntervals.MWake);
%     INMWakeRates = Rate(Si,StateIntervals.NMWake);
else
    IAllRates = [];
    IWakeSleepRates = [];
    IWSWakeRates = [];
    IWakeARates = [];
    IWSSleepRates = [];
    IREMRates = [];
    ISWSRates = [];
%     IMWakeRates = [];
%     INMWakeRates = [];
end    

%% Spindles & UPs
AllUPRates = Rate(S,StateIntervals.UPstates);
EUPRates = Rate(Se,StateIntervals.UPstates);
IUPRates = Rate(Si,StateIntervals.UPstates);

AllSpindleRates = Rate(S,StateIntervals.Spindles);
ESpindleRates = Rate(Se,StateIntervals.Spindles);
ISpindleRates = Rate(Si,StateIntervals.Spindles);

% AllNDSpRates = Rate(S,StateIntervals.NDSpindles);
% ENDSpRates = Rate(Se,StateIntervals.NDSpindles);
% INDSpRates = Rate(Si,StateIntervals.NDSpindles);

%% First/last SWS of sleep episodes
AllFSWSRates = Rate(S,StateIntervals.FSWS);
EFSWSRates = Rate(Se,StateIntervals.FSWS);
IFSWSRates = Rate(Si,StateIntervals.FSWS);

AllLSWSRates = Rate(S,StateIntervals.LSWS);
ELSWSRates = Rate(Se,StateIntervals.LSWS);
ILSWSRates = Rate(Si,StateIntervals.LSWS);


% StateRates = v2struct(EWakeRates,IWakeRates,EREMRates,IREMRates,...
%     ESWSRates,ISWSRates,...
%     EMWakeRates,IMWakeRates,ENMWakeRates,INMWakeRates,...
%     EUPRates,IUPRates,ESpindleRates,ISpindleRates);
StateRates = v2struct(AllAllRates,EAllRates,IAllRates,...
    AllWakeSleepRates,EWakeSleepRates,IWakeSleepRates,...
    AllWSWakeRates,EWSWakeRates,IWSWakeRates,...
    AllWakeARates,EWakeARates,IWakeARates,...
    AllWSSleepRates,EWSSleepRates,IWSSleepRates,...
    AllREMRates,EREMRates,IREMRates,...
    AllSWSRates,ESWSRates,ISWSRates,...
    AllUPRates,EUPRates,IUPRates,...
    AllSpindleRates,ESpindleRates,ISpindleRates,...
    AllFSWSRates,EFSWSRates,IFSWSRates,...
    AllLSWSRates,ELSWSRates,ILSWSRates);
%     AllMWakeRates,EMWakeRates,IMWakeRates,...
%     AllNMWakeRates,ENMWakeRates,INMWakeRates,...
save(fullfile(basepath,[basename,'_StateRates.mat']),'StateRates')
