function [ ints1,ints2,ints1idx,ints2idx ] = FindIntsNextToInts(ints1,ints2,tol)
%FindIntsNextToInts(ints1,ints2,tol) returns only the intervals from the
%sets ints1 and ints2 such that an interval from ints1 is directly
%preceeding an interval from ints2, with the option of allowing for some 
%time delay tolerance.
%
%INPUTS
%   ints1,ints2     two interval sets [Nints x 2]
%                   (optional) can be TSObjects intervalSet
%   tol             time tolerance
%
%Last Updated: 11/20/15
%DLevenstein
%%
if isempty(ints1) || isempty(ints2)
    ints1=[];ints2=[];ints1idx=[];ints2idx=[];
    return
end

if isa(ints1,'intervalSet')
    ints1 = [Start(ints1,'s'), End(ints1,'s')];
end
if isa(ints2,'intervalSet')
    ints2 = [Start(ints2,'s'), End(ints2,'s')];
end

if ~exist('tol','var')
    tol = 1;
end

ints1idx = [];
ints2idx = [];
numints1 = length(ints1(:,1));
for ii = 1:numints1
    interintdist = ints2(:,1)-ints1(ii,2);
    closeints = find(interintdist<=tol & interintdist>=0,1,'first');
    if ~isempty(closeints)
        ints1idx = [ints1idx ; ii];
        ints2idx = [ints2idx ; closeints];
    end
end

ints1 = ints1(ints1idx,:);
ints2 = ints2(ints2idx,:);

end

