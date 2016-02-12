function SecondsAfterLightCycleStart = TimeFromLightCycleStart(basepath,basename)

if ~exist('basepath','var')
 [~,basename,~] = fileparts(cd);
 basepath = cd;   
end

bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
if isfield(bmd,'masterpath')
    basepath = bmd.masterpath;
    basename = bmd.mastername;
end

fname = fullfile(basepath,[basename '-01.meta']);

out = ReadMetaAspects(fname,'starttime');

h = str2num(out(1:2));
m = str2num(out(4:5));
s = str2num(out(7:8));

% lightson = 06:00:00;
lightsonhours = 6;
lightsonminutes = 0;
lightsonseconds = 0;

hoursecs = (h-lightsonhours)*3600;
minsecs = (m-lightsonminutes)*60;

SecondsAfterLightCycleStart = hoursecs+minsecs+s;

if isfield(bmd,'masterpath')
    savepath = fullfile(bmd.basepath,[bmd.basename '_SecondsFromLightsOn.mat']);
else
    savepath = fullfile(basepath,[basename '_SecondsFromLightsOn.mat']);
end


save(savepath,'SecondsAfterLightCycleStart')