%% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

basename = 'Dino_061614';
basepath = '/mnt/brendon6/Dino/Dino_061614';
cd(basepath)
Par = LoadPar([basename '.xml']);
% presleepstartstop = [0 13128];%rough manual entry, in seconds
% postsleepstartstop = [15606 Inf];%rough manual entry, in seconds

% To Do
%>> Do StateEditor(basename)
%>> Make a _SpikeGroupAnatomy.csv using gdrive
goodshanks = [1,4,5,7];
goodeegchannel = 46; %For UP State detection
RecordingFilesForAnalysis = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];%Booleans for each component dat of merged recording

% Run
RecordingFileIntervals = FileStartStopsToIntervals(basename);
FileStartStopsToStateEditorEvent(basename);

save([basename '_BasicMetaData.mat']);
% load([basename '_BasicMetaData.mat']);

% For ketamine analysis
KetamineStartFile = 2;
RecordingStartsAndEnds = [Start(RecordingFileIntervals) End(RecordingFileIntervals)];
KetamineTimeStamp = RecordingStartsAndEnds(KetamineStartFile,1)/10000;