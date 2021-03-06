function [ IDX ] = INTtoIDX(INT,len)
%INTtoIDX(INT) Converts state on/offsets to vector of indices
%
%INPUT
%   INT:    {nstates} cell array of intervals - start and end times
%   len:    length of index vector
%
%OUTPUT
%   IDX:    [len x 1] vector of state indices, where states are identified by
%           integers starting from 1, 0 are unmarked.

IDX = zeros(len,1);

numstates = length(INT);
for ss = 1:numstates
    stateints = INT{ss};
    numints = length(stateints(:,1));
    for ii = 1:numints
        IDX(stateints(ii,1):stateints(ii,2))=ss;
    end
end



end

