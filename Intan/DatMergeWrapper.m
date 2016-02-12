function DatMergeWrapper
% Assumes you are in the folder with amplifier.dat etc
% Brendon Watson 2016

%% Get number of channels per file type
[AmplifierChans,AnalogInChans,DigitalInChans,AuxiliaryChans,DigitalOutChans,SupplyChans] = IntanChannelsPerFile(cd);

%% Merge filetypes
if AnalogInChans>0
    %for now just Amplifier and AnalogIn
    MergeDats({'amplifier.dat';'analogin.dat'},'merge.dat',[AmplifierChans,AnalogInChans])
else
    copyfile ('amplifier.dat','merge.dat');
end

%% Modify .xml to match channel numbers

%% ... meantime make a file whose name is channel numbers per file type
numberstring = ['Amp' num2str(AmplifierChans) '-Alg' num2str(AnalogInChans) '.chans'];
fid = fopen(numberstring,'w');
fclose(fid)

