function [AmplifierChans,AnalogInChans,DigitalInChans,AuxiliaryChans,DigitalOutChans,SupplyChans] = IntanChannelsPerFile(dirpath)
% gives the numbers of channels for each file type based on their number of
% bytes, their bytes per sample and the number of samples in the time
% variable.
%
% based on info at http://www.intantech.com/files/Intan_RHD2000_data_file_formats.pdf
% may also see read_Intan_RHD2000_file.m
%
% Brendon Watson 2016

if ~exist('dirpath','var')
    dirpath = cd;
end

cd(dirpath)%lazy

NumSamps = dir('time.dat');
NumSamps = NumSamps.bytes/4; % int32 = 4 bytes

AmplifierChans = dir('amplifier.dat');
AmplifierChans = AmplifierChans.bytes/2/NumSamps;

AuxiliaryChans = dir('auxiliary.dat');
AuxiliaryChans = AuxiliaryChans.bytes/2/NumSamps;

SupplyChans = dir('supply.dat');
SupplyChans = SupplyChans.bytes/2/NumSamps;

if exist('analogin.dat','file')
    AnalogInChans = dir('analogin.dat');
    AnalogInChans = AnalogInChans.bytes/2/NumSamps;
else
    AnalogInChans = 0;
end

if exist('digitalin.dat','file')
    DigitalInChans = 16; %always all 16 channels or none
else
    DigitalInChans = 0;
end

if exist('digitalout.dat','file')
    DigitalOutChans = 16; %always all 16 channels or none
else
    DigitalOutChans = 0;
end

