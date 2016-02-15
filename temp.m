function [SeRateUnsorted] = temp(sextilemode)
% sname can be 'SWS','REM','WAKE' or 'MA"
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
        case('WSWake')
            load(fullfile(basepath,[basename '_StateRates.mat']));
            [~,sortrate] = sort(StateRates.EWSWakeRates);
            SeRates = StateRates.EWSWakeRates;
        case('WakeA')
            load(fullfile(basepath,[basename '_StateRates.mat']));
            [~,sortrate] = sort(StateRates.EWakeARates);
            SeRates = StateRates.EWSWakeRates;
    end
    SeRatesAll{a} = SeRates;
end


SeRate = vertcat(SeRatesAll{:});
SeRateUnsorted = SeRate;
% [~,sortrate] = sort(SeRate);



