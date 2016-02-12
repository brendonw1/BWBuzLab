function [epochs,droppedints] = IsolateEpochs2(data,int,win,sf,includeNaN)
%[epochs] = IsolateEpochs2(data,int,win,sf) extracts data in intervals with
%sorrounding time windows win and puts them in a cell array. Useful to
%align/compare intervals of different durations, especially when used with 
%CellToNaNMat.  Greatly improved over the original IsolateEpochs
%
%INPUTS
%   -data   [Nt x Nd] continuous time series data, Nd = 1 or 2;
%   -int    [Nint x 2] start and end time of intervals. note: if start and
%           end time are equal, will simply align to time point with 
%           sorrounding window - for event triggered average etc
%           (optional) can be TSObject intervalSet
%   -win    [Nint x 2] sorrounding time window from int on/offsets to
%           include.  can be [Nint x 1] or [1 x 1]
%   sf      sampling frequency (Hz)
%
%   includeNaN      (optional) if 'includeNaN', then pad over/underhanging
%                   epochs with NaN
%
%OUTPUT
%   -epochs cell array of extracted epochs
%
%
%
%TO DO
%   -Include output for time points of extracted epochs
%   -Add option to put in time vector instead of sf (non-continuous data)
%
%Last Updated: 11/17/15
%DLevenstein
%%
if exist('includeNaN','var')
    if strcmp(includeNaN,'includeNaN')
        includeNaN = true;
    else
        display('includeNaN should say "includeNaN"')
    end
else
    includeNaN = false;
end
   
if isa(int,'intervalSet')
    int = [Start(int,'s'), End(int,'s')];
end

if isempty(int)
    epochs = {};
    return
end


si = 1/sf;

%Convert int into samples
if length(int(1,:)) == 1
    int = [int,int];
end
S = int(:,1)*sf;
E = int(:,2)*sf;

%Window
if length(win(1,:)) == 1
    win = [win,win];
end
win = abs(win);           %W is positive but can be input negative
W_si = win/si;          %W in samples


% %In case data starts in the middle of an epoch, drop first trigger
% if E(1) < S(1)
%     S = S(1:end-1);
%     E = E(2:end);
% end

%Adjust start/end times with window
S = S-W_si(:,1);
E = E+W_si(:,2);

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
epoch_length_t = epoch_length*si;

num_epochs = length(epoch_length);
droppedints = [];

for i = 1:num_epochs
    if S(i)<=0 | E(i)>length(data)
        if includeNaN
             if S(i)<=0
                 underhangNaN = NaN(1-S(i),length(data(1,:)));
                 epochs{i,1} = vertcat(underhangNaN,data(1:E(i),:));
                 continue
             elseif E(i)>length(data)
                 overhangingNaN = NaN(E(i)-length(data),length(data(1,:)));
                 epochs{i,1} = vertcat(data(S(i):end,:),overhangingNaN);
                 continue
             end
        end
        droppedints = [droppedints,i];
        display('Epoch out of Data Range... Dropped');
        epochs{i,1} = [];
        continue
    end
    epochs{i,1} = data(S(i):E(i),:);
end
epochs(droppedints) = [];


end

