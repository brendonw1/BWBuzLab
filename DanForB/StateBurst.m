function [ StateBurst_out ] = StateBurst(spkObject, intervals, states, restrictinginterval)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
%Output:
%   ISI distribution (log ISI)
%   ISI hist bins
%   Mean burst rate
%   "burst index" (% ISI < 10ms)   - variable threshold?
%
%TO DO
%   -Comment...
%
%Last Updated: 7/14/15
%DLevenstein
%% 


%Parms
ISI_numhistbins = 60;
burstthresh = 0.01; %s

display('State Bursting');

numstates = length(states);
numcells = length(spkObject);

%Restrict spkObject,intervals to restrictioninterval
if exist('restrictinginterval','var')
    for i = states
        intervals{i} = intersect(intervals{i},restrictinginterval);
    end
end



%%


ISI_histbins = linspace(-3,3,ISI_numhistbins);
ISIhists = zeros(length(ISI_histbins),numcells,numstates);
for s = 1:numstates
    st = states(s);
    stSpikes_obj = Restrict(spkObject,intervals{st});
    for c = 1:numcells
        stSpikes{c} = Range(stSpikes_obj{c},'s');
    end
    
    stISIs = cellfun(@diff,stSpikes,'UniformOutput', false);
    log_stISIs = cellfun(@log10,stISIs,'UniformOutput', false);
    
    for c = 1:numcells
        ISIhists(:,c,s)= hist(log_stISIs{c},ISI_histbins);
        ISIhists(:,c,s) = ISIhists(:,c,s)./sum(ISIhists(:,c,s));
    end
end

StateBurst_out.ISIhist = ISIhists;
StateBurst_out.logISIhistbins = ISI_histbins;
StateBurst_out.ISIhistbins = 10.^ISI_histbins;
StateBurst_out.burstindex = sum(ISIhists(1:find(StateBurst_out.ISIhistbins<0.01,1,'last')+1,:,:));

end

