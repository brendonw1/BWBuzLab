%% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

basename = 'Dino_061614';
basepath = '/mnt/brendon6/Dino/Dino_061614';
cd(basepath)

Par = LoadPar([basename '.xml']);
voltsperunit = VoltsPerUnit(basename,basepath);
% presleepstartstop = [0 13128];%rough manual entry, in seconds
% postsleepstartstop = [15606 Inf];%rough manual entry, in seconds

% To Do
%>> Do StateEditor(basename)
%>> Make a _SpikeGroupAnatomy.csv using gdrive
goodshanks = [1:8];
RecordingFilesForSleep = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];%Booleans for each component dat of merged recording

goodeegchannel = 46; %base 1
UPstatechannel = goodeegchannel; %Good # of units
Spindlechannel = goodeegchannel; %Superficial cortical is best
Thetachannel = goodeegchannel;
Ripplechannel = Thetachannel;

% Run
RecordingFileIntervals = FileStartStopsToIntervals(basename);
FileStartStopsToStateEditorEvent(basename);

SaveBasicMetaData