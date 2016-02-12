function [ INT ] = IDXtoTSDINT( IDX )
%IDXtoINT(IDX) Converts state indices to collection of state intervalSets
%
%INPUT
%   IDX:    [t x 1] vector of state indices, where states are identified by
%           integers starting from 1.
%
%OUTPUT
%   INT:    {nstates} cell array of intervals - start and end times


IDX = IDX(:);

states = unique(IDX);
states(states==0)=[];
numstates = length(states);

IDX = [0; IDX; 0];
for ss = 1:numstates
    statetimes = IDX==states(ss);
    INT{ss} = intervalSet(find(diff(statetimes)==1)*10000,(find(diff(statetimes)==-1)-1)*10000);
end



end
