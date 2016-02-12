outvars = v2struct(basename,basepath,Par,goodshanks,goodeegchannel,...
    RecordingFilesForSleep, RecordingFileIntervals,voltsperunit);

if exist('UPstatechannel','var')
    outvars.UPstatechannel = UPstatechannel;
end
if exist('Spindlechannel','var')
    outvars.Spindlechannel = Spindlechannel;
end
if exist('Thetachannel','var')
    outvars.Thetachannel = Thetachannel;
end
if exist('Ripplechannel','var')
    outvars.Ripplechannel = Ripplechannel;
end
if exist('RippleNoiseChannel','var')
    outvars.RippleNoiseChannel = RippleNoiseChannel;
end
if exist('KetamineStartFile','var')
    outvars.KetamineStartFile = KetamineStartFile;
end
if exist('KetamineTimeStamp','var')
    outvars.KetamineTimeStamp = KetamineTimeStamp;
end
if exist('mastername','var')
    outvars.mastername = mastername;
end
if exist('masterpath','var')
    outvars.masterpath = masterpath;
end
if exist('manualGoodSleeep','var')
    outvars.manualGoodSleep = manualGoodSleeep;
end
if exist('sleepstart','var')
    outvars.sleepstart = sleepstart;
end
if exist('sleepstop','var')
    outvars.sleepstop = sleepstop;
end


save(fullfile(basepath,[basename '_BasicMetaData.mat']),'-struct','outvars')
disp(['Saved ' fullfile(basepath,[basename '_BasicMetaData.mat'])])
% save([basename '_BasicMetaData.mat']);
% load([basename '_BasicMetaData.mat']);