function BatchMergeRecordingsInSession

topdir = cd;
[~,sessionname] = fileparts(cd);
dates = {};
times = {};

filecounter = 0;
d = getdir(cd);
for a = 1:length(d);
    disp(d(a).name)
    tpath = fullfile(topdir,d(a).name);
    if isdir(tpath)
        cd (tpath)
        disp(d(a).name)
        
        filecounter = filecounter + 1;
        if filecounter == 1;
            continue
        end
        
        % merge files
        DatMergeWrapper
        
        % Move merged dat to upper level with name -01,-02 etc
        if a<10
            filenumstr = ['0',num2str(filecounter)];
        else
            filenumstr = num2str(filecounter);
        end
        movefile('merge.dat',fullfile(topdir,[sessionname,'-',filenumstr,'.dat']));
        
        %Save original file start times
        underscores = strfind(d(a).name,'_');
        dates{end+1} = d(a).name(underscores(end-1)+1:underscores(end)-1);
        times{end+1} = d(a).name(underscores(end)+1:end);
        cd(tpath)
    end
end

save('DatesAndTimes.mat','dates','times')

