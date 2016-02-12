%manually: make a folder with fbasename
%have all files in it
%generate xml with name fbasename
%navigate to that folder

%% get basename, assume the current directory is named basename
dirname = cd;
f = filesep;
r = regexp(dirname,f);%find the slash
basename = dirname(r(end)+1:end);%take from after the last slash to the end

%%
RemoveDCfromDat_AllDat

%% put all .dats in a subfolder called basename or to isis
% mkdir(basename);
% movefile('*.dat',basename)
newfolder = ['/mnt/isis3/brendon/',basename];
mkdir(newfolder);
eval(['! cp *.dat ',newfolder]);
eval(['! ',basename,'.xml mnt/isis3/brendon');

%% 
cd (newfolder)
cd ..

% eval(['!ndm_start ',basename,'.xml ',basename,'/'])
eval(['!ndmscript ',basename,'.xml ',basename,'/'])

%% 

cd(dirname)
mkdir('OrignalTsps')
d = dir('*.tsp');
answer = inputdlg('Enter number of movie that should be used as map of animal behavior');
goodmovie = str2num(answer{1});%do first movie first, to get coordinates
allbutgoodmovie = 1:length(d);
allbutgoodmovie(goodmovie) = [];
sequence = [goodmovie allbutgoodmovie];
for a = sequence;
    thisfile = d(a).name;
    thisfilenotsp = thisfile(1:end-4);
    origtspname = [thisfilenotsp,'_original.tsp'];
    movefile(thisfile,origtspname);
    if a == goodmovie;
        LEDbounds = ConfineTspOutput(origtspname,thisfile);
    else
        ConfineTspOutput(origtspname,thisfile,LEDbounds)
    end
    movefile(origtspname,'OriginalTsps')
end

%%
answer = inputdlg('Enter color channels you want to use: 1 thru 3','Color Channel Selection',1,{'1 3'});
colorix = str2num(answer{1});
AlignTsp2Whl_All('colorix',colorix);