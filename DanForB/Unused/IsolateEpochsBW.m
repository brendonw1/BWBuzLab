function [epochdatapoints,epochsamptimes,droppedints] = IsolateEpochsBW(data,int,win,samptimes)
%[epochs] = IsolateEpochs2(data,int,win,sf) extracts data in intervals with
%sorrounding time windows win and puts them in a cell array. Useful to
%align/compare intervals of different durations, especially when used with 
%CellToNaNMat.  Greatly improved over the original IsolateEpochs
%
%INPUTS
%   -data   [Nt x Nd] continuous time series data, Ndims = 1 or 2;
%   -int    [Nint x 2] start and end time of intervals. note: if start and
%           end time are equal, will simply align to time point with 
%           sorrounding window - for event triggered average etc
%   -win    [Nint x 2] sorrounding time window from int on/offsets to
%           include.  can be [Nint x 1] or [1 x 1]
%   -samptimes     timestamps of samples, in same units as int, one for
%                  each sample in data
%
%OUTPUT
%   -epochs cell array of extracted epochs
%
%
%
%TO DO
%   -Extend to 2D data. For example, spectrogram.
%   -Include output for time points of extracted epochs
%
%Last Updated: 9/17/15
%DLevenstein

SHOWFIGS = false;   %Add the optional input to showfigs

%Convert int into samples
S = int(:,1);
E = int(:,2);

%Window
if size(win,2) == 1
    win = [win,win];
end
win = abs(win);           %W is positive but can be input negative

% %In case data starts in the middle of an epoch, drop first trigger
% if E(1) < S(1)
%     S = S(1:end-1);
%     E = E(2:end);
% end

%Adjust start/end times with window
cS = S;%Start of just the central region
cE = E;%End of just the central region
S = S-win(:,1);
E = E+win(:,2);

% %Drop Overhanging epochs (start/end before/after start/end of data)
% while S(1)<0
%     S(1) = []; E(1) = [];
%     display('Underhanging Epoch Dropped');
% end
% while E(end)>length(data)
%     S(end) = []; E(end) = [];
%     display('Overhanging Epoch Dropped');
% end

%How long are epoc lengths?
epoch_length = E - S; 
% epoch_length_t = epoch_length*si;

num_epochs = length(epoch_length);
droppedints = [];

epochdatapoints = {};
epochsamptimes = {};
for i = 1:num_epochs %if central region is OK, all points within the total window span are output (ie including points outside the center but within the window)
    if cS(i)>0 %&& cE(i)<=max(samptimes)% if bins demanded are within the central region
        ok = samptimes>=S(i) & samptimes<=E(i);
        epochdatapoints{i,1} = data(ok,:);
        epochsamptimes{i,1} = samptimes(ok,:);
    else
        droppedints = [droppedints,i];
%             display('Epoch out of Data Range... Dropped');
        epochdatapoints{i,1} = [];
        epochsamptimes{i,1} = [];
        continue
    end
end

% if isempty(epochdatapoints)
%     epochdatapoints = {};
%     epochdatatimes = {};
% end

%     if S(i)>0 && E(i)<=length(data)% if bins demanded don't run off the end of the actual data
%         ok = samptimes>=S && samptimes<=E;
%         epochs{i,1} = data(ok,:);
%     else
%         %should just make sure central portion is OK
%         
%         
%         
%     if S(i)<=0 | E(i)>length(data)
%         droppedints = [droppedints,i];
%         display('Epoch out of Data Range... Dropped');
%         epochs{i,1} = [];
%     else
%         ok = samptimes>=S && samptimes<=E;
%         epochs{i,1} = data(ok,:);
%     end
% end
% epochs(droppedints) = [];
% 
% 
% end

